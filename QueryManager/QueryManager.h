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
#import "QueryTicket.h"

// actions
#define tLoad 1
#define tPause 2
#define tCancel 3

// states
#define tAny -1
#define tUninitialized 0
#define tUnloaded 1
#define tLoading 2
#define tLoaded 3
#define tCancelling 4
#define tCancelled 5
#define tPausing 6
#define tPaused 7

// queue config
#define tfifo 1
#define tlifo 2

#define tUnlimitedQueueSize -1
#define tUnlimitedConcurrentConnections -1

#define tAll 1
#define tOne 2

@class Query;
@class Queue;
@class QueryTicket;

@interface QueryManager : NSObject

+(QueryManager*)instance;

-(Queue*)addQueue:(Queue*)queue prio:(uint)prio;
-(QueryTicket*)process:(Query*)query prio:(uint)prio queue:(Queue*)queue;

-(void)stateChangeFrom:(int)from to:(int)to forQuery:(Query*)query;
-(void)prioChangeFrom:(int)from to:(int)to forQuery:(Query*)query;

@property (nonatomic) int maxConcurrentConnections;
@property (nonatomic) BOOL finishHigherPrioFirst;
@property (nonatomic) BOOL pauseWhileLoading;

@end
