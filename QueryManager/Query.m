//
//  Query.m
//  QueryManager
//
//  Created by Matthias Stumpp on 02.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import "Query.h"

@implementation Query

+(Query*)instanceWithQueue:(Queue*)queue
{
    Query *instance = [[self allocWithZone:NULL] init];
    instance.state = tUninitialized;
    [queue addQuery:instance];
    return instance;
}

-(QueryTicket*) process:(id)data onCompletion:(QueryCompletionHandler)handler;
{
    self.data = data;
    self.handler = handler;
    [self toState:tUnloaded];
}

-(BOOL)inPrio:(uint)p
{
    return (self.prio == p);
}

-(void)toPrio:(uint)prio
{
    if (self.prio != prio)
    {
        int tmpPrio = [self prio];
        self.prio = prio;
        if (self.queue)
            [self.queue prioChangeFrom:tmpPrio to:self.prio forQuery:self];
    }
}

-(BOOL)inState:(int)state
{
    return (self.state == state);
}

-(BOOL)toState:(int)to
{
    return [self inState:tAny toState:to];
}

-(BOOL)inState:(int)from toState:(int)to
{
    if (from != tAny && self.state != from)
        return FALSE;
    
    if (self.state == to)
        return FALSE;
    
    BOOL result = FALSE;
    switch (to)
    {
        case tUnloaded:
        {
            if (self.state == tUninitialized)
                result = TRUE;
            break;
        }

        case tLoading:
        {            
            if (self.state == tUnloaded || self.state == tPaused)
                result = TRUE;
            break;
        }
            
        case tLoaded:
        {
            if (self.state == tLoading)
                result = TRUE;
            break;
        }

        case tPausing:
        {
            if (self.state == tUnloaded || self.state == tLoading)
                result = TRUE;
            break;
        }

        case tPaused:
        {
            if (self.state == tPausing)
                result = TRUE;
            break;
        }

        case tCancelling:
        {
            if (self.state == tUnloaded || self.state == tPaused || self.state == tLoading)
                result = TRUE;
            break;
        }
            
        case tCancelled:
        {
            if (self.state == tCancelling)
                result = TRUE;
            break;
        }
            
        default:
        {
            [NSException raise:NSInvalidArgumentException format:@"other than tLoading, tLoaded, tPaused or tCancelled not supported as to state!"];
        }
    }
    if (result) {
        int tmpState = self.state;
        self.state = to;
        if (self.queue)
            [self.queue stateChangeFrom:tmpState to:self.state forQuery:self];
    }
    return result;
}

// these actions are usually called by a queue instance

-(BOOL)do:(uint)action
{
    BOOL result = FALSE;
    switch (action)
    {
        case tLoad:
        {
            if ([self toState:tLoading]) {
                [self load:self.data];
                result = TRUE;
            }
            break;
        }

        case tPause:
        {
            if ([self toState:tPausing]) {
                [self pause:self.data];
                result = TRUE;
            }
            break;
        }

        case tCancel:
        {
            if ([self toState:tCancelling]) {
                [self cancel:self.data];
                result = TRUE;
            }
            break;
        }

        default:
        {
            [NSException raise:NSInvalidArgumentException format:@"other than tLoad, tPause or tCancel not supported as action!"];
        }
    }
    return result;
}

// these methods must be overwritten by concrete query classes

-(void)load:(id)data
{
    [NSException raise:NSInvalidArgumentException format:@"load method must be overwritten!"];
}

-(void)pause:(id)data
{
    [NSException raise:NSInvalidArgumentException format:@"pause method must be overwritten!"];
}

-(void)cancel:(id)data
{
    [NSException raise:NSInvalidArgumentException format:@"cancel method must be overwritten!"];
}

// these methods are called by load, pause or cancel method code

-(void)loadedWithData:(id)entry andError:(NSError*)error
{
    if ([self toState:tLoaded])
        self.handler(tLoaded, entry, error);
}

-(void)pausedWithData:(id)entry andError:(NSError*)error
{
    if ([self toState:tPaused])
        self.handler(tPaused, entry, error);
}

-(void)cancelledWithData:(id)entry andError:(NSError*)error
{
    if ([self toState:tCancelled])
        self.handler(tCancelled, entry, error);
}

@end