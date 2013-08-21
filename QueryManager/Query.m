//
//  Query.m
//  QueryManager
//
//  Created by Matthias Stumpp on 02.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import "Query.h"

@interface Query()
@property Queue* queue;
@property id data;
@property QueryCompletionHandler handler;
@property dispatch_semaphore_t sema;
@end

@implementation Query

+(Query*)instanceWithQueue:(Queue*)queue
{
    Query *instance = [self new];
    instance.queue = queue;
    [instance addObserver:instance forKeyPath:tReady options:NSKeyValueObservingOptionNew context:NULL];
    [instance addObserver:instance forKeyPath:tExecuting options:NSKeyValueObservingOptionNew context:NULL];
    [instance addObserver:instance forKeyPath:tCancelled options:NSKeyValueObservingOptionNew context:NULL];
    [instance addObserver:instance forKeyPath:tFinished options:NSKeyValueObservingOptionNew context:NULL];
    return instance;
}

-(Query*)execute:(id)data onStateChange:(QueryCompletionHandler)handler;
{
    return [self execute:data withPrio:NSOperationQueuePriorityNormal onStateChange:handler];
}

-(Query*)execute:(id)data withPrio:(NSInteger)p onStateChange:(QueryCompletionHandler)handler
{
    self.data = data;
    self.handler = handler;
    [self setQueuePriority:p];
    [self.queue addOperation:self];
    return self;
}

-(void)main
{
    @try
    {
        self.sema = dispatch_semaphore_create(1);
        [self load:self.data];
        dispatch_semaphore_wait(self.sema, DISPATCH_TIME_FOREVER);
    }

    @catch(NSException *e)
    {
        // Do not rethrow exceptions.
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if ([keyPath isEqual:tCancelled])
        [self cancelled:self.data];

    self.handler(self, self.data);

    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
}

-(void)loaded
{
    dispatch_semaphore_signal(self.sema);
}

-(void)setData:(id)data
{
    self.data = data;
}

-(id)data
{
    return self.data;
}

/////
// these methods may be overwritten by concrete query classes
/////

// main operation code goes here
// check if cancelled [self isCancelled] whenever possible

-(void)load:(id)data
{
    return;
}

-(void)cancelled:(id)data
{
    return;
}

@end