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

typedef void(^QueryCompletionHandler)(NSString *state, id result, NSError *error, id context);

@interface Query : NSOperation
@property (retain) id props;
@property Queue* queue;
@property BOOL someCheckIsTrue;
@property id result;
@property NSError *error;
+(Query*)instanceWithQueue:(Queue*)queue;
-(Query*)execute:(id)props context:(id)context onStateChange:(QueryCompletionHandler)handler;
-(Query*)execute:(id)props context:(id)context withPrio:(NSInteger)p onStateChange:(QueryCompletionHandler)handler;
-(void)loaded;
@end