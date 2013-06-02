//
//  Queue.h
//  QueryManager
//
//  Created by Matthias Stumpp on 02.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QueryManager.h"

@class QueryManager;
@class Query;
@class QueryTicket;

@interface Queue : NSObject

-(Queue*)initWithIdentifier:(id)identifier queueMaxSize:(int)queueMaxSize numberMaxConcurrent:(int)numberMaxConcurrent processOrder:(int)processOrder finishHigherPrioFirst:(BOOL)finishHigherPrioFirst pauseWhileLoading:(BOOL)pauseWhileLoading cancelWhileLoading:(BOOL)cancelWhileLoading;

@property (nonatomic, assign) id identifier;
@property (nonatomic, assign) QueryManager *queryManager;
@property int prio;

-(QueryTicket*)addQuery:(Query*)query;

// initiates processing of the number of queries
-(int)process:(uint)numberToProcess;
-(BOOL)hasQueriesInQueue;

-(int)setQueries:(int)number inState:(int)from toState:(int)to andSmallerPrio:(uint)prio includePrio:(BOOL)includePrio excludeQuery:(Query*)excludeQuery;

-(BOOL)inPrio:(uint)p;
-(void)toPrio:(uint)p;

-(void)stateChangeFrom:(int)from to:(int)to forQuery:(Query*)query;
-(void)prioChangeFrom:(int)from to:(int)to forQuery:(Query*)query;

@end
