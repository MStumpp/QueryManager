//
//  Logger.h
//  QueryManager
//
//  Created by Matthias Stumpp on 03.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QueryConcrete.h"

@class QueryConcrete;

typedef void(^LoggerCallback)(NSString *string);

@interface Logger : NSObject

+(Logger*)instance;
-(void)registerCallback:(LoggerCallback)callback withTarget:(int)target;
-(void)addString:(NSString*)string finished:(BOOL)finished;

@end
