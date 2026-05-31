//
//  TopScoresDetailViewController.m
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

#import "TopScoresDetailViewController.h"
#import "KidsTimeFunAppState.h"
#import "TopScoresSingleDetailViewController.h"

@implementation TopScoresDetailViewController

@synthesize activity;
@synthesize activityType;
@synthesize activityLevel;
@synthesize showActivityTypeSelection;

- (id) initWithActivity: (int)act andType: (int)actType andLevel: (int)actLevel showActivityTypeSelection: (BOOL)showActTypeSelection withNibName: (NSString *)nibNameOrNil andBundle: (NSBundle *)nibBundleOrNil {
	self.activity = act;
	self.activityType = actType;
	self.activityLevel = actLevel;
	self.showActivityTypeSelection = showActTypeSelection;
	return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    NSString *activityName;
    NSString *activityLevelName;
    switch (self.activity) {
        case kActTellTime:
            activityName = kStrTellTime;
            break;
        case kActElapsedTime:
            activityName = kStrElapsedTime;
            break;
        case kActTimeAfter:
            activityName = kStrTimeAfter;
            break;
        case kActTimeBefore:
            activityName = kStrTimeBefore;
            break;
        case kActSetTime:
            activityName = kStrSetTime;
            break;
        case kActMixed:
            activityName = kStrMixed;
            break;
        default:
            activityName = @"";
            break;
    }
    switch (self.activityLevel) {
        case kActLevelYellowBelt:
            activityLevelName = @"Yellow Belt";
            break;
        case kActLevelGreenBelt:
            activityLevelName = @"Green Belt";
            break;
        case kActLevelRedBelt:
            activityLevelName = @"Red Belt";
            break;
        case kActLevelBlackBelt:
            activityLevelName = @"Black Belt";
            break;
        default:
            activityLevelName = @"";
            break;
    }

	self.title = [NSString stringWithFormat:@"%@ - %@", activityName, activityLevelName];
	UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Top Score"] style:UIBarButtonItemStyleBordered target:self action:nil];
	self.navigationItem.backBarButtonItem = backBarButton;
	//create two views - one for numbered, one for timed quiz
    NSString *nibName;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		nibName = @"TopScoresSingleDetailView-iPad";
	}
	else
	{
        nibName = @"TopScoresSingleDetailView";
	}
	TopScoresSingleDetailViewController *numberedVC = [[TopScoresSingleDetailViewController alloc] initWithActivity:self.activity andType:kActTypeNumbered andLevel:self.activityLevel withNibName:nibName bundle:nil];
	TopScoresSingleDetailViewController *timedVC = [[TopScoresSingleDetailViewController alloc] initWithActivity:self.activity andType:kActTypeTimed andLevel:self.activityLevel withNibName:nibName bundle:nil];
	numberedVC.title = @"Numbered";
	timedVC.title = @"Timed";
	//setup tab bar
	if (self.showActivityTypeSelection) {
		UITabBarItem *numberedTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Numbered" image:[UIImage imageNamed:@"Numbered.png"] tag:kActTypeNumbered];
		numberedVC.tabBarItem = numberedTabBarItem;
		UITabBarItem *timedTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Timed" image:[UIImage imageNamed:@"Timed.png"] tag:kActTypeTimed];
		timedVC.tabBarItem = timedTabBarItem;
		[numberedTabBarItem release];
		[timedTabBarItem release];
	}
	//create array of view controllers
	NSArray *viewControllersArray = [[NSArray alloc] initWithObjects:numberedVC,timedVC,nil];
	self.viewControllers = viewControllersArray;
	[numberedVC release];
	[timedVC release];
	[viewControllersArray release];
	[backBarButton release];
	[super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
