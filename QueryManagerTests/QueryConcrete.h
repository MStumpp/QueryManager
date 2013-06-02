//
//  QueryConcrete.h
//  QueryManager
//
//  Created by Matthias Stumpp on 02.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import "Query.h"
#import "QueryManager.h"
#import "Logger.h"

@class Logger;

@interface QueryConcrete : Query

-(QueryConcrete*)initWithDelay:(NSTimeInterval)delay withIdentifier:(id)identifier andLogger:(Logger*)logger;

@property id identifier;

@end