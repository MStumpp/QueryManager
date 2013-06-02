//
//  Query.h
//  QueryManager
//
//  Created by Matthias Stumpp on 02.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QueryManager.h"

typedef void(^QueryCompletionHandler)(int state, id data, NSError *error);

@class Queue;
@class QueryTicket;

@interface Query : NSObject

@property (nonatomic, assign) Queue* queue;
@property (nonatomic, assign) int prio;
@property (nonatomic, assign) int state;
@property (nonatomic, assign) id data;
@property (nonatomic, assign) QueryCompletionHandler handler;

+(Query*)instanceWithQueue:(Queue*)queue;
-(QueryTicket*) process:(id)data onCompletion:(QueryCompletionHandler)handler;

-(BOOL)inState:(int)state;
-(BOOL)toState:(int)state;
-(BOOL)inState:(int)from toState:(int)to;
-(BOOL)do:(uint)action;

-(BOOL)inPrio:(uint)p;
-(void)toPrio:(uint)p;

-(void)load:(id)data;
-(void)pause:(id)data;
-(void)cancel:(id)data;

-(void)loadedWithData:(id)entry andError:(NSError*)error;
-(void)pausedWithData:(id)entry andError:(NSError*)error;
-(void)cancelledWithData:(id)entry andError:(NSError*)error;

@end
