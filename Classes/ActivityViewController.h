//
//  ActivityViewController.h
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TellTimeViewController.h"
#import "ElapsedTimeViewController.h"
#import "SetTimeViewController.h"
#import "ResultViewController.h"

@class TransitionView;
@class ActivityHeaderView;

@interface ActivityViewController : UIViewController <DismissResultDelegate, DismissActivityDelegate> {
	//define activity
	int activity;
	int activityType;
	int activityLevel;
	//define limits and progress
	int maxQuestions;
	int maxSeconds;
	int currentQuestion;
	int elapsedSeconds;
	//define scoring parameters
	int questionsAsked;
	int questionsAttempted;
	int rightAnswers;
	int wrongAnswers;
	int secondsTaken;
	float percentScore;
	//define activity state
	int activityState;
	//define variable for transitionview, also the base view for activity
	TransitionView *transView;
	UIView *composite;
	ActivityHeaderView *header;
	UIView *content;
	UIImageView *activityBG;
	NSTimer *timer;
	NSDate *startTime;
	NSDate *endTime;
}

- (void) loadActivity:(int)thisActivity;
- (void) loadResultsView: (id) sender;
- (void) loadTopScoresView: (id) sender;

@property (nonatomic, assign) int activity;
@property (nonatomic, assign) int activityType;
@property (nonatomic, assign) int activityLevel;
@property (nonatomic, assign) int maxQuestions;
@property (nonatomic, assign) int maxSeconds;
@property (nonatomic, readonly) int currentQuestion;
@property (nonatomic, readonly) int elapsedSeconds;
@property (nonatomic, readonly) int questionsAsked;
@property (nonatomic, readonly) int questionsAttempted;
@property (nonatomic, readonly) int rightAnswers;
@property (nonatomic, readonly) int wrongAnswers;
@property (nonatomic, readonly) int secondsTaken;
@property (nonatomic, readonly) float percentScore;
@property (nonatomic, readonly) int activityState;
@property (nonatomic, retain) IBOutlet TransitionView *transView;
@property (nonatomic, retain) IBOutlet UIView *composite;
@property (nonatomic, retain) IBOutlet ActivityHeaderView *header;
@property (nonatomic, retain) IBOutlet UIView *content;
@property (nonatomic, retain) IBOutlet UIImageView *activityBG;
@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSDate *endTime;

@property (nonatomic, retain) ElapsedTimeViewController *etvc;
@property (nonatomic, retain) SetTimeViewController *stvc;
@property (nonatomic, retain) TellTimeViewController *ttvc;
//@property (nonatomic, retain) IBOutlet ResultViewController *resultVC;
@end
