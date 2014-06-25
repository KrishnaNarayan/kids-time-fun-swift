//
//  ClockView.h
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClockView : UIView {
	float hours;
	float minutes;
	float seconds;
	BOOL PM;
	BOOL showSeconds;
	BOOL showClockAsAnalog;
	BOOL showMinutesOffsetInHoursHand;
	BOOL showAMPM;
	BOOL showDayNight;
}

@property (assign, nonatomic) float hours;
@property (assign, nonatomic) float minutes;
@property (assign, nonatomic) float seconds;
@property (assign, nonatomic) BOOL PM;
@property (assign, nonatomic) BOOL showSeconds;
@property (assign, nonatomic) BOOL showClockAsAnalog;
@property (assign, nonatomic) BOOL showMinutesOffsetInHoursHand;
@property (assign, nonatomic) BOOL showAMPM;
@property (assign, nonatomic) BOOL showDayNight;

@end
