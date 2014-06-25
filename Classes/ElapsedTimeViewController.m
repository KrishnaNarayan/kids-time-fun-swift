//
//  ElapsedTimeViewController.m
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
//

#import "ElapsedTimeViewController.h"
#import "ClockView.h"
#import "RandomInteger.h"
#import "KidsTimeFunAppState.h"
#import "AudioPlayer.h"

@implementation ElapsedTimeViewController

@synthesize delegate;
@synthesize isRight;
@synthesize activity;
@synthesize activityType;
@synthesize activityLevel;
@synthesize timeOffset;
@synthesize answerIndex;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
	//Build first clock
	clockView = [[ClockView alloc] initWithFrame:clockContainerView.bounds];
	clockView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f	alpha:0.0f];
	
	//Build 2nd clock
	if (self.activity == kActElapsedTime) {
		clockView2 = [[ClockView alloc] initWithFrame:clockContainerView.bounds];
		clockView2.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
	}
	
	//initialize intervals and range based on difficulty settings
	int timeInterval, timeRangeLow, timeRangeHigh, numberOfChoices;
	switch (self.activityLevel) {
		case kActLevelYellowBelt:
			numberOfChoices = 2;
			timeInterval = 30;
			timeRangeLow = 30;
			timeRangeHigh = 120;
			break;
		case kActLevelGreenBelt:
			numberOfChoices = 3;
			timeInterval = 15;
			timeRangeLow = 15;
			timeRangeHigh = 240;
			break;
		case kActLevelRedBelt:
			numberOfChoices = 4;
			timeInterval = 5;
			timeRangeLow = 5;
			timeRangeHigh = 360;
			break;
		case kActLevelBlackBelt:
			numberOfChoices = 4;
			timeInterval = 1;
			timeRangeLow = 5;
			timeRangeHigh = 719;
			break;
		default:
			break;
	}
	
	//set number of choices on UI
	switch (numberOfChoices) {
		case 2:
			choices4.hidden = YES;
			choices3.hidden = YES;
			choices2.hidden = NO;
			choices = choices2;
			break;
		case 3:
			choices4.hidden = YES;
			choices3.hidden = NO;
			choices2.hidden = YES;
			choices = choices3;
			break;
		case 4:
			choices4.hidden = NO;
			choices3.hidden = YES;
			choices2.hidden = YES;
			choices = choices4;
			break;
		default:
			break;
	}
	
	//Load first/main clock with Random values
	//Hours first
	randomNumber = [[RandomInteger alloc] initWithRange:1 To:12];
	clockView.hours = randomNumber.randomInteger;
	//Then AM/PM
	clockView.PM = ([randomNumber nextRandomIntegerInRange:0 To:1])?YES:NO;
	//rounded to nearest multiple of timeInterval
	clockView.minutes = ([randomNumber nextRandomIntegerInRange:0 To:59] / timeInterval)*timeInterval;
	//No seconds for now
	clockView.seconds = 0;
	clockView.showSeconds = NO;
	//other clock properties
	clockView.showClockAsAnalog = YES;
	clockView.showMinutesOffsetInHoursHand = YES;
	clockView.showAMPM = NO;
	clockView.showDayNight = NO;
	//add clock as a view in the container
	[clockContainerView addSubview:clockView];
	//NSLog(@"First: %f %f %f %f",clockView.frame.origin.x,clockView.frame.origin.y,clockView.frame.size.width,clockView.frame.size.height);
		
	//Then ask the question
	int randomTimeOffset, randomHoursOffset, randomMinutesOffset;
	 labelQuestion.text = @"How much time has passed?";
	[[AudioPlayer getInstance] playAudioFile:@"how_much_time_has_past"];
	
	//create timeoffset for clock 2
	randomTimeOffset = [randomNumber nextRandomIntegerInRange:timeRangeLow To:timeRangeHigh];
	randomTimeOffset = (randomTimeOffset/timeInterval)*timeInterval;
	randomHoursOffset = randomTimeOffset/60;
	randomMinutesOffset = randomTimeOffset-(randomHoursOffset*60);
	
	//this offset is the answer
	int answerHours, answerMinutes;
	answerHours = randomHoursOffset;
	answerMinutes = randomMinutesOffset;
	
	//hours and minutes for 2nd clock
	int clock2hours, clock2minutes;
	clock2minutes = (int)clockView.hours*60+(int)clockView.minutes;
	clock2minutes = clock2minutes +randomTimeOffset;
	if (clock2minutes < 0) clock2minutes = clock2minutes+720;
	if (clock2minutes > 720) clock2minutes = clock2minutes-720;
	clock2hours = clock2minutes/60;
	clock2minutes = clock2minutes-(clock2hours*60);
	if (clock2hours == 0) clock2hours = 12;
	
	//Load 2nd clock
	//Hours first
	clockView2.hours = clock2hours;
	//Then AM/PM
	clockView2.PM = clockView.PM;
	//rounded to nearest multiple of timeInterval
	clockView2.minutes = clock2minutes;
	//No seconds for now
	clockView2.seconds = 0;
	clockView2.showSeconds = NO;
	//other clock properties
	clockView2.showClockAsAnalog = YES;
	clockView2.showMinutesOffsetInHoursHand = YES;
	clockView2.showAMPM = NO;
	clockView2.showDayNight = NO;
	//add clock as a view in the container
	[clockContainerView2 addSubview:clockView2];
	
	//load random answer choices
	int h=0, m=0, prev_h=0, prev_m=0;
	NSString* answerTitle =  (answerHours == 0) ? [NSString stringWithFormat:@"%02i min", answerMinutes] : [NSString stringWithFormat:@"%i:%02i", answerHours, answerMinutes];

	for (int i = 0; i<choices.numberOfSegments; i++) {
		BOOL newNumberGenerated = NO;
		NSString* choiceTitle;
		while (!newNumberGenerated) {
			//generate random time
			h = [randomNumber nextRandomIntegerInRange:((timeRangeLow/60)==0)?1:timeRangeLow To:(timeRangeHigh/60)];
			m = ([randomNumber nextRandomIntegerInRange:0 To:59]/timeInterval)*timeInterval;
			//if same as previous or answer, generate new random minute to change it
			int loopLimit=0;
			while ((((prev_h*60+prev_m) == (h*60+m))||((h*60+m) == (answerHours*60+answerMinutes)))&&(loopLimit<3)) {
				m = (randomNumber.randomInteger/timeInterval)*timeInterval;
				++loopLimit;
			}
			prev_m = m;
			prev_h = h;
			choiceTitle = (h == 0) ? [NSString stringWithFormat:@"%02i min", m] : [NSString stringWithFormat:@"%i:%02i", h, m];
			if (i == 0) {
				newNumberGenerated = YES;
			}
			else 
			{
				for (int j = 0; j < i; j++) 
				{
					if ([[choices titleForSegmentAtIndex:j] isEqualToString:choiceTitle] || [answerTitle isEqualToString:choiceTitle]) {
						newNumberGenerated = NO;
						break;
					}
					else {
						newNumberGenerated = YES;
					}

				}
			}
		}
		[choices setTitle:choiceTitle forSegmentAtIndex:i];
	}
	//load answer in a random index, but remember where it is
	randomNumber.rangeLow = 0;
	randomNumber.rangeHigh =(int) choices.numberOfSegments-1;
	self.answerIndex = randomNumber.randomInteger;
//	if (answerHours == 0) [choices setTitle:[NSString stringWithFormat:@"%02i min", answerMinutes] forSegmentAtIndex:self.answerIndex];
//		else [choices setTitle:[NSString stringWithFormat:@"%i:%02i", answerHours, answerMinutes] forSegmentAtIndex:self.answerIndex];
	[choices setTitle:answerTitle forSegmentAtIndex:self.answerIndex];
	//now load super
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
	[randomNumber release];
	[clockContainerView release];
	[clockContainerView2 release];
	[clockView2 release];
	[clockView release];
	if (self.delegate != self) delegate = nil;
	[choices release];
	[rightOrWrong release];
    [super dealloc];
}

#pragma mark -
#pragma mark Custom Methods

- (IBAction) choicesValueChanged {
	choices.enabled = NO;
	choices.hidden = YES;
	if (choices.selectedSegmentIndex == self.answerIndex) {
		isRight = YES;
		rightOrWrong.image = [UIImage imageNamed:@"GoodJob.png"];
		rightOrWrong2.image = [UIImage imageNamed:@"Right.png"];
		rightOrWrong2.hidden = NO;
		[[AudioPlayer getInstance] playCorrectWrong:YES];
		[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(rightAnswer) userInfo:NULL repeats:NO];
	}
	else {
		isRight = NO;
		++wrongCounter;
		rightOrWrong2.image = [UIImage imageNamed:@"Wrong.png"];
		rightOrWrong.image = [UIImage imageNamed:@"TryAgain.png"];
		[[AudioPlayer getInstance] playCorrectWrong:NO];
		if (self.activityType == kActTypeTimed) {
			rightOrWrong2.hidden = NO;
			rightOrWrong.hidden = YES;
		}
		else {
			rightOrWrong2.hidden = YES;
			rightOrWrong.hidden = NO;
		}
		NSLog(@"Wrong Answer");
		[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(wrongAnswer) userInfo:NULL repeats:NO];
	}
}

- (void) rightAnswer {
	if (wrongCounter > 0) {
		isRight = NO;
		wrongCounter = 0;
	}
	if ([delegate conformsToProtocol:@protocol(DismissActivityDelegate)]) [delegate didDismissActivity:self];
}

- (void) wrongAnswer {
	if (self.activityType != kActTypeTimed) {
		rightOrWrong.image = nil;
		rightOrWrong2.image = nil;
		rightOrWrong2.hidden = YES;
		choices.enabled = YES;
		choices.hidden = NO;
		[self.view setNeedsDisplay];
	}
	else {
		if ([delegate conformsToProtocol:@protocol(DismissActivityDelegate)]) [delegate didDismissActivity:self];
	}

}

@end
