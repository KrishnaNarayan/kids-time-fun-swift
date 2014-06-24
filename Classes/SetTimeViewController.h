//
//  SetTimeViewController.h
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/30/09.
//
//  Copyright 2009-2013 NSC Partners LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class SetClockView;
@class RandomInteger;

@interface SetTimeViewController : BaseViewController {
	id<DismissActivityDelegate> delegate;
	BOOL isRight;
	int activity;
	int activityType;
	int activityLevel;
	int timeOffset;
	int wrongCounter;
  @private
	IBOutlet UIView *clockContainerView;
	IBOutlet UIView *hourHand, *minuteHand;
	SetClockView *setClockView;
	RandomInteger *randomNumber;
	IBOutlet UIImageView *rightOrWrong2;
	IBOutlet UIImageView *rightOrWrong;
	IBOutlet UILabel *labelQuestion;
	int setHours, setMinutes;
}

- (IBAction) setTimeButtonPushed;

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) BOOL isRight;
@property (nonatomic, assign) int activity;
@property (nonatomic, assign) int activityType;
@property (nonatomic, assign) int activityLevel;
@property (nonatomic, assign) int timeOffset;

- (void) rightAnswer;
- (void) wrongAnswer;

@end
