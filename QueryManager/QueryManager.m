//
//  QueryManager.m
//  QueryManager
//
//  Created by Matthias Stumpp on 02.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import "QueryManager.h"

@interface QueryManager()
@property (strong, nonatomic) NSMutableDictionary *queues;
@property int currentConcurrentConnections;
@end

@implementation QueryManager

@synthesize maxConcurrentConnections;
@synthesize finishHigherPrioFirst;
@synthesize pauseWhileLoading;

static QueryManager *classInstance = nil;

+(QueryManager*)instance
{
    if (classInstance == nil) {
        classInstance = [[super allocWithZone:NULL] init];
        
        classInstance.queues = [NSMutableDictionary dictionary];
        
        // one concurrent connection = one query in state tLoading
        classInstance.maxConcurrentConnections = tUnlimitedConcurrentConnections;
        classInstance.currentConcurrentConnections = 0;
        classInstance.finishHigherPrioFirst = TRUE;
        classInstance.pauseWhileLoading = TRUE;
    }
    return classInstance;
}

-(Queue*)addQueue:(Queue*)queue prio:(uint)p
{
    if (!queue)
        [NSException raise:NSInvalidArgumentException format:@"queue and prio must be provided!"];
    
    [queue setPrio:p];
    [queue setQueryManager:self];
    
    if (![classInstance.queues objectForKey:[NSNumber numberWithInt:p]])
        [classInstance.queues setObject:[NSMutableDictionary dictionary] forKey:[NSNumber numberWithInt:p]];
    
    if ([[classInstance.queues objectForKey:[NSNumber numberWithInt:p]] objectForKey:queue.identifier]) {
        NSLog(@"queue with the same identifier already exists for this prio!");
        return [[classInstance.queues objectForKey:[NSNumber numberWithInt:p]] objectForKey:queue.identifier];
    }
            
    [[classInstance.queues objectForKey:[NSNumber numberWithInt:p]] setObject:queue forKey:queue.identifier];
    
    return queue;
}

-(QueryTicket*)process:(Query*)query prio:(uint)prio queue:(Queue*)queue
{
    if (!query || !queue) {
        [NSException raise:NSInvalidArgumentException format:@"query, prio and queue must be provided!"];
        return nil;
    }
    
    // set up query
    query.prio = prio;
    query.queryManager = self;
    query.queue = queue;
    
    // add query to queue, receive ticket
    QueryTicket *ticket = [queue addQuery:query prio:prio];
    
    // query may haven been immediately cancelled, e.g. if max queue size reached
    if ([ticket inState:tCancelled])
        return ticket;
        
    // check if queries have to be paused due to finishHigherPrioFirst = true
    // this may cause loading of current query already
    if (self.finishHigherPrioFirst) {
        //NSLog(@"%d", [queue prio]);
        [self setQueries:tAll inState:tAny toState:tPaused andSmallerPrio:[queue prio] includePrio:FALSE excludeQueue:nil];
    }
    
    if ([self hasConcurrentConnectionsLeft]) {
        // if at least one connection left, use this to process previously added query
        // by running the loop
        if (([query inState:tUnloaded] || [query inState:tPaused])) {
            [self runLoop];
        }
        
    } else {
        // if no connection left and pauseWhileLoading = true,
        // check if there is a query in state tLoading in a queue of smaller or equal prio
        // compared to prio of current queue which may be tPaused
        if (([query inState:tUnloaded] || [query inState:tPaused]) && self.pauseWhileLoading) {
            [self setQueries:tOne inState:tLoading toState:tPaused andSmallerPrio:[queue prio] includePrio:TRUE excludeQueue:queue];
        }
    }
    
    return ticket;
}

-(void)stateChangeFrom:(int)from to:(int)to forQuery:(Query*)query
{
    if (!from || !to || !query)
        [NSException raise:NSInvalidArgumentException format:@"from, to and query must be provided!"];
    
    switch (to)
    {
        case tLoading:
        {
            self.currentConcurrentConnections++;
            break;
        }
            
        case tPaused:
        {
            switch (from)
            {
                case tLoading:
                {
                    self.currentConcurrentConnections--;
                    [self runLoop];
                    break;
                }
            }
            break;
        }
            
        case tLoaded:
        {
            switch (from)
            {
                case tLoading:
                {
                    self.currentConcurrentConnections--;
                    [self runLoop];
                    break;
                }
            }
            break;
        }
            
        case tCancelled:
        {
            switch (from)
            {
                case tLoading:
                {
                    self.currentConcurrentConnections--;
                    [self runLoop];
                    break;
                }
            }
            break;
        }
    }
}

-(void)prioChangeFrom:(int)from to:(int)to forQuery:(Query*)query
{
    if (!from || !to || !query)
        [NSException raise:NSInvalidArgumentException format:@"from, to and query must be provided!"];
    
    [self runLoop];
}

// private helpers

-(void)runLoop
{
    NSArray* prios =  [[self.queues allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for(NSNumber* prio in prios) {
        
        // if no more connections left, stop looking for processing queries for current prio at all
        if (![self hasConcurrentConnectionsLeft])
            break;
        
        // otherwise, process queues for this prio one after another
        NSMutableDictionary *queuesForPrio = [self.queues objectForKey:prio];
        BOOL hasQueriesInQueue = FALSE;
        Queue *queue = nil;
        for (id queueKey in queuesForPrio) {
            queue = [queuesForPrio objectForKey:queueKey];
            [queue process:[self concurrentConnectionsLeft]];
            if ([queue hasQueriesInQueue])
                hasQueriesInQueue = TRUE;
            
            // if no more connections left, stop looking for processing more queries for current prio
            if (![self hasConcurrentConnectionsLeft])
                break;
        }
        
        // if finihHigherPrioFirst = true,
        // do not process queries of smaller prios
        if (self.finishHigherPrioFirst && hasQueriesInQueue)
            break;
    }
}

-(int)setQueries:(int)number inState:(int)from toState:(int)to andSmallerPrio:(uint)prio includePrio:(BOOL)includePrio excludeQueue:(Queue*)excludeQueue
{
    if (!number || !from || !to)
        [NSException raise:NSInvalidArgumentException format:@"number, prio, from and to must be provided!"];
    
    NSNumber* currentPrio = [NSNumber numberWithInt:prio];
    NSLog(@"currentPrio: %d", [currentPrio intValue]);
    NSArray* prios =  [[self.queues allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSArray* reversedPrios = [[prios reverseObjectEnumerator] allObjects];
    //NSEnumerator *e = [reversedPrios objectEnumerator];
    int queriesProcessed = 0;
    NSMutableDictionary *queuesForPrio;
    NSArray* reversedIdentifiers;
    //NSNumber* prioKey;
    //while (((prioKey = [e nextObject]) >= currentPrio)) {
    for (NSNumber* prioKey in reversedPrios) {
        
        if (!([prioKey compare:currentPrio] == NSOrderedDescending || [prioKey compare:currentPrio] == NSOrderedSame))
            break;
            
        NSLog(@"prioKey: %@", prioKey);
        //NSLog(@"%d", [prioKey intValue]);

        if (!includePrio && [prioKey compare:currentPrio] == NSOrderedSame) {
            NSLog(@"break");
            break;
        }
        
        NSLog(@"prioKey pass");
        
        queuesForPrio = [self.queues objectForKey:prioKey];
        reversedIdentifiers = [[[queuesForPrio allKeys] reverseObjectEnumerator] allObjects];
                
        Queue *queue;
        for (id queueKey in reversedIdentifiers) {
            queue = [queuesForPrio objectForKey:queueKey];
            
            if (excludeQueue && queue == excludeQueue)
                return queriesProcessed;
            
            queriesProcessed += [queue setQueries:number inState:from toState:to andSmallerPrio:0 includePrio:TRUE excludeQuery:nil];
            
            if (number == tOne && queriesProcessed == 1)
                return 1;
        }
    }
    return queriesProcessed;
}

-(int)concurrentConnectionsLeft
{
    if (self.maxConcurrentConnections == tUnlimitedConcurrentConnections)
        return tUnlimitedConcurrentConnections;
    
    int result = self.maxConcurrentConnections - self.currentConcurrentConnections;
    return result > 0 ? result : 0;
}

-(BOOL)hasConcurrentConnectionsLeft
{
    if (self.maxConcurrentConnections == tUnlimitedConcurrentConnections)
        return TRUE;
    
    return (self.maxConcurrentConnections - self.currentConcurrentConnections) > 0;
}

-(void)setMaxConcurrentConnections:(int)n
{
    if (!(maxConcurrentConnections == n)) {
        maxConcurrentConnections = n;
        [self setQueries:tAll inState:tAny toState:tPaused andSmallerPrio:0 includePrio:TRUE excludeQueue:nil];
    }
}

-(void)setFinishHigherPrioFirst:(BOOL)n
{
    if (!(finishHigherPrioFirst == n)) {
        finishHigherPrioFirst = n;
        [self setQueries:tAll inState:tAny toState:tPaused andSmallerPrio:0 includePrio:TRUE excludeQueue:nil];
    }
}

-(void)setPauseWhileLoading:(BOOL)n
{
    if (!(pauseWhileLoading == n)) {
        pauseWhileLoading = n;
    }
}

@end

