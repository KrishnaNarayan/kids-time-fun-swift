//
//  TellTimeViewController.h
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved..
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class ClockView;
@class RandomInteger;

@interface TellTimeViewController : BaseViewController {
	id<DismissActivityDelegate> delegate;
	BOOL isRight;
	int activity;
	int activityType;
	int activityLevel;
	int timeOffset;
	int answerIndex;
	int wrongCounter;
  @private
	IBOutlet UIView *clockContainerView;
	ClockView *clockView;
	RandomInteger *randomNumber;
	IBOutlet UISegmentedControl *choices;
	IBOutlet UISegmentedControl *choices2;
	IBOutlet UISegmentedControl *choices3;
	IBOutlet UISegmentedControl *choices4;
	IBOutlet UIImageView *rightOrWrong;
	IBOutlet UIImageView *rightOrWrong2;
	IBOutlet UILabel *labelQuestion;
}

- (IBAction) choicesValueChanged;

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) BOOL isRight;
@property (nonatomic, assign) int activity;
@property (nonatomic, assign) int activityType;
@property (nonatomic, assign) int activityLevel;
@property (nonatomic, assign) int timeOffset;
@property (nonatomic, assign) int answerIndex;

@end
