// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Copyright 2026 Island Innovation LLC.  All rights reserved.

//
//  SetTimeViewController.m
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/30/09.
//  Modified by SVV Satyanarayana, under contract to NSC Partners LLC on 28/04/10.
//  Copyright 2009-2012 NSC Partners LLC. All rights reserved.
//

#import "SetTimeViewController.h"
#import "SetClockView.h"
#import "RandomInteger.h"
#import "KidsTimeFunAppState.h"

@implementation SetTimeViewController

@synthesize delegate;
@synthesize isRight;
@synthesize activity;
@synthesize activityType;
@synthesize activityLevel;
@synthesize timeOffset;

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
		
	//Generate a random time to set
	//Hours first
	randomNumber = [[RandomInteger alloc] initWithRange:1 To:12];
	setHours = randomNumber.randomInteger;
	//rounded to nearest multiple of timeInterval
	//setMinutes = ([randomNumber nextRandomIntegerInRange:0 To:59] / timeInterval)*timeInterval;
	setMinutes = [randomNumber nextRandomIntegerInRange:0 To:59];
	setMinutes = setMinutes/timeInterval;
	setMinutes = setMinutes*timeInterval;
	
	//Set the time string in view
	NSString* sTime;
    sTime = [NSString stringWithFormat:@"%d:%.2d",setHours,setMinutes];
    
//	if(setMinutes == 0)
//	{
//		//[labelQuestion setText:[NSString stringWithFormat:@"Move the clock hands to %d:00",setHours]];
//		sTime = [NSString stringWithFormat:@"%d:00",setHours];
//	}
//	else
//	{
//        sTime = [NSString stringWithFormat:@"%.2d:%.2d",setHours,setMinutes];
//		if(setMinutes < 10)
//		{
//			//[labelQuestion setText:[NSString stringWithFormat:@"Move the clock hands to %d:0%d",setHours,setMinutes]];
//			sTime = [NSString stringWithFormat:@"%d:0%d",setHours,setMinutes];
//		}
//		else 
//		{
//			//[labelQuestion setText:[NSString stringWithFormat:@"Move the clock hands to %d:%d",setHours,setMinutes]];	
//			sTime = [NSString stringWithFormat:@"%d:%d",setHours,setMinutes];
//		}
//	}
  
    NSLog(@"####### Time: %d %d",setHours, setMinutes);
    NSLog(@"%@",[NSString stringWithFormat:@"Move the clock hands to %@",sTime]);
	labelQuestion.text = [NSString stringWithFormat:@"Move the clock hands to %@",sTime];
    
	//KRISHNA -  NOT PLAYING THIS SOUND FILE BELOW
    
	[[AudioPlayer getInstance] playAudioFile:@"move_the_clock_hands_to" withTime:sTime];
	if(setClockView)
	{
		[setClockView release];
	}
	//Build a clock
	setClockView = [[SetClockView alloc] initWithFrame:clockContainerView.bounds];	
	setClockView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f	alpha:0.0f];
	[self.view bringSubviewToFront:labelQuestion];
	//ask question
	
	//add clock as a view in the container
	[clockContainerView addSubview:setClockView];
	//[[AudioPlayer getInstance] playAudioForHours:setHours andMinutes:setMinutes];
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
	[setClockView release];
	if (self.delegate != self) delegate = nil;
	//[rightOrWrong release];
    [super dealloc];
}

#pragma mark -
#pragma mark Custom Methods

- (IBAction) setTimeButtonPushed 
{
	//NSLog(@"Hours diff:%f, minutes diff:%f",(setHours*1.0)-setClockView.hours, (setMinutes*1.0)-setClockView.minutes);

/*New1	
	BOOL rightHours = NO;
	float diffHours = (setHours*1.0)-setClockView.hours;
	if ((setClockView.minutes >= 0 && setClockView.minutes < 15) && (ABS(diffHours) >= 0 && ABS(diffHours) <= 0.25)) {
		rightHours = YES;
	}
	else if ((setClockView.minutes >= 15 && setClockView.minutes < 30) && (ABS(diffHours) >= 0.25 && ABS(diffHours) <= 0.5)){
		rightHours = YES;
	}
	else if ((setClockView.minutes >= 30 && setClockView.minutes) < 45 && (ABS(diffHours) >= 0.5 && ABS(diffHours) <= 0.75)){
		rightHours = YES;
	}
	else if ((setClockView.minutes >= 45 && setClockView.minutes <= 59) && (ABS(diffHours) >= 0.75 && ABS(diffHours) <= 0.99999999)){
		rightHours = YES;
	}
	
	if (rightHours && setMinutes == setClockView.minutes)
*/
//Old	if ((setHours == setClockView.hours) && (setMinutes == setClockView.minutes))	//This conditional check was added by Krishna
    
	BOOL rightHours = NO;
	int hrs = round(setClockView.hours);
	if (hrs == 12) {
		hrs = 0;
	}

    int tempHrs = setHours;
    if (tempHrs == 12) {
        tempHrs = 0;
    }
	if (setClockView.hours >= tempHrs && setClockView.hours <=  MIN(hrs+1,(hrs+setClockView.minutes/60.0)*1.1)) 
//	if ((fabs(setClockView.hours - tempHrs) < 0.1) && setClockView.hours <=  MIN(hrs+1,(hrs+setClockView.minutes/60.0)*1.1))     
	{
		rightHours = YES;
	}
	
	if (rightHours && (abs(setMinutes-setClockView.minutes) < 2))
	{
		isRight = YES;
		NSLog(@"Right Answer");
		rightOrWrong2.image = [UIImage imageNamed:@"Right"];
		rightOrWrong.image = [UIImage imageNamed:@"GoodJob"];
		rightOrWrong2.hidden = NO;
		[[AudioPlayer getInstance] playCorrectWrong:YES];
		[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(rightAnswer) userInfo:NULL repeats:NO];
	}
	else 
	{
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
		[self.view setNeedsDisplay];
	}
	else {
		if ([delegate conformsToProtocol:@protocol(DismissActivityDelegate)]) [delegate didDismissActivity:self];
	}

}

@end
