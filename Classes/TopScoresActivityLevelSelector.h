//
//  TopScoresActivityLevelSelector.h
//  ScoresDisplay
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
//

@interface TopScoresActivityLevelSelector : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	int activity;
	int activityLevel;
}

@property int activity;
@property int activityLevel;


@end
