//
//  KidsTimeFunAppState.m
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. All rights reserved.

//  A singleton for state

#import "KidsTimeFunAppState.h"

//state dict keys
#define kStrStateKeyPlayerName @"Player Name"
#define kStrStateKeyCurrentScreen @"Current Screen"
#define kStrStateKeyActivity @"Activity"
#define kStrStateKeyActivityType @"Activity Type"
#define kStrStateKeyActivityLevel @"Activity Level"
#define kStrStateKeyQuestionNumber @"Question Number"
#define kStrStateKeyQuestionsRight @"Questions Right"
#define kStrStateKeyQuestionsWrong @"Questions Wrong"
#define kStrStateKeyQuestionsUnanswered @"Questions Unanswered"
#define kStrStateKeyActivityProgress @"Activity Progress"
#define kStrStateKeyMaxQuestions @"Max Questions"
#define kStrStateKeyMaxTimeInSeconds @"Max Time In Seconds"
#define kStrStateKeySizeOfTopScoreList @"Size of Top Score List"
#define kStrStateKeyAppSoundState @"App Sound State"

@implementation KidsTimeFunAppState

@synthesize playerName;
@synthesize screen;
@synthesize activity;
@synthesize activityType;
@synthesize activityLevel;
@synthesize questionNumber;
@synthesize questionsRight;
@synthesize questionsWrong;
@synthesize questionsUnanswered;
@synthesize activityProgress;
@synthesize maxQuestions;
@synthesize maxTimeInSeconds;
@synthesize sizeOfTopScoreList;
@synthesize appSoundState;

static KidsTimeFunAppState *sharedState = nil;

+(KidsTimeFunAppState *) sharedState {
    @synchronized(self) {
        if (sharedState == nil) {
            sharedState = [[self alloc] init]; // assignment not done here
        }
    }
    return sharedState;
}

+(id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedState == nil) {
            sharedState = [super allocWithZone:zone];
            return sharedState;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}


-(void)dealloc {
	[playerName release];
    [super dealloc];
}

-(id)copyWithZone:(NSZone *)zone {
    return self;
}


-(id)retain {
    return self;
}


-(NSUInteger)retainCount {
    return UINT_MAX;  //denotes an object that cannot be release
}


-(oneway void)release {
    //do nothing    
}


-(id)autorelease {
    return self;    
}


-(id)init {
    self = [super init];
    sharedState = self;
	//Initialize Defaults
	self.playerName = kDefaultPlayerName;
	self.screen = kScrNone;
	self.activity = kActNone;
	self.activityType = kDefaultActivityType;
	self.activityLevel = kDefaultActivityLevel;
	self.questionNumber = 0;
	self.questionsRight = 0;
	self.questionsWrong = 0;
	self.questionsUnanswered = 0;
	self.activityProgress = kActQuestionNotDisplayed;
	self.maxQuestions = kDefaultMaxNumberOfQuestions;
	self.maxTimeInSeconds = kDefaultMaxTimeInSeconds;
	self.sizeOfTopScoreList = kDefaultSizeOfTopScoreList;
	self.appSoundState = kDefaultAppSoundState;
    //Now read from NSUserDefaults
	//Code to be written
	[self readSettings];
    return self;
}

- (void) readSettings {
	//Get the file name - root for documents directory
	NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *fileNameWithPath = [docPath stringByAppendingPathComponent:kFileAppSettings];
	//Now read settings from disk
	NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:fileNameWithPath];
	int numberOfQuestions = [[settingsDict valueForKey:kSettingsKeyNumberOfQuestions] intValue];
	numberOfQuestions = (numberOfQuestions == 0)?kDefaultMaxNumberOfQuestions:numberOfQuestions;
	int numberOfMinutes = [[settingsDict valueForKey:kSettingsKeyNumberOfMinutes] intValue];
	numberOfMinutes = (numberOfMinutes == 0)?(kDefaultMaxTimeInSeconds/60):numberOfMinutes;
	int actLevel = [[settingsDict valueForKey:kSettingsKeyActivityLevel] intValue];
	actLevel = (actLevel == 0)?kDefaultActivityLevel:actLevel;
	self.activityLevel = actLevel;
	self.maxQuestions = numberOfQuestions;
	self.maxTimeInSeconds = numberOfMinutes*60;
    
    if (settingsDict)
    {
        self.appSoundState = [[settingsDict valueForKey:kSettingsKeyPlaySound] boolValue];
    }
    else
    {
        self.appSoundState = kDefaultAppSoundState;
    }
}

-(void) flushState {
	//Get the file name - root for documents directory
	NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *fileNameWithPath = [docPath stringByAppendingPathComponent:kFileAppState];
	//Now read settings from disk
	NSMutableDictionary *stateDict = [[NSMutableDictionary alloc] init];
	[stateDict setObject:self.playerName forKey:kStrStateKeyPlayerName];
	[stateDict setObject:[NSNumber numberWithInt:self.screen] forKey:kStrStateKeyCurrentScreen];
	[stateDict setObject:[NSNumber numberWithInt:self.activity] forKey:kStrStateKeyActivity];
	[stateDict setObject:[NSNumber numberWithInt:self.activityType] forKey:kStrStateKeyActivityType];
	[stateDict setObject:[NSNumber numberWithInt:self.activityLevel] forKey:kStrStateKeyActivityLevel];
	[stateDict setObject:[NSNumber numberWithInt:self.questionNumber] forKey:kStrStateKeyQuestionNumber];
	[stateDict setObject:[NSNumber numberWithInt:self.questionsRight] forKey:kStrStateKeyQuestionsRight];
	[stateDict setObject:[NSNumber numberWithInt:self.questionsWrong] forKey:kStrStateKeyQuestionsWrong];
	[stateDict setObject:[NSNumber numberWithInt:self.questionsUnanswered] forKey:kStrStateKeyQuestionsUnanswered];
	[stateDict setObject:[NSNumber numberWithInt:self.activityProgress] forKey:kStrStateKeyActivityProgress];
	[stateDict setObject:[NSNumber numberWithInt:self.maxQuestions] forKey:kStrStateKeyMaxQuestions];
	[stateDict setObject:[NSNumber numberWithInt:self.maxTimeInSeconds] forKey:kStrStateKeyMaxTimeInSeconds];
	[stateDict setObject:[NSNumber numberWithInt:self.sizeOfTopScoreList] forKey:kStrStateKeySizeOfTopScoreList];
	[stateDict setObject:[NSNumber numberWithBool:self.appSoundState] forKey:kStrStateKeyAppSoundState];
	[stateDict writeToFile:fileNameWithPath atomically:YES];
    [stateDict release];
}

-(void) resumeFromState {
	//Get the file name - root for documents directory
	NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *fileNameWithPath = [docPath stringByAppendingPathComponent:kFileAppState];
	//Now read settings from disk
	NSDictionary *stateDict = [NSDictionary dictionaryWithContentsOfFile:fileNameWithPath];
	if ([stateDict count] > 0) {
		self.playerName = [stateDict valueForKey:kStrStateKeyPlayerName];
		//self.screen = [[stateDict valueForKey:kStrStateKeyCurrentScreen] intValue];
		//self.activity = [[stateDict valueForKey:kStrStateKeyActivity] intValue];
		self.activityType = [[stateDict valueForKey:kStrStateKeyActivityType] intValue];
		//self.activityLevel = [[stateDict valueForKey:kStrStateKeyActivityLevel] intValue];
		//self.questionNumber = [[stateDict valueForKey:kStrStateKeyQuestionNumber] intValue];
		//self.questionsRight = [[stateDict valueForKey:kStrStateKeyQuestionsRight] intValue];
		//self.questionsWrong = [[stateDict valueForKey:kStrStateKeyQuestionsWrong] intValue];
		//self.questionsUnanswered = [[stateDict valueForKey:kStrStateKeyQuestionsUnanswered] intValue];
		//self.activityProgress = [[stateDict valueForKey:kStrStateKeyActivityProgress] intValue];
		//self.maxQuestions = [[stateDict valueForKey:kStrStateKeyMaxQuestions] intValue];
		//self.maxTimeInSeconds = [[stateDict valueForKey:kStrStateKeyMaxTimeInSeconds] intValue];
		self.sizeOfTopScoreList = [[stateDict valueForKey:kStrStateKeySizeOfTopScoreList] intValue];
		self.appSoundState = [[stateDict valueForKey:kStrStateKeyAppSoundState] boolValue];
	}
}

@end