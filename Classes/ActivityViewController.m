//
//  ActivityViewController.m
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Modified by SVV Satyanarayana, under contract to NSC Partners LLC on 28/04/10.
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Copyright 2026 Island Innovation LLC.  All rights reserved.
//

#import "ActivityViewController.h"
#import "TransitionView.h"
#import <QuartzCore/QuartzCore.h>
#import "ActivityHeaderView.h"
#import "ScoreViewController.h"
#import "KidsTimeFunAppState.h"
#import "ResultViewController.h"
#import "TopScoresSingleDetailViewController.h"

@implementation ActivityViewController

@synthesize activity;
@synthesize activityType;
@synthesize activityLevel;
@synthesize maxQuestions;
@synthesize maxSeconds;
@synthesize currentQuestion;
@synthesize elapsedSeconds;
@synthesize questionsAsked;
@synthesize questionsAttempted;
@synthesize rightAnswers;
@synthesize wrongAnswers;
@synthesize secondsTaken;
@synthesize percentScore;
@synthesize activityState;
@synthesize transView;
@synthesize composite;
@synthesize header;
@synthesize content;
@synthesize activityBG;
@synthesize startTime;
@synthesize endTime;

@synthesize etvc;
@synthesize stvc;
@synthesize ttvc;
//@synthesize resultVC;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//	nibNameOrNil = kNibActivity;
//	nibBundleOrNil = nil;
//    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
//    }
//    return self;
//}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//start clock
	self.startTime = [NSDate date];
	//Custom Back Button - home button
	UIBarButtonItem *homeBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kImgHome] style:UIBarButtonItemStyleBordered target:self action:@selector(goHome:)];
	self.navigationItem.backBarButtonItem = homeBarButton;
	[homeBarButton release];	
	[super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
	self.activity = [KidsTimeFunAppState sharedState].activity;
	self.activityType = [KidsTimeFunAppState sharedState].activityType;
	self.activityLevel = [KidsTimeFunAppState sharedState].activityLevel;
	
	//limits
	maxQuestions = [KidsTimeFunAppState sharedState].maxQuestions;
	maxSeconds = [KidsTimeFunAppState sharedState].maxTimeInSeconds;
	//initialize activity progress variables
	currentQuestion = 1;
	elapsedSeconds = 0;
	questionsAsked = 1;
	questionsAttempted = 0;
	rightAnswers = 0;
	wrongAnswers = 0;
	secondsTaken = 0;
	//Set timer
	if ([KidsTimeFunAppState sharedState].activityType == kActTypeTimed) {
		header.countdownTimer = [KidsTimeFunAppState sharedState].maxTimeInSeconds;
		timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:NULL repeats:YES];
		[header setNeedsDisplay];
	}
	//Load activity
	header.right = rightAnswers;
	header.wrong = wrongAnswers;
	header.current = currentQuestion;
	header.total = maxQuestions;
	header.showTimer = ([KidsTimeFunAppState sharedState].activityType == kActTypeTimed);
	header.activityLevel = self.activityLevel;
	header.showTotal = YES;
    [header setNeedsDisplay];
	[self loadActivity:self.activity];
	[super viewWillAppear:animated];
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

- (void) viewWillDisappear:(BOOL)animated {
	if ([KidsTimeFunAppState sharedState].activityType == kActTypeTimed) {
		[timer invalidate];
		timer = nil;
	}
	NSArray* subViews = [content subviews];
	for (UIView* tempview in subViews) {
		[tempview removeFromSuperview];
	}
	[super viewWillDisappear:YES];
}

- (void)dealloc {
	[transView release];
	[composite release];
	[header release];
	[content release];
	[activityBG release];
	[startTime release];
	[endTime release];
	[super dealloc];
}

#pragma mark -
#pragma mark Custom Actions

- (void) loadActivity: (int)thisActivity {
	switch (thisActivity) {
		case kActTellTime:
			[self.activityBG setImage:[UIImage imageNamed:kBGTellTime]];
			TellTimeViewController *tellTimeViewVC = nil;
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
			{
				tellTimeViewVC = [[TellTimeViewController alloc] initWithNibName:kiPadNibTellTime bundle:nil];
			}
			else 
			{
				tellTimeViewVC = [[TellTimeViewController alloc] initWithNibName:kNibTellTime bundle:nil];	
			}

			tellTimeViewVC.activity = thisActivity;
			tellTimeViewVC.activityType = self.activityType;
			tellTimeViewVC.activityLevel = self.activityLevel;
			tellTimeViewVC.timeOffset = 0; //no offset
			[tellTimeViewVC setDelegate:self];
			[self.navigationItem setTitle:kStrTellTime];
			self.ttvc = tellTimeViewVC;
			[tellTimeViewVC release];
			[content addSubview:[self.ttvc view]];
			//[tellTimeViewVC release];
			break;
		case kActSetTime:
			[self.activityBG setImage:[UIImage imageNamed:kBGSetTime]];
			//change it to set time when ready
			SetTimeViewController *setTimeVC = nil;

			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			{
				setTimeVC = [[SetTimeViewController alloc] initWithNibName:kiPadNibSetTime bundle:nil];	
			}
			else {
				setTimeVC = [[SetTimeViewController alloc] initWithNibName:kNibSetTime bundle:nil];	
			}

			setTimeVC.activity = thisActivity;
			setTimeVC.activityType = self.activityType;
			setTimeVC.activityLevel = self.activityLevel;
			setTimeVC.timeOffset = 0; //no offset
			[setTimeVC setDelegate:self];
			[self.navigationItem setTitle:kStrSetTime];
			
			self.stvc = setTimeVC;
			[content addSubview:[self.stvc view]];
			[setTimeVC release];
			break;
		case kActTimeBefore:
			[self.activityBG setImage:[UIImage imageNamed:kBGTimeBefore]];
			TellTimeViewController *timeBeforeVC = nil;
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
			{
				timeBeforeVC = [[TellTimeViewController alloc] initWithNibName:kiPadNibTellTime bundle:nil];
			}
			else 
			{
				timeBeforeVC = [[TellTimeViewController alloc] initWithNibName:kNibTellTime bundle:nil];	
			}
			
			timeBeforeVC.activity = thisActivity;
			timeBeforeVC.activityType = self.activityType;
			timeBeforeVC.activityLevel = self.activityLevel;
			timeBeforeVC.timeOffset = -1; //negative offset
			[timeBeforeVC setDelegate:self];
			//provide time offset code here
			[self.navigationItem setTitle:kStrTimeBefore];
			self.ttvc = timeBeforeVC;
			[content addSubview:[self.ttvc view]];
			[timeBeforeVC release];
			break;
		case kActTimeAfter:
			[self.activityBG setImage:[UIImage imageNamed:kBGTimeAfter]];
			TellTimeViewController *timeAfterVC = nil;
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
			{
				timeAfterVC = [[TellTimeViewController alloc] initWithNibName:kiPadNibTellTime bundle:nil];
			}
			else 
			{
				timeAfterVC = [[TellTimeViewController alloc] initWithNibName:kNibTellTime bundle:nil];	
			}
			
			timeAfterVC.activity = thisActivity;
			timeAfterVC.activityType = self.activityType;
			timeAfterVC.activityLevel = self.activityLevel;
			timeAfterVC.timeOffset = 1; //positive offset
			[timeAfterVC setDelegate:self];
			//provide time offset code here
			[self.navigationItem setTitle:kStrTimeAfter];
			self.ttvc = timeAfterVC;
			[content addSubview:[self.ttvc view]];
			[timeAfterVC release];
			break;
		case kActElapsedTime:
			[self.activityBG setImage:[UIImage imageNamed:kBGElapsedTime]];
			ElapsedTimeViewController *elapsedTimeVC = nil;
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
			{
				elapsedTimeVC = [[ElapsedTimeViewController alloc] initWithNibName:kiPadNibElapsedTime bundle:nil];
			}
			else 
			{
				elapsedTimeVC = [[ElapsedTimeViewController alloc] initWithNibName:kNibElapsedTime bundle:nil];	
			}

			
			elapsedTimeVC.activity = thisActivity;
			elapsedTimeVC.activityType = self.activityType;
			elapsedTimeVC.activityLevel = self.activityLevel;
			elapsedTimeVC.timeOffset = 1; //positive offset
			[elapsedTimeVC setDelegate:self];
			[self.navigationItem setTitle:kStrElapsedTime];
			self.etvc = elapsedTimeVC;
			[content addSubview:[self.etvc view]];
			[elapsedTimeVC release];
			break;
		case kActMixed:
            
			[self.activityBG setImage:[UIImage imageNamed:kBGMixed]];

            int r = arc4random() % 5;
			[self loadActivity:r];
			break;
		default:
			break;
	}
	[transView addSubview:composite];	
}

- (void) loadNextActivity: (id) sender {
	//load activity progress variables
	++currentQuestion;
	if ([sender isRight]) ++rightAnswers;
	else ++wrongAnswers;
	//Load activity
	header.right = rightAnswers;
	header.wrong = wrongAnswers;
	header.current = currentQuestion;
	header.total = maxQuestions;
	//header.showTimer = NO;
	header.showTotal = YES;
	[header setNeedsDisplay];
	//Update app state
	[KidsTimeFunAppState sharedState].questionNumber = currentQuestion;
	[KidsTimeFunAppState sharedState].questionsRight = rightAnswers;
	[KidsTimeFunAppState sharedState].questionsWrong = wrongAnswers;
	if ((([KidsTimeFunAppState sharedState].activityType == kActTypeNumbered) && (currentQuestion <= maxQuestions)) ||
		(([KidsTimeFunAppState sharedState].activityType == kActTypeTimed) && (secondsTaken <= maxSeconds))) 
	{
		//Load Next Activity
		++questionsAsked;
		++questionsAttempted;
		//remove content's old subview
		[[[content subviews] objectAtIndex:0] removeFromSuperview];
		//load activity view controller
		
		if(self.activity == kActMixed)
		{
			int r = arc4random() % 5;
			[self loadActivity:r];
		}
		else
		{
		
			[self loadActivity:self.activity];
		}
		[composite layoutIfNeeded];
		[transView replaceSubview:[[transView subviews] objectAtIndex:1] withSubview:composite transition:kCATransitionPush direction:kCATransitionFromRight duration:0.25];
	}
	else {
		//Load Record Score
		[self loadResultsView:self];		
	}
}

- (void) loadResultsView: (id)sender {
	if ([KidsTimeFunAppState sharedState].activityType == kActTypeTimed) {
		[timer invalidate];
		timer = nil;
	}
	self.endTime = [NSDate date];
	self.title = kStrResult;
	ResultViewController *resultVC;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        resultVC = [[ResultViewController alloc] initWithNibName:kiPadNibResult bundle:nil];
    }
    else
    {
        resultVC = [[ResultViewController alloc] initWithNibName:kNibResult bundle:nil];
    }
	resultVC.rightAnswers = self.rightAnswers;
	resultVC.wrongAnswers = self.wrongAnswers;
	resultVC.totalQuestions = self.rightAnswers+self.wrongAnswers;
	resultVC.percentScore = (float) self.rightAnswers / (float) (self.rightAnswers+self.wrongAnswers);
	if (self.activityType == kActTypeTimed) resultVC.timeTakenInSeconds = self.maxSeconds;
	else resultVC.timeTakenInSeconds = [endTime timeIntervalSinceDate:startTime];
	//[resultVC setDelegate:self];
	//[transView replaceSubview:[[transView subviews] objectAtIndex:1] withSubview:resultVC.view transition:kCATransitionPush direction:kCATransitionFromRight duration:0.25];
	[self.navigationController pushViewController:resultVC animated:YES];
	[resultVC release];
}

- (void) loadTopScoresView: (id)sender {
	TopScoresSingleDetailViewController *topScoresDtVC = [[TopScoresSingleDetailViewController alloc] initWithActivity:self.activity andType:self.activityType andLevel:self.activityLevel withNibName:@"TopScoresSingleDetailView" bundle:nil];
	self.title = kStrTopScores;
	UIBarButtonItem *homeBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TopScores20.png"] style:UIBarButtonItemStyleBordered target:self action:nil];
	self.navigationItem.backBarButtonItem = homeBarButton;
	[homeBarButton release];
	[self.navigationController pushViewController:topScoresDtVC animated:YES];
	[topScoresDtVC release];
}

- (void) countDown {
	if ([KidsTimeFunAppState sharedState].activityType == kActTypeTimed) {
		//if countdown to zero, and activity view on top and not transitioning
		if ((header.countdownTimer <= 0) && ((self.navigationController.topViewController == self)||(![transView isTransitioning]))) {
			[timer invalidate];
			timer = nil;
			UIAlertView *timeIsUp = [[UIAlertView alloc] initWithTitle:@"Time is up!" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[timeIsUp show];
			[timeIsUp release];
			//show score recorder
			if (self.navigationController.topViewController == self) [self loadResultsView:self];
		}
		else {
			--header.countdownTimer;
			[header setNeedsDisplay];
		}
	}
}

#pragma mark -
#pragma mark DismissResultDelegate

- (void) didDismissResult: (id) sender {
	if (self.navigationController.topViewController == self) [self loadTopScoresView:sender];
}

#pragma mark -
#pragma mark DismissActivityDelegate

- (void)didDismissActivity: (id) sender {
	if (self.navigationController.topViewController == self) [self loadNextActivity:sender];
}

@end
