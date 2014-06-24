//
//  TopScoresDetailViewController.h
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


@interface TopScoresDetailViewController : UITabBarController {
	int activity;
	int activityType;
	int activityLevel;
	BOOL showActivityTypeSelection;
}

- (id) initWithActivity: (int)activity andType: (int)activityType andLevel: (int)activityLevel showActivityTypeSelection: (BOOL)showActivityTypeSelection withNibName: (NSString *)nibNameOrNil andBundle: (NSBundle *)nibBundleOrNil;

@property (assign) int activity;
@property (assign) int activityType;
@property (assign) int activityLevel;
@property (assign) BOOL showActivityTypeSelection;

@end
