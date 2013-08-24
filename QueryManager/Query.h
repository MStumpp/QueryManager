//
//  Query.h
//  QueryManager
//
//  Created by Matthias Stumpp on 02.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QueryManager.h"

@class Queue;
@class Query;

typedef void(^QueryCompletionHandler)(Query *query, id data);

@interface Query : NSOperation
@property (retain) id data;
@property Queue* queue;
@property BOOL someCheckIsTrue;
+(Query*)instanceWithQueue:(Queue*)queue;
-(Query*)execute:(id)data onStateChange:(QueryCompletionHandler)handler;
-(Query*)execute:(id)data withPrio:(NSInteger)p onStateChange:(QueryCompletionHandler)handler;
-(void)loaded;
@end