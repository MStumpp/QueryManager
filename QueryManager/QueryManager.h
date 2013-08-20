//
//  QueryManager.h
//  QueryManager
//
//  Created by Matthias Stumpp on 02.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Query.h"
#import "Queue.h"

// states
#define tReady @"isReady"
#define tExecuting @"isExecuting"
#define tCancelled @"isCancelled"
#define tFinished @"isFinished"

@class Query;
@class Queue;

@interface QueryManager : NSObject

+(QueryManager*)instance;
-(Queue*)createQueueWithName:(NSString*)name;
-(Queue*)queueWithName:(NSString*)name;

@end
