//
//  TellTimeViewController.m
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
//

#import "TellTimeViewController.h"
#import "ClockView.h"
#import "RandomInteger.h"
#import "KidsTimeFunAppState.h"
#import "AudioPlayer.h"

@implementation TellTimeViewController

@synthesize delegate;
@synthesize isRight;
@synthesize activity;
@synthesize activityType;
@synthesize activityLevel;
@synthesize timeOffset;
@synthesize answerIndex;

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
	//Build a clock
	clockView = [[ClockView alloc] initWithFrame:clockContainerView.bounds];
	clockView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f	alpha:0.0f];
	
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
	
	//[clockContainerView2 addSubview:clockView2];
	
	//Then ask the question
	int randomTimeOffset = 0, randomHoursOffset, randomMinutesOffset;
	NSMutableString *labelQuestionText = [NSMutableString string];
	switch (self.timeOffset) {
		case 0:
			labelQuestionText = [NSMutableString stringWithFormat:@"What time is it?"];
			[[AudioPlayer getInstance] playAudioFile:@"what_time_is_it"];
			break;
		case -1:
			randomTimeOffset = [randomNumber nextRandomIntegerInRange:timeRangeLow To:timeRangeHigh];
			randomTimeOffset = (randomTimeOffset/timeInterval)*timeInterval;
			randomHoursOffset = randomTimeOffset/60;
			randomMinutesOffset = randomTimeOffset-(randomHoursOffset*60);
			if (randomHoursOffset == 0) { 
				NSString* minutes = [NSString stringWithFormat:@"%i %@",randomMinutesOffset, randomMinutesOffset == 1 ? @"minute" : @"minutes"];
				labelQuestionText = [NSMutableString stringWithFormat:@"What was the time %@ ago?", minutes];
				[[AudioPlayer getInstance] playTellTime:@"what_was_the_time" playHours:NO hours:@"" playMinutes:YES minutes:minutes playAnd:NO playAgo:YES];
			}
			else {
				if (randomMinutesOffset == 0) {
					NSString* hrs = [NSString stringWithFormat:@"%i %@",randomHoursOffset, randomHoursOffset == 1 ? @"hour" : @"hours"];
					labelQuestionText = [NSMutableString stringWithFormat:@"What was the time %@ ago?",hrs];
					[[AudioPlayer getInstance] playTellTime:@"what_was_the_time" playHours:YES hours:hrs playMinutes:NO minutes:@"" playAnd:NO playAgo:YES];
				}
				else {
					NSString* hrs = [NSString stringWithFormat:@"%i %@",randomHoursOffset, randomHoursOffset == 1 ? @"hour" : @"hours"];
					NSString* minutes = [NSString stringWithFormat:@"%i %@",randomMinutesOffset, randomMinutesOffset == 1 ? @"minute" : @"minutes"];
					labelQuestionText = [NSMutableString stringWithFormat:@"What was the time %@ and %@ ago?", hrs, minutes];
					[[AudioPlayer getInstance] playTellTime:@"what_was_the_time" playHours:YES hours:hrs playMinutes:YES minutes:minutes playAnd:YES playAgo:YES];
				}
			}
			break;
		case 1:
			randomTimeOffset = [randomNumber nextRandomIntegerInRange:timeRangeLow To:timeRangeHigh];
			randomTimeOffset = (randomTimeOffset/timeInterval)*timeInterval;
			randomHoursOffset = randomTimeOffset/60;
			randomMinutesOffset = randomTimeOffset-(randomHoursOffset*60);
			if (randomHoursOffset == 0) { 
				NSString* minutes = [NSString stringWithFormat:@"%i %@",randomMinutesOffset, randomMinutesOffset == 1 ? @"minute" : @"minutes"];
				labelQuestionText = [NSMutableString stringWithFormat:@"What will the time be in %@?", minutes];
				[[AudioPlayer getInstance] playTellTime:@"what_will_the_time_be_in" playHours:NO hours:@"" playMinutes:YES minutes:minutes playAnd:NO playAgo:NO];
			}
			else {
				if (randomMinutesOffset == 0) {
					NSString* hrs = [NSString stringWithFormat:@"%i %@",randomHoursOffset, randomHoursOffset == 1 ? @"hour" : @"hours"];
					labelQuestionText = [NSMutableString stringWithFormat:@"What will the time be in %@?", hrs];
					[[AudioPlayer getInstance] playTellTime:@"what_will_the_time_be_in" playHours:YES hours:hrs playMinutes:NO minutes:@"" playAnd:NO playAgo:NO];

				}
				else {
					NSString* minutes = [NSString stringWithFormat:@"%i %@",randomMinutesOffset, randomMinutesOffset == 1 ? @"minute" : @"minutes"];
					NSString* hrs = [NSString stringWithFormat:@"%i %@",randomHoursOffset, randomHoursOffset == 1 ? @"hour" : @"hours"];

					labelQuestionText = [NSMutableString stringWithFormat:@"What will the time be in %@ and %@?",hrs, minutes];
					[[AudioPlayer getInstance] playTellTime:@"what_will_the_time_be_in" playHours:YES hours:hrs playMinutes:YES minutes:minutes playAnd:YES playAgo:NO];

				}
			}
			break;
		default:
			break;
	}
	//replace 1 hours with 1 hour and 1 minutes with 1 minute
	[labelQuestionText replaceOccurrencesOfString:@" 1 hours" withString:@" 1 hour" options:NSCaseInsensitiveSearch range:NSMakeRange(0, labelQuestionText.length)];
	[labelQuestionText replaceOccurrencesOfString:@" 1 minutes" withString:@" 1 minute" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [labelQuestionText length])];
	
	 //show questions
	labelQuestion.text = labelQuestionText;
	[self.view bringSubviewToFront:labelQuestion];
	 
	//calculate answer
	int answerHours, answerMinutes;
	if (self.timeOffset == 0) {
		answerHours = (int)clockView.hours;
		answerMinutes = (int)clockView.minutes;
	}
	else {
		answerMinutes = (int)clockView.hours*60+(int)clockView.minutes;
		answerMinutes = answerMinutes + (self.timeOffset * randomTimeOffset);
		if (answerMinutes < 0) answerMinutes = answerMinutes+720;
		if (answerMinutes > 720) answerMinutes = answerMinutes-720;
		answerHours = answerMinutes/60;
		answerMinutes = answerMinutes-(answerHours*60);
		if (answerHours == 0) answerHours = 12;
	}
	
	//load random answer choices
	int h=0, m=0, prev_h=0, prev_m=0;
	for (int i = 0; i<choices.numberOfSegments; i++) {
		//generate random time
        h = [randomNumber nextRandomIntegerInRange:1 To:12];
        m = ([randomNumber nextRandomIntegerInRange:0 To:59]/timeInterval)*timeInterval;
		//if same as previous or answer, generate new random minute to change it
		int loopLimit=0;
		while ((loopLimit<9)&&
               (((h*60+m) == (prev_h*60+prev_m))||
                ((h*60+m) == (answerHours*60+answerMinutes)))) {
            //generate random answer again
            h = [randomNumber nextRandomIntegerInRange:1 To:12];
            m = ([randomNumber nextRandomIntegerInRange:0 To:59]/timeInterval)*timeInterval;
            ++loopLimit;
		}
		prev_m = m;
		prev_h = h;
		if (((self.activityLevel == kActLevelYellowBelt) || (self.activityLevel == kActLevelGreenBelt)) && (m == 0)) [choices setTitle:[NSString stringWithFormat:@"%i o'clock", h] forSegmentAtIndex:i];
		else [choices setTitle:[NSString stringWithFormat:@"%i:%02i", h, m] forSegmentAtIndex:i];}
	//load answer in a random index, but remember where it is
	randomNumber.rangeLow = 0;
	randomNumber.rangeHigh = (int) choices.numberOfSegments-1;
    
	self.answerIndex = randomNumber.randomInteger;
	if (((self.activityLevel == kActLevelYellowBelt) || (self.activityLevel == kActLevelGreenBelt)) && (answerMinutes == 0)) [choices setTitle:[NSString stringWithFormat:@"%i o'clock", answerHours] forSegmentAtIndex:self.answerIndex];
		else [choices setTitle:[NSString stringWithFormat:@"%i:%02i", answerHours, answerMinutes] forSegmentAtIndex:self.answerIndex];
	//super load
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
		rightOrWrong.image = [UIImage imageNamed:@"GoodJob"];
		rightOrWrong2.image = [UIImage imageNamed:@"Right"];
		rightOrWrong2.hidden = NO;
		[[AudioPlayer getInstance] playCorrectWrong:YES];
		[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(rightAnswer) userInfo:NULL repeats:NO];
	}
	else {
		isRight = NO;
		++wrongCounter;
		rightOrWrong2.image = [UIImage imageNamed:@"Wrong"];
		rightOrWrong.image = [UIImage imageNamed:@"TryAgain"];
		[[AudioPlayer getInstance] playCorrectWrong:NO];
		
		if (self.activityType == kActTypeTimed) {
			rightOrWrong2.hidden = YES;
			rightOrWrong.hidden = NO;
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
