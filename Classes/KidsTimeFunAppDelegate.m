//
//  KidsTimeFunAppDelegate.m
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. All rights reserved.
//

#import "KidsTimeFunAppDelegate.h"
#import "MenuViewController.h"
#import "KidsTimeFunAppState.h"

@implementation KidsTimeFunAppDelegate
@synthesize window;
@synthesize navController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	//Initialize State
	[KidsTimeFunAppState sharedState];
	[[KidsTimeFunAppState sharedState] resumeFromState];
	//Initialize Menu View Controller
	//Create navigation controller with menu at its root and set its style
	//navController = [[UINavigationController alloc] initWithRootViewController:menuViewController];
	navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    //Add navController to window and show window
//	[window addSubview:navController.view];
	window.rootViewController = navController;
	[window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	//store state
	[[KidsTimeFunAppState sharedState] flushState];
}

- (void)dealloc {
	[navController release];
    [window release];
    [super dealloc];
}



@end
