//
//  Query.m
//  QueryManager
//
//  Created by Matthias Stumpp on 02.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import "Query.h"

@interface Query()
@property (copy) QueryCompletionHandler handler;
@end

@implementation Query

+(Query*)instanceWithQueue:(Queue*)queue
{
    if (!queue)
        [NSException raise:@"queue must not be null" format:@"queue must not be null"];
    Query *instance = [[self alloc] init];
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
    if (!self.data)
        self.data = [NSMutableDictionary dictionary];
    self.handler = handler;
    [self setQueuePriority:p];
    [self.queue addOperation:self];
    return self;
}

-(void)main
{
    @try
    {
        self.someCheckIsTrue = YES;

        [self load:self.data];

        while (self.someCheckIsTrue) 
        { 
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]; 
        } 
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

    if (self.handler)
        self.handler(self, self.data);

    // [super observeValueForKeyPath:keyPath
    //                      ofObject:object
    //                        change:change
    //                       context:context];
}

-(void)loaded
{
    self.someCheckIsTrue = NO;
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