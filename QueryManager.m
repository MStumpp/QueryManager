//
//  QueryManager.m
//  QueryManager
//
//  Created by Matthias Stumpp on 02.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import "QueryManager.h"

@interface QueryManager()
@property Queue *queue;
@end

@implementation QueryManager

static QueryManager *classInstance = nil;

+(QueryManager*)instance
{
    if (classInstance == nil) {
        classInstance = [[super allocWithZone:nil] init];
    }
    return classInstance;
}

-(Queue*)createQueueWithName:(NSString*)name
{
    return self.queue = [[Queue alloc] initWithName:name];
}

-(Queue*)queueWithName:(NSString*)name
{
    return self.queue;
}

@end

