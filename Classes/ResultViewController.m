//
//  ResultViewController.m
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
//

#import "ResultViewController.h"
#import "ScoreCard.h"
#import "TopScoresDetailViewController.h"

@implementation ResultViewController
@synthesize scoreRank;
@synthesize rightAnswers;
@synthesize wrongAnswers;
@synthesize totalQuestions;
@synthesize percentScore;
@synthesize timeTakenInSeconds;
@synthesize delegate;

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


-(void)goHome:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    self.title = kStrResult;
	UIBarButtonItem *homeBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Home.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(goHome:)];
	self.navigationItem.leftBarButtonItem = homeBarButton;
	[homeBarButton release];	
	lblRightAnswers.text = [NSString stringWithFormat:@"%i", self.rightAnswers];
	lblWrongAnswers.text = [NSString stringWithFormat:@"%i", self.wrongAnswers];
	lblTotalQuestions.text = [NSString stringWithFormat:@"%i", self.totalQuestions];
	lblPercentScore.text = [NSString stringWithFormat:@"%1.2f%%", self.percentScore*100.0f];
	lblTimeTaken.text = [NSString stringWithFormat:@"%i seconds", self.timeTakenInSeconds];
	//check for top score
	ScoreCard *yourScoreCard = [[ScoreCard alloc] init];
	yourScoreCard.playerName = [KidsTimeFunAppState sharedState].playerName;
	yourScoreCard.activity = [KidsTimeFunAppState sharedState].activity;
	yourScoreCard.activityType = [KidsTimeFunAppState sharedState].activityType;
	yourScoreCard.activityLevel = [KidsTimeFunAppState sharedState].activityLevel;
	yourScoreCard.questionsAsked = self.totalQuestions;
	yourScoreCard.questionsAttempted = self.totalQuestions;
	yourScoreCard.rightAnswers = self.rightAnswers;
	yourScoreCard.wrongAnswers = self.wrongAnswers;
	yourScoreCard.percentScore = self.percentScore;
	yourScoreCard.secondsTaken = self.timeTakenInSeconds;
	[yourScoreCard newScoreCard];
	if (yourScoreCard.isTopScore) {
		[headerView addSubview:topScoreHeaderView];
		lblScoreRank.text = [NSString stringWithFormat:@"%i", yourScoreCard.scoreRank];
		if ([[KidsTimeFunAppState sharedState].playerName isEqualToString:kDefaultPlayerName])
			txtName.text = kStrBlank;
		else txtName.text = [KidsTimeFunAppState sharedState].playerName;
		txtName.enabled = YES;
		btnSave.enabled = YES;
	}
	else [headerView addSubview:noTopScoreHeaderView];
	[yourScoreCard release];
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
	if (self.delegate != self) delegate = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Custom Actions

- (IBAction) dismissKeyboard {
	if ([txtName.text length] > 0)
		[KidsTimeFunAppState sharedState].playerName = txtName.text;
	[txtName resignFirstResponder];
}

- (IBAction) saveScore {
	[self dismissKeyboard];
	ScoreCard *yourScoreCard = [[ScoreCard alloc] init];
	yourScoreCard.playerName = [KidsTimeFunAppState sharedState].playerName;
	yourScoreCard.activity = [KidsTimeFunAppState sharedState].activity;
	yourScoreCard.activityType = [KidsTimeFunAppState sharedState].activityType;
	yourScoreCard.activityLevel = [KidsTimeFunAppState sharedState].activityLevel;
	yourScoreCard.questionsAsked = self.totalQuestions;
	yourScoreCard.questionsAttempted = self.totalQuestions;
	yourScoreCard.rightAnswers = self.rightAnswers;
	yourScoreCard.wrongAnswers = self.wrongAnswers;
	yourScoreCard.percentScore = self.percentScore;
	yourScoreCard.secondsTaken = self.timeTakenInSeconds;
	[yourScoreCard newScoreCard];
	if (yourScoreCard.isTopScore) {
		if (![yourScoreCard writeScoreCard]) {
			UIAlertView *fileAlert = [[UIAlertView alloc] initWithTitle:@"File Alert!" message:@"Could not write score to the file. Please contact support." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
			[fileAlert show];
			[fileAlert release];
		}
	}
	[yourScoreCard release];
	txtName.enabled = NO;
	btnSave.enabled = NO;
	//[self done];
	NSArray* arr = [self.navigationController viewControllers];
	[self.navigationController popToViewController:[arr objectAtIndex:0] animated:YES];
}

- (IBAction) done {
	//notify delegate to unload view and display Top Scores Scree
	if ([delegate conformsToProtocol:@protocol(DismissResultDelegate)]) [delegate didDismissResult:self];
}

@end
