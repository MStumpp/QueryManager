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
@property id context;
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
 
-(Query*)execute:(id)props context:(id)context onStateChange:(QueryCompletionHandler)handler;
{
    return [self execute:props context:context withPrio:NSOperationQueuePriorityNormal onStateChange:handler];
}

-(Query*)execute:(id)props context:(id)context withPrio:(NSInteger)p onStateChange:(QueryCompletionHandler)handler
{
    self.props = props;
    self.handler = handler;
    self.context = context;
    [self setQueuePriority:p];
    [self.queue addOperation:self];
    return self;
}

-(void)main
{
    @try
    {
        self.someCheckIsTrue = YES;

        [self load:self.props];

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
    //[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqual:tCancelled])
        [self cancelled:self.props];

    if (self.handler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.handler(keyPath, self.result, self.error, self.context);
        });
    }
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

-(void)load:(id)props
{
    [self loaded];
}

-(void)cancelled:(id)props
{
}

@end