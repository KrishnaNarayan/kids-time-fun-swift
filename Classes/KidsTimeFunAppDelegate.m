//
//  KidsTimeFunAppDelegate.m
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Copyright 2026 Island Innovation LLC.  All rights reserved.
//

#import "KidsTimeFunAppDelegate.h"
#import "MenuViewController.h"
#import "KidsTimeFunAppState.h"
#import <FloopSDK/FloopSDK.h>

@implementation KidsTimeFunAppDelegate
@synthesize window;
@synthesize navController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	
	//Initialize State
	[KidsTimeFunAppState sharedState];
	[[KidsTimeFunAppState sharedState] resumeFromState];
	
	//Set Application Defaults
	[self setApplicationAppearanceDefaults];
	
	//Show UI
	window.rootViewController = navController;
	[window makeKeyAndVisible];
}

- (void)applicationDidFinishLaunchingWithOptions{
	[[FloopSdkManager sharedInstance] startWithAppKey:@"a5b62509cce25acc5e397714d7c63981"]; //kn add floop for parental gate
}


- (void)applicationWillTerminate:(UIApplication *)application {
	//store state
	[[KidsTimeFunAppState sharedState] flushState];
}


- (void)setApplicationAppearanceDefaults {
	//Navigation Bar - Clear Color
	UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
	navigationBarAppearance.backgroundColor = [UIColor clearColor];
	[navigationBarAppearance setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
	navigationBarAppearance.shadowImage = [[UIImage alloc] init];
	//Navigation Bar - Tint Color
	navigationBarAppearance.tintColor = [UIColor colorWithRed:0.055 green:0.478 blue:0.996 alpha:1.000];
	//Navigation Bar - Purple Font
	NSShadow *shadow = [[NSShadow alloc] init];
	shadow.shadowColor = [UIColor clearColor];
	shadow.shadowBlurRadius = 0.0;
	shadow.shadowOffset = CGSizeMake(0.0, 0.0);
	[[UINavigationBar appearance] setTitleTextAttributes: @{
															NSForegroundColorAttributeName : [UIColor colorWithRed:0.055 green:0.478 blue:0.996 alpha:1.000],
															NSShadowAttributeName : shadow
															}];
	[shadow release];
	
}

- (void)dealloc {
	[navController release];
	[window release];
	[super dealloc];
}



@end
