//
//  Queue.m
//  QueryManager
//
//  Created by Matthias Stumpp on 02.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import "Queue.h"
#import "QueryConcrete.h"

@interface Queue()
@property int queueMaxSize;
@property int queueCurrentSize;
@property int numberMaxConcurrent;
@property int processOrder;
@property int finishHigherPrioFirst;
@property BOOL pauseWhileLoading;
@property BOOL cancelWhileLoading;
@property (strong, nonatomic) NSMutableDictionary *queries;
@property (strong, nonatomic) NSMutableArray *processingQueries;
@end

@implementation Queue

-(Queue*)initWithIdentifier:(id)identifier queueMaxSize:(int)queueMaxSize numberMaxConcurrent:(int)numberMaxConcurrent processOrder:(int)processOrder finishHigherPrioFirst:(BOOL)finishHigherPrioFirst pauseWhileLoading:(BOOL)pauseWhileLoading cancelWhileLoading:(BOOL)cancelWhileLoading
{
    self = [super init];
    if (self) {
        self.identifier = identifier;
        
        self.queueMaxSize = queueMaxSize;
        self.queueCurrentSize = 0;
        
        self.processOrder = processOrder;
        self.finishHigherPrioFirst = finishHigherPrioFirst;

        self.numberMaxConcurrent = numberMaxConcurrent;
        self.pauseWhileLoading = pauseWhileLoading;
        self.cancelWhileLoading = cancelWhileLoading;
        
        self.queries = [NSMutableDictionary dictionary];
        self.processingQueries = [NSMutableArray array];
    }
    return self;
}

-(QueryTicket*)addQuery:(Query*)query
{
    if (!query)
        [NSException raise:NSInvalidArgumentException format:@"query must be provided!"];

    if (!p)
        p = INFINITY;

    QueryTicket *ticket = [[QueryTicket alloc] initWithQuery:query];
    
    // add array for prio in case no mutable array yet initialized
    if (![self.queries objectForKey:[NSNumber numberWithInt:prio]])
        [self.queries setObject:[NSMutableArray array] forKey:[NSNumber numberWithInt:prio]];
    
    // add query
    // if last in, first out, add at the beginning of array
    if (self.processOrder == tlifo)
        [[self.queries objectForKey:[NSNumber numberWithInt:prio]] insertObject:query atIndex:0];
    // if last in, last out, add at the end of array
    else
        [[self.queries objectForKey:[NSNumber numberWithInt:prio]] addObject:query];
    
    //NSLog(@"query %@ to queue %@", [(QueryConcrete*)query identifier], self.identifier);
    
    self.queueCurrentSize++;

    // cancel query if
    if (![self queueSpaceLeft])
        return [ticket cancel];
    
    if (self.processOrder == tlifo && self.cancelWhileLoading && [self setQueries:tOne inState:tLoading toState:tCancelled andSmallerPrio:prio includePrio:TRUE excludeQuery:query])
        cancel = FALSE;

    // check if queries have to be paused due to finishHigherPrioFirst = true
    // this may cause loading of current query already
    if (self.finishHigherPrioFirst)
        [self setQueries:tAll inState:tAny toState:tPaused andSmallerPrio:prio includePrio:FALSE excludeQuery:nil];
    
    // if query with smaller prios exists, pause it in order
    // to free a connection for currently added query
    if (self.pauseWhileLoading && ![self hasConcurrentConnectionsLeft] && ([query inState:tUnloaded] || [query inState:tPaused]))
        [self setQueries:tOne inState:tLoading toState:tPaused andSmallerPrio:prio includePrio:TRUE excludeQuery:query];

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
            if (![self.processingQueries containsObject:query]) {
                [self.processingQueries addObject:query];
            }
            break;
        }
            
        case tPaused:
        {
            switch (from)
            {
                case tLoading:
                {
                    [self.processingQueries removeObject:query];
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
                    //NSLog(@"queue %@: tLoaded", self.identifier);
                    [self.processingQueries removeObject:query];
                    if ([[self.queries objectForKey:[NSNumber numberWithInt:[query prio]]] containsObject:query]) {
                        [[self.queries objectForKey:[NSNumber numberWithInt:[query prio]]] removeObject:query];
                        self.queueCurrentSize--;
                    }
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
                    [self.processingQueries removeObject:query];
                    if ([[self.queries objectForKey:[NSNumber numberWithInt:[query prio]]] containsObject:query]) {
                        [[self.queries objectForKey:[NSNumber numberWithInt:[query prio]]] removeObject:query];
                        self.queueCurrentSize--;
                    }
                    break;
                }
                    
                    // tUnloaded, tPaused
                default:
                {
                    if ([[self.queries objectForKey:[NSNumber numberWithInt:[query prio]]] containsObject:query]) {
                        [[self.queries objectForKey:[NSNumber numberWithInt:[query prio]]] removeObject:query];
                        self.queueCurrentSize--;
                    }
                    break;
                }
            }
            break;
        }
    }
    
    [self.queryManager stateChangeFrom:from to:to forQuery:query];
}

-(void)prioChangeFrom:(int)from to:(int)to forQuery:(Query*)query
{
    if (!from || !to || !query)
        [NSException raise:NSInvalidArgumentException format:@"from, to and query must be provided!"];
    
    [self moveQuery:query fromKey:from toKey:to];
    [query toState:tPaused];
    
    [self.queryManager prioChangeFrom:from to:to forQuery:query];
}

-(int)process:(uint)numberToProcess
{
    NSArray* prios =  [[self.queries allKeys] sortedArrayUsingSelector:@selector(compare:)];
    int numberProcessed = 0;
    for(NSNumber* prioKey in prios) {
        
        // if no more connections left, stop looking for processing queries for current prio at all
        if (![self hasConcurrentConnectionsLeft] ||
            (numberToProcess != tUnlimitedConcurrentConnections && numberToProcess == 0))
            break;
        
        // otherwise, process queues for this prio one after another
        NSMutableArray *queriesForPrio = [self.queries objectForKey:prioKey];
        for (Query *query in queriesForPrio) {
            if (![query inState:tLoading]) {
                [query toState:tLoading];
                if ([query inState:tLoading]) {
                    numberProcessed++;
                    if (numberToProcess != tUnlimitedConcurrentConnections)
                        numberToProcess--;
                }
            }
                        
            // if no more connections left or numberToProcess = 0,
            // stop looking for processing more queries for current prio
            if (![self hasConcurrentConnectionsLeft] ||
                (numberToProcess != tUnlimitedConcurrentConnections && numberToProcess == 0))
                break;
        }
        
        // if finihHigherPrioFirst = true,
        // do not process queries of smaller prios
        if (self.finishHigherPrioFirst && [queriesForPrio count] > 0)
            break;
    }
    
    return numberProcessed;
}

-(BOOL)hasConcurrentConnectionsLeft
{
    if (self.numberMaxConcurrent == tUnlimitedConcurrentConnections)
        return TRUE;
    
    return (self.numberMaxConcurrent - [[self processingQueries] count]) > 0;
}

-(BOOL)queueSpaceLeft
{
    if (self.queueMaxSize == tUnlimitedQueueSize)
        return TRUE;
    
    return (self.queueMaxSize - [[self processingQueries] count]) > 0;
}

-(BOOL)hasQueriesInQueue
{
    return self.queueCurrentSize > 0;
}

// private helpers

-(int)setQueries:(int)number inState:(int)from toState:(int)to andSmallerPrio:(uint)prio includePrio:(BOOL)includePrio excludeQuery:(Query*)excludeQuery
{
    if (!number || !from || !to)
        [NSException raise:NSInvalidArgumentException format:@"number, prio, from and to must be provided!"];
    
    NSNumber* currentPrio = [NSNumber numberWithInt:prio];
    NSArray* prios =  [[self.queries allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSArray* reversedPrios = [[prios reverseObjectEnumerator] allObjects];
    //NSEnumerator *e = [reversedPrios objectEnumerator];
    int queriesProcessed = 0;
    NSMutableArray *queriesForPrio;
    NSArray* reversedArray;
    //NSNumber* prioKey;
    //while (((prioKey = [e nextObject]) >= currentPrio)) {
    for (NSNumber* prioKey in reversedPrios) {
        if (!([prioKey compare:currentPrio] == NSOrderedDescending || [prioKey compare:currentPrio] == NSOrderedSame))
            break;
        
        if (!includePrio && [prioKey compare:currentPrio] == NSOrderedSame)
            break;
        
        //if (!includePrio && prioKey == currentPrio)
         //   break;
        
        queriesForPrio = [self.queries objectForKey:prioKey];
        reversedArray = [[queriesForPrio reverseObjectEnumerator] allObjects];
        
        for (Query *query in reversedArray) {
            if (excludeQuery && query == excludeQuery)
                return queriesProcessed;
            
            if ([query inState:from toState:to])
                queriesProcessed++;
            
            if (number == tOne && queriesProcessed == 1)
                return 1;
        }
    }
    return queriesProcessed;
}

-(void)moveQuery:(Query*)query fromKey:(int)from toKey:(int)to
{
    if (!query || !from || !to)
        [NSException raise:NSInvalidArgumentException format:@"from, to and query must be provided!"];
    
    // add array for prio in case no array not yet initialized
    if (![self.queries objectForKey:[NSNumber numberWithInt:to]])
        [self.queries setObject:[NSMutableArray array] forKey:[NSNumber numberWithInt:to]];
    
    // move query from previous to current prio queue
    [[self.queries objectForKey:[NSNumber numberWithInt:from]] removeObject:query];
    
    [[self.queries objectForKey:[NSNumber numberWithInt:to]] addObject:query];
}

-(BOOL)inPrio:(uint)p
{
    return (self.prio == p);
}

-(void)toPrio:(uint)p
{
    self.prio = p;
}

@end

