//
//  Queue.h
//  QueryManager
//
//  Created by Matthias Stumpp on 02.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Queue : NSOperationQueue
-(Queue*)initWithName:(id)name;
-(Queue*)initWithName:(id)name maxConcurrentOperationCount:(int)maxConcurrentOperationCount;
@end
