//
//  AppDelegate.m
//  SlidingPanels
//
//  Created by John Mcintosh  on 1/30/13.
//  Copyright (c) 2013 John Mcintosh . All rights reserved.
//

#import "AppDelegate.h"

#import "UBSlidingPanelController.h"
#import "LeftVC.h"
#import "RightVC.h"
#import "CenterVC.h"
#import "ScrollVC.h"

#if RUN_KIF_TESTS
#import "SPKIFTestController.h"
#endif


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	self.viewController = [[UBSlidingPanelController alloc] init];
    
    self.viewController.leftPanel = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
//	self.viewController.leftPanel = [[LeftVC alloc] init];
	self.viewController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[CenterVC alloc] init]];
//	self.viewController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[UITableViewController alloc] initWithStyle:UITableViewStylePlain]];
//	self.viewController.centerPanel = [[ScrollVC alloc] init];
	self.viewController.rightPanel = [[RightVC alloc] init];
	   
	self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
#if RUN_KIF_TESTS
    [[SPKIFTestController sharedInstance] startTestingWithCompletionBlock:^{
        // Exit after the tests complete so that CI knows we're done
        exit([[SPKIFTestController sharedInstance] failureCount]);
    }];
#endif
    
    return YES;
}


@end
