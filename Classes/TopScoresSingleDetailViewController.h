//
//  TopScoresSingleDetailViewController.h
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

@interface TopScoresSingleDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	int activity;
	int activityType;
	int activityLevel;
	NSArray *scoresArray;
	
}

- (id)initWithActivity:(int)act andType:(int)type andLevel:(int)level withNibName: (NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNi;
- (void) loadScoreForActivity: (int)activity andType: (int)activityType andLevel: (int)activityLevel;

@property (assign) int activity;
@property (assign) int activityType;
@property (assign) int activityLevel;
@property (retain) NSArray *scoresArray;
@end
