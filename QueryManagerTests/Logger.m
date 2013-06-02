//
//  Logger.m
//  QueryManager
//
//  Created by Matthias Stumpp on 03.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import "Logger.h"

@interface Logger()
@property (nonatomic, copy) LoggerCallback callback;
@property int target;
@property int currentTarget;
@property (nonatomic, retain) NSMutableString *resultString;
@end

@implementation Logger

static Logger *classInstance = nil;

+(Logger*)instance
{
    if (classInstance == nil) {
        classInstance = [[super allocWithZone:NULL] init];
        classInstance.currentTarget = 0;
        classInstance.resultString = [[NSMutableString alloc] init];
    }
    return classInstance;
}

-(void)registerCallback:(LoggerCallback)callback withTarget:(int)target
{
    self.callback = callback;
    self.target = target;
    
    // some resetting
    self.currentTarget = 0;
    self.resultString = [[NSMutableString alloc] init];
}

-(void)addString:(NSString*)string finished:(BOOL)finished
{
    if (finished)
        self.currentTarget++;
    
    [self.resultString appendString:string];
    
    if (self.currentTarget == self.target)
        self.callback(self.resultString);
    else
        [self.resultString appendString:@" "];
}

@end
