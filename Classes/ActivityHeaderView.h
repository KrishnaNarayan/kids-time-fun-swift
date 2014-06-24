//
//  ActivityHeaderView.h
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. All rights reserved.d.
//

#import <UIKit/UIKit.h>


@interface ActivityHeaderView : UIView {
	int activityLevel;
	int right;
	int wrong;
	int current;
	int total;
	BOOL showTotal;
	BOOL showTimer;
	int countdownTimer;
  @private
	IBOutlet UILabel *rightLabel;
	IBOutlet UILabel *wrongLabel;
	IBOutlet UILabel *countdownLabel;
	IBOutlet UILabel *pageLabel;
	IBOutlet UIImageView *timerImg;
	IBOutlet UIImageView *activityLevelImg;
}

@property (assign) int activityLevel;
@property (assign) int right;
@property (assign) int wrong;
@property (assign) int current;
@property (assign) int total;
@property (assign) BOOL showTotal;
@property (assign) BOOL showTimer;
@property (assign) int countdownTimer;

@end
