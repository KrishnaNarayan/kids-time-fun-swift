//
//  HelpViewController.m
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09, 9/6/13
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Modified by SVV Satyanarayana, under contract to NSC Partners LLC on 28/04/10.
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Copyright 2026 Island Innovation LLC.  All rights reserved.
//

#import "HelpViewController.h"
#import "KidsTimeFunAppState.h"

#define APP1 @"287877578" //Kindergarten
#define APP2 @"287880249" //First Grade
#define APP3 @"287882100" //Second Grade
#define APP4 @"287884849" //Third Grade
#define APP5 @"290076686" //Fourth Grade
#define APP6 @"300633885" //Fifth Grade
#define APP7 @"318350766" //Kids Time Fun
#define APP8 @"380632079" //Kids Coin Fun
#define APP9 @"399143221" //Clean Energy   
#define APP10 @"539457137" //Wordplay    
#define APP11 @"524746620" //Nature Maestro
#define APP12 @"524746620" //
#define APP13 @"333391557" //
#define APP14 @"363384622" //
#define APP15 @"354850603" //
#define APP16 @"352590964" //
#define	APP_STORE1 @"http://linktoapp.com/nsc+partners+llc" //All NSC Partner LLC Apps
#define	APP_STORE2 @"http://linktoapp.com/picpocket+books" //All PicPocketBooks Apps

@implementation HelpViewController

/*
@synthesize tellaFriendKButton;
@synthesize tellaFriend1Button;
@synthesize tellaFriend2Button;
@synthesize tellaFriend3Button;
@synthesize tellaFriend4Button;
@synthesize tellaFriendPButton;
*/

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    self.title = kStrHelp;
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

-(IBAction) tellaFriendButtonPressed:(id)sender
{
	UIButton* btn = (UIButton*)sender;
	switch (btn.tag) {
		case 1:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8&uo=6",APP1]]];
			break;
		case 2:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8&uo=6",APP2]]];
			break;
		case 3:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8&uo=6",APP3]]];
			break;
		case 4:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8&uo=6",APP4]]];
			break;
		case 5:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8&uo=6",APP5]]];
			break;
		case 6:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8&uo=6",APP6]]];
			break;
		case 7:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8&uo=6",APP7]]];
			break;
		case 8:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8&uo=6",APP8]]];
			break;
		case 9:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8&uo=6",APP9]]];
			break;
		case 10:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8&uo=6",APP10]]];
			break;
		case 11:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8&uo=6",APP11]]];
			break;
		case 12:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8&uo=6",APP12]]];
			break;
		case 13:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8&uo=6",APP13]]];
			break;
		case 14:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8&uo=6",APP14]]];
			break;
		case 15:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8&uo=6",APP15]]];
			break;
		case 16:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8&uo=6",APP16]]];
			break;
		case 17:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_STORE1]];
			break;
		case 18:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_STORE2]];
			break;
		default:
			break;
	}
}

/*
- (IBAction) tellaFriendKButtonPressed: (id) sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=287877578&mt=8&uo=6"]];
	
}

- (IBAction) tellaFriend1ButtonPressed: (id) sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=287880249&mt=8&uo=6"]];
}

- (IBAction) tellaFriend2ButtonPressed: (id) sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=287882100&mt=8&uo=6"]];
}

- (IBAction) tellaFriend3ButtonPressed: (id) sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=287884849&mt=8&uo=6"]];
}

- (IBAction) tellaFriend4ButtonPressed: (id) sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=290076686&mt=8&uo=6"]];
}

- (IBAction) tellaFriendPButtonPressed: (id) sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=300633885&mt=8&uo=6"]];
}
*/
@end
