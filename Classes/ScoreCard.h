//
//  ScoreCard.h
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

#import <UIKit/UIKit.h>
#import "KidsTimeFunAppState.h"

@interface ScoreCard : NSObject {
	NSString *playerName;
	int activity;
	int activityType;
	int activityLevel;
	int questionsAsked;
	int questionsAttempted;
	int rightAnswers;
	int wrongAnswers;
	float percentScore;
	int secondsTaken;
	int scoreRank;
	NSDate *scoreDateTime;
	NSDictionary *scoreCard;
	BOOL isTopScore;
}

- (NSDictionary *) newScoreCard;
- (BOOL) writeScoreCard;

@property (retain, nonatomic) NSString *playerName;
@property (assign, nonatomic) int activity;
@property (assign, nonatomic) int activityType;
@property (assign, nonatomic) int activityLevel;
@property (assign, nonatomic) int questionsAsked;
@property (assign, nonatomic) int questionsAttempted;
@property (assign, nonatomic) int rightAnswers;
@property (assign, nonatomic) int wrongAnswers;
@property (assign, nonatomic) float percentScore;
@property (assign, nonatomic) int secondsTaken;
@property (readonly, nonatomic) int scoreRank;
@property (readonly, nonatomic) NSDate *scoreDateTime;
@property (readonly, nonatomic) NSDictionary *scoreCard;
@property (readonly, nonatomic) BOOL isTopScore;

@end
