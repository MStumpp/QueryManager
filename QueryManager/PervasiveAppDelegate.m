//
//  PervasiveAppDelegate.m
//  QueryManager
//
//  Created by Matthias Stumpp on 02.02.13.
//  Copyright (c) 2013 Pervasive. All rights reserved.
//

#import "PervasiveAppDelegate.h"
#import "QueryManager.h"
#import "QueryConcrete.h"
#import "Logger.h"

@class QueryManager;
@class QueryTicket;
@class Queue;
@class Logger;

@implementation PervasiveAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    /*QueryManager *manager = [QueryManager instance];
    
    Queue *queue1 = [[Queue alloc] initWithIdentifier:@"queue 1" queueMaxSize:tUnlimitedQueueSize numberMaxConcurrent:tUnlimitedConcurrentConnections processOrder:tfifo finishHigherPrioFirst:TRUE pauseWhileLoading:TRUE cancelWhileLoading:TRUE];
    
    Queue *queue2 = [[Queue alloc] initWithIdentifier:@"queue 2" queueMaxSize:tUnlimitedQueueSize numberMaxConcurrent:tUnlimitedConcurrentConnections processOrder:tfifo finishHigherPrioFirst:TRUE pauseWhileLoading:TRUE cancelWhileLoading:TRUE];
    
    [manager addQueue:queue1 prio:0];
    //[manager addQueue:queue2 prio:0];
    
    Logger *logger = [Logger instance];
    [logger registerCallback:^(NSString *string) {
        NSLog(@"%@", string);
    } withTarget:2];
    
    Query *query1 = [[QueryConcrete alloc] initWithDelay:2.0 withIdentifier:@"1" andLogger:logger];
    Query *query2 = [[QueryConcrete alloc] initWithDelay:3.0 withIdentifier:@"2" andLogger:logger];
    //Query *query3 = [[QueryConcrete alloc] initWithDelay:5.0 withIdentifier:@"3"];
    
    QueryTicket *ticket1 = [manager process:query1 prio:1 queue:queue1];
    NSLog(@"--------");
    QueryTicket *ticket2 = [manager process:query2 prio:0 queue:queue1];
    //QueryTicket *ticket3 = [manager process:query3 prio:0 queue:queue1];*/
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
