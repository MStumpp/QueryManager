//
//  QueryManagerTests.m
//  QueryManagerTests
//
//  Created by Matthias Stumpp on 02.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import "QueryManagerTests.h"
#import "Logger.h"

@interface QueryManagerTests()
@property (nonatomic, retain) Logger *logger;
@end

@implementation QueryManagerTests

- (void)setUp
{
    [super setUp];
    self.logger = [Logger instance];
}

- (void)tearDown
{
    // Tear-down code here.
    self.logger = nil;
    [super tearDown];
}

// 1 queue, prio 0
// 2 queries, prio 0
// expect: processed in order as added

- (void)testExample
{
    __block NSString *string = nil;
    
    QueryManager *manager = [QueryManager instance];
    Queue *queue1 = [[Queue alloc] initWithIdentifier:@"queue 1" queueMaxSize:tUnlimitedQueueSize numberMaxConcurrent:tUnlimitedConcurrentConnections processOrder:tfifo finishHigherPrioFirst:TRUE pauseWhileLoading:TRUE cancelWhileLoading:TRUE];
        
    [manager addQueue:queue1 prio:0];
    
    [self.logger registerCallback:^(NSString *str) {
        string = str;
    } withTarget:2];
    
    Query *query1 = [[QueryConcrete alloc] initWithDelay:1.0 withIdentifier:@"1" andLogger:self.logger];
    Query *query2 = [[QueryConcrete alloc] initWithDelay:1.0 withIdentifier:@"2" andLogger:self.logger];
    
    [manager process:query1 prio:0 queue:queue1];
    [manager process:query2 prio:0 queue:queue1];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:10];
    while (!string && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    if (string) {
        STAssertEqualObjects(string, @"q1:loading q2:loading q1:loaded q2:loaded", nil);
    } else {
        STFail(@"no callback received");
    }
}

// 2 queues, prio 0 and 1
// 2 queries, prio 0
// 1. query added to queue prio 1 before 2. query added to queue prio 0
// expect: 1. query paused while loading, 2. query loaded first, then 1. query loaded

- (void)testExample2
{
    __block NSString *string = nil;
    
    QueryManager *manager = [QueryManager instance];
    Queue *queue1 = [[Queue alloc] initWithIdentifier:@"queue 1" queueMaxSize:tUnlimitedQueueSize numberMaxConcurrent:tUnlimitedConcurrentConnections processOrder:tfifo finishHigherPrioFirst:TRUE pauseWhileLoading:TRUE cancelWhileLoading:TRUE];
    
    Queue *queue2 = [[Queue alloc] initWithIdentifier:@"queue 2" queueMaxSize:tUnlimitedQueueSize numberMaxConcurrent:tUnlimitedConcurrentConnections processOrder:tfifo finishHigherPrioFirst:TRUE pauseWhileLoading:TRUE cancelWhileLoading:TRUE];
    
    [manager addQueue:queue1 prio:0];
    [manager addQueue:queue2 prio:1];
    
    [self.logger registerCallback:^(NSString *str) {
        string = str;
    } withTarget:2];
    
    Query *query1 = [[QueryConcrete alloc] initWithDelay:1.0 withIdentifier:@"1" andLogger:self.logger];
    Query *query2 = [[QueryConcrete alloc] initWithDelay:1.0 withIdentifier:@"2" andLogger:self.logger];
    
    [manager process:query1 prio:0 queue:queue2];
    [manager process:query2 prio:0 queue:queue1];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:10];
    while (!string && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    if (string) {
        STAssertEqualObjects(string, @"q1:loading q1:paused q2:loading q2:loaded q1:loading q1:loaded", nil);
    } else {
        STFail(@"no callback received");
    }
}

// 1 queue, prio 0
// 2 queries, prio 0 and 1
// 1. query prio 1 added to queue before 2. query prio 0 added to queue
// expect: 1. query paused while loading, 2. query loaded first, then 1. query loaded

- (void)testExample3
{
    __block NSString *string = nil;
    
    QueryManager *manager = [QueryManager instance];
    Queue *queue1 = [[Queue alloc] initWithIdentifier:@"queue 1" queueMaxSize:tUnlimitedQueueSize numberMaxConcurrent:tUnlimitedConcurrentConnections processOrder:tfifo finishHigherPrioFirst:TRUE pauseWhileLoading:TRUE cancelWhileLoading:TRUE];
    
    [manager addQueue:queue1 prio:0];
    
    [self.logger registerCallback:^(NSString *str) {
        string = str;
    } withTarget:2];
    
    Query *query1 = [[QueryConcrete alloc] initWithDelay:1.0 withIdentifier:@"1" andLogger:self.logger];
    Query *query2 = [[QueryConcrete alloc] initWithDelay:1.0 withIdentifier:@"2" andLogger:self.logger];
    
    [manager process:query1 prio:1 queue:queue1];
    [manager process:query2 prio:0 queue:queue1];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:10];
    while (!string && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    if (string) {
        STAssertEqualObjects(string, @"q1:loading q1:paused q2:loading q2:loaded q1:loading q1:loaded", nil);
    } else {
        STFail(@"no callback received");
    }
}

@end
