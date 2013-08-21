//
//  Queue.m
//  QueryManager
//
//  Created by Matthias Stumpp on 02.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import "Queue.h"

@implementation Queue

-(Queue*)initWithName:(id)name
{
    return [self initWithName:name maxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
}

-(Queue*)initWithName:(id)name maxConcurrentOperationCount:(int)maxConcurrentOperationCount;
{
    self = [super init];
    if (self) {
        [self setName:name];
        [self setMaxConcurrentOperationCount:maxConcurrentOperationCount];
    }
    return self;
}

@end

