//
//  Query.m
//  QueryManager
//
//  Created by Matthias Stumpp on 02.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import "Query.h"

@interface Query()
@property (nonatomic, assign) Queue* queue;
@property (nonatomic, assign) id data;
@property (nonatomic, assign) NSError *error;
@property (nonatomic, copy) QueryCompletionHandler handler;
@property dispatch_semaphore_t sema;
@end

@implementation Query

+(Query*)instanceWithQueue:(Queue*)queue
{
    Query *instance = [self new];
    instance.queue = queue;
    [instance addObserver:instance forKeyPath:tCancelled options:NSKeyValueObservingOptionNew context:NULL];
    [instance addObserver:instance forKeyPath:tFinished options:NSKeyValueObservingOptionNew context:NULL];
    return instance;
}

-(Query*)execute:(id)data onCompletion:(QueryCompletionHandler)handler;
{
    self.data = data;
    self.handler = handler;
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
    if ([keyPath isEqual:tReady]) {
        self.handler(tReady, self.data, self.error);
    } else if ([keyPath isEqual:tExecuting]) {
        self.handler(tExecuting, self.data, self.error);
    } else if ([keyPath isEqual:tCancelled]) {
        [self cancelled:self.data];
        self.handler(tCancelled, self.data, self.error);
    } else if ([keyPath isEqual:tFinished]) {
        self.handler(tFinished, self.data, self.error);
    }

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

-(void)setError:(NSError*)error
{
    self.error = error;
}

-(id)getData
{
    return self.data;
}

-(NSError*)getError
{
    return self.error;
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