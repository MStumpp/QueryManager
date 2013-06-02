//
//  QueryTicket.h
//  QueryManager
//
//  Created by Matthias Stumpp on 02.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QueryManager.h"

@class QueryTicket;
@class Query;

@interface QueryTicket : NSObject

@property (nonatomic, retain) Query *query;

-(QueryTicket*)initWithQuery:(Query*)query;

-(int)state;
-(BOOL)inState:(int)state;
-(BOOL)toState:(int)state;
-(QueryTicket*)cancel;

-(int)prio;
-(BOOL)inPrio:(uint)prio;
-(void)toPrio:(uint)prio;

@end
