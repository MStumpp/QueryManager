//
//  Query.h
//  QueryManager
//
//  Created by Matthias Stumpp on 02.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QueryManager.h"

typedef void(^QueryCompletionHandler)(NSString *state, id data, NSError *error);

@class Queue;

@interface Query : NSOperation
+(Query*)instanceWithQueue:(Queue*)queue;
-(Query*)execute:(id)data onCompletion:(QueryCompletionHandler)handler;
-(Query*)execute:(id)data withPrio:(NSInteger)p onCompletion:(QueryCompletionHandler)handler;
-(void)loaded;
-(void)setData:(id)data;
-(void)setError:(NSError*)error;
-(id)data;
-(NSError*)error;
@end