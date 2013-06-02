//
//  QueryConcrete.m
//  QueryManager
//
//  Created by Matthias Stumpp on 02.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import "QueryConcrete.h"

@interface QueryConcrete()
@property NSTimeInterval delay;
@property Logger *logger;
@end

@implementation QueryConcrete

-(QueryConcrete*)initWithDelay:(NSTimeInterval)delay withIdentifier:(id)identifier andLogger:(Logger*)logger
{
    self = [super init];
    if (self) {
        self.delay = delay;
        self.logger = logger;
        self.identifier = identifier;
    }
    return self;
}

-(void)load
{
    [self performSelector:@selector(setLoaded) withObject:nil afterDelay:self.delay];
    [self.logger addString:[NSString stringWithFormat:@"q%@:loading", self.identifier] finished:FALSE];
    [super loading:TRUE];
}

-(void)setLoaded
{
    [self.logger addString:[NSString stringWithFormat:@"q%@:loaded", self.identifier] finished:TRUE];
    [super loaded:TRUE];
}

-(void)cancel
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setLoaded) object:nil];
    [self.logger addString:[NSString stringWithFormat:@"q%@:cancelled", self.identifier] finished:TRUE];
    [super cancelled:TRUE];
}

-(void)pause
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setLoaded) object:nil];
    [self.logger addString:[NSString stringWithFormat:@"q%@:paused", self.identifier] finished:FALSE];
    [super paused:TRUE];
}

@end