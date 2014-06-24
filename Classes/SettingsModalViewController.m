//
//  SettingsModalViewController.m
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. All rights reserved.
//

#import "SettingsModalViewController.h"
#import "KidsTimeFunAppState.h"

#define kMinQuestions 10
#define kMaxQuestions 50
#define kIncrementQuestions 10
#define kMinMinutes 1
#define kMaxMinutes 5
#define kIncrementMinutes 1
#define kStrVarNumberOfQuestions @"Total Questions: %i"
#define kStrVarNumberOfMinutes @"Total Minutes: %i"
#define kStrActTypeYellowBelt @"Yellow Belt"
#define kStrActTypeGreenBelt @"Green Belt"
#define kStrActTypeRedBelt @"Red Belt"
#define kStrActTypeBlackBelt @"Black Belt"
#define kStrYellowBeltDescription @"YELLOW BELT\n2 answer choices\n30 minute time increments\n2 hour max math range"
#define kStrGreenBeltDescription @"GREEN BELT\n3 answer choices\n15 minute time increments\n4 hour max math range"
#define kStrRedBeltDescription @"RED BELT\n4 answer choices\n5 minute time increments\n6 hour max math range"
#define kStrBlackBeltDescription @"BLACK BELT\n4 answer choices\n1 minute time increments\nNo max math range"

@implementation SettingsModalViewController

//@synthesize delegate;
@synthesize isDirty;
@synthesize numberOfQuestions;
@synthesize numberOfMinutes;
@synthesize activityLevel;
@synthesize playSoundInApplication;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = @"Settings";
	//Load current settings and initialize UI to values;
	//Get the file name - root for documents directory
    
    self.navigationItem.hidesBackButton=YES;
    
	NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *fileNameWithPath = [docPath stringByAppendingPathComponent:kFileAppSettings];
	//Now read settings from disk
	isDirty = NO;	//file in sync with the variables, any time any of the above vars change, set this var to YES, at exit if isDirty YES will hydrate/write the file
	NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:fileNameWithPath];
	if ([settingsDict count] == 0) isDirty = YES;  //if file blank or corrupted this will force write defaults
	numberOfQuestions = [[settingsDict valueForKey:kSettingsKeyNumberOfQuestions] intValue];
	numberOfQuestions = (numberOfQuestions == 0)?kDefaultMaxNumberOfQuestions:numberOfQuestions;
	numberOfMinutes = [[settingsDict valueForKey:kSettingsKeyNumberOfMinutes] intValue];
	numberOfMinutes = (numberOfMinutes == 0)?(kDefaultMaxTimeInSeconds/60):numberOfMinutes;
	activityLevel = [[settingsDict valueForKey:kSettingsKeyActivityLevel] intValue];
	activityLevel = (activityLevel == 0)?kDefaultActivityLevel:activityLevel;
    
    
    if ([UIImage instancesRespondToSelector:@selector(imageWithRenderingMode:)])
        {
            
            [self->activityLevelChoiceControl setImage:[[UIImage imageNamed:@"YellowBelt.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:0];
            [self->activityLevelChoiceControl setImage:[[UIImage imageNamed:@"GreenBelt.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:1];
            [self->activityLevelChoiceControl setImage:[[UIImage imageNamed:@"RedBelt.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:2];
            [self->activityLevelChoiceControl setImage:[[UIImage imageNamed:@"BlackBelt.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:3];
        }
    
    
    
    if (settingsDict)
    {
        playSoundInApplication = [[settingsDict valueForKey:kSettingsKeyPlaySound] boolValue];
    }
    else
    {
        playSoundInApplication = kDefaultAppSoundState;
    }

	//initialize UI
	numberOfQuestionsSlider.minimumValue = kMinQuestions;
	numberOfQuestionsSlider.maximumValue = kMaxQuestions;
	numberOfQuestionsSlider.continuous = YES;
	numberOfQuestionsSlider.value = numberOfQuestions;
	numberOfMinutesSlider.minimumValue = kMinMinutes;
	numberOfMinutesSlider.maximumValue = kMaxMinutes;
	numberOfMinutesSlider.continuous = YES;
	numberOfMinutesSlider.value = numberOfMinutes;
	activityLevelChoiceControl.selectedSegmentIndex = activityLevel;
	numberOfQuestionsLabel.text = [NSString stringWithFormat:kStrVarNumberOfQuestions,numberOfQuestions];	
	numberOfMinutesLabel.text = [NSString stringWithFormat:kStrVarNumberOfMinutes,numberOfMinutes];
	[playSoundDecider setOn:playSoundInApplication];
	switch (activityLevel) {
		case kActLevelYellowBelt:
			activityLevelLabel.text = kStrActTypeYellowBelt;
			activityLevelDescriptionLabel.text = kStrYellowBeltDescription;
			break;
		case kActLevelGreenBelt:
			activityLevelLabel.text = kStrActTypeGreenBelt;
			activityLevelDescriptionLabel.text = kStrGreenBeltDescription;
			break;
		case kActLevelRedBelt:
			activityLevelLabel.text = kStrActTypeRedBelt;
			activityLevelDescriptionLabel.text = kStrRedBeltDescription;
			break;
		case kActLevelBlackBelt:
			activityLevelLabel.text = kStrActTypeBlackBelt;
			activityLevelDescriptionLabel.text = kStrBlackBeltDescription;
			break;
		default:
			break;
	}
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(settingsDone:)];
	//settingsNavController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonSystemItemDone target:self action:nil];
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
	//if (self != self.delegate) delegate = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Custom Actions

- (IBAction) maxNumberOfQuestionsChanged: (id) sender {
	int sliderValue = numberOfQuestionsSlider.value;
	numberOfQuestions = (sliderValue/kIncrementQuestions)*kIncrementQuestions;
	if ((sliderValue%kIncrementQuestions) == 0) {
		numberOfQuestionsLabel.text = [NSString stringWithFormat:kStrVarNumberOfQuestions,numberOfQuestions];
		isDirty = YES;
	}
}

- (IBAction) maxNumberOfMinutesChanged: (id) sender {
	int sliderValue = numberOfQuestionsSlider.value;
	numberOfMinutes = (numberOfMinutesSlider.value/kIncrementMinutes)*kIncrementMinutes;
	if ((sliderValue%kIncrementMinutes) == 0)
		numberOfMinutesLabel.text = [NSString stringWithFormat:kStrVarNumberOfMinutes,numberOfMinutes];
		isDirty = YES;
}

- (IBAction) activityLevelChoiceChanged: (id) sender {
	isDirty = YES;
	activityLevel = activityLevelChoiceControl.selectedSegmentIndex;
	switch (activityLevel) {
		case kActLevelYellowBelt:
			activityLevelLabel.text = kStrActTypeYellowBelt;
			activityLevelDescriptionLabel.text = kStrYellowBeltDescription;
			break;
		case kActLevelGreenBelt:
			activityLevelLabel.text = kStrActTypeGreenBelt;
			activityLevelDescriptionLabel.text = kStrGreenBeltDescription;
			break;
		case kActLevelRedBelt:
			activityLevelLabel.text = kStrActTypeRedBelt;
			activityLevelDescriptionLabel.text = kStrRedBeltDescription;
			break;
		case kActLevelBlackBelt:
			activityLevelLabel.text = kStrActTypeBlackBelt;
			activityLevelDescriptionLabel.text = kStrBlackBeltDescription;
		default:
			break;
	}
}

- (IBAction) playSound: (id)sender
{
	isDirty = YES;
	playSoundInApplication = [playSoundDecider isOn];
}

/*
- (void) SlideActivityLevelTextInAndOut {
	[UIView beginAnimations:@"SlideActivityLevelTextInAndOut" context:nil];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	CGRect frame = [activityLevelDescriptionDropDownView frame];
	activityLevelDescriptionLabel.text = kStrBlank;
	activityLevelLabel.text = kStrBlank;
	activityLevelDescriptionDropDownView.bounds = CGRectMake(0, 0, frame.size.width, 0);
	activityLevelDescriptionDropDownView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 0);
	[UIView commitAnimations];	
}

- (void) slideActivityLevelTextOut: (CGRect) frame {
	[UIView beginAnimations:@"SlideActivityLevelTextOut" context:nil];
	[UIView setAnimationDuration:0.25];
	activityLevelDescriptionDropDownView.bounds = CGRectMake(0, 0, width, height);
	activityLevelDescriptionDropDownView.frame = CGRectMake(origin.x, origin.y,width, height);
	switch (activityLevelChoiceControl.selectedSegmentIndex) {
		case kActLevelYellowBelt:
			activityLevelLabel.text = kStrActTypeYellowBelt;
			activityLevelDescriptionLabel.text = kStrYellowBeltDescription;
			break;
		case kActLevelGreenBelt:
			activityLevelLabel.text = kStrActTypeGreenBelt;
			activityLevelDescriptionLabel.text = kStrGreenBeltDescription;
			break;
		case kActLevelRedBelt:
			activityLevelLabel.text = kStrActTypeRedBelt;
			activityLevelDescriptionLabel.text = kStrRedBeltDescription;
			break;
		case kActLevelBlackBelt:
			activityLevelLabel.text = kStrActTypeBlackBelt;
			activityLevelDescriptionLabel.text = kStrBlackBeltDescription;
		default:
			break;
	}
	[UIView commitAnimations];
}
*/

- (void) settingsDone: (id) sender {
	if (isDirty) {
		//update settings here
		//Get the file name - root for documents directory
		NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString *fileNameWithPath = [docPath stringByAppendingPathComponent:kFileAppSettings];
		//Create dictionary
		NSDictionary *settingsDict = [NSDictionary dictionaryWithObjectsAndKeys:
									  [NSNumber numberWithInt:numberOfQuestions],kSettingsKeyNumberOfQuestions,
									  [NSNumber numberWithInt:numberOfMinutes],kSettingsKeyNumberOfMinutes,
									  [NSNumber numberWithInt:activityLevel],kSettingsKeyActivityLevel,
									  [NSNumber numberWithBool:playSoundInApplication],kSettingsKeyPlaySound,
									  nil];

		[settingsDict writeToFile:fileNameWithPath atomically:YES];
		[[KidsTimeFunAppState sharedState] readSettings];
	}
	[self.navigationController popViewControllerAnimated:YES];
//	if ([self.delegate conformsToProtocol:@protocol(DismissSettings)])
//			[self.delegate didDismissSettings:self];
}

@end
