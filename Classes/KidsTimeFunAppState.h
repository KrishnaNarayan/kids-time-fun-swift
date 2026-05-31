//
//  KidsTimeFunAppState.h
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

#import <Foundation/Foundation.h>
#import "KidsTimeFunAppConstants.h"

@interface KidsTimeFunAppState : NSObject {
	NSString *playerName;
	int screen;
	int activity;
	int activityType;
	int activityLevel;
	int questionNumber;
	int questionsRight;
	int questionsWrong;
	int questionsUnanswered;
	int activityProgress;
	int maxQuestions;
	int maxTimeInSeconds;
	int sizeOfTopScoreList;
	BOOL appSoundState;
}

+(KidsTimeFunAppState *) sharedState;
-(void) flushState;
-(void) resumeFromState;
-(void) readSettings;

@property (retain) NSString *playerName;
@property (assign) int screen;
@property (assign) int activity;
@property (assign) int activityType;
@property (assign) int activityLevel;
@property (assign) int questionNumber;
@property (assign) int questionsRight;
@property (assign) int questionsWrong;
@property (assign) int questionsUnanswered;
@property (assign) int activityProgress;
@property (assign) int maxQuestions;
@property (assign) int maxTimeInSeconds;
@property (assign) int sizeOfTopScoreList;
@property (assign) BOOL appSoundState;

@end
