//
//  QueryTicket.m
//  QueryManager
//
//  Created by Matthias Stumpp on 02.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import "QueryTicket.h"

@implementation QueryTicket

-(QueryTicket*)initWithQuery:(Query*)query
{
    self = [super init];
    if (self) {
        self.query = query;
    }
    return self;
}

-(int)state
{
    return [self.query state];
}

-(BOOL)toState:(int)state
{
    return [self.query toState:state];
}

-(int)prio
{
    return [self.query prio];
}

-(BOOL)inPrio:(uint)p
{
    return [self.query inPrio:p];
}

-(BOOL)inState:(int)state
{
    return [self.query inState:state];
}

-(void)toPrio:(uint)p
{
    [self.query toPrio:p];
}

-(QueryTicket*)cancel
{
    [self.query toState:tCancelled];
    return self;
}

@end
