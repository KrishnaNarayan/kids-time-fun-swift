//
//  SetClockView.h
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/19/09.
//  Modified by SVV Satyanarayana, under contract to NSC Partners LLC on 28/04/10.
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Copyright 2026 Island Innovation LLC.  All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetClockView : UIView {
	float hours, xx, yy, r_h, r_m, theta, r, x_c, y_c, theta_h, theta_m;
	float minutes, thetaHoursHand, thetaMinutesHand, thetaTouch, xHourHand, yHourHand, xMinuteHand, yMinuteHand;
	//float pi;
	BOOL showMinutesOffsetInHoursHand, minuteHandFlag, hourHandFlag, firstPass;

}

@property (assign, nonatomic) float hours;
@property (assign, nonatomic) float minutes;
@property (assign, nonatomic) BOOL showMinutesOffsetInHoursHand;

@end
