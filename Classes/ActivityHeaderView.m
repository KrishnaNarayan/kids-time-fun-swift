//
//  ActivityHeaderView.m
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

#import "ActivityHeaderView.h"
#import "KidsTimeFunAppState.h"

@implementation ActivityHeaderView
@synthesize activityLevel;
@synthesize right;
@synthesize wrong;
@synthesize current;
@synthesize total;
@synthesize showTotal;
@synthesize showTimer;
@synthesize countdownTimer;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
   }
    return self;
}

- (void)drawRect:(CGRect)rect {
	
	switch (activityLevel) {
		case kActLevelYellowBelt:
			activityLevelImg.image = [UIImage imageNamed:@"Yellow Belt"];
			break;
		case kActLevelGreenBelt:
			activityLevelImg.image = [UIImage imageNamed:@"Green Belt"];
			break;
		case kActLevelRedBelt:
			activityLevelImg.image = [UIImage imageNamed:@"Red Belt"];
			break;
		case kActLevelBlackBelt:
			activityLevelImg.image = [UIImage imageNamed:@"Black Belt"];
			break;
		default:
			break;
	}
	
	if (showTimer) {
		timerImg.hidden = NO;
		countdownLabel.hidden = NO;
		showTotal = NO;
	}
	else {
		timerImg.hidden = YES;
		countdownLabel.hidden = YES;
	}
	rightLabel.text = [NSString stringWithFormat:@"%i", right];
	wrongLabel.text = [NSString stringWithFormat:@"%i", wrong];
	if (showTotal) {
		pageLabel.text = [NSString stringWithFormat:@"%i/%i", current, total];	
	}
	else {
		pageLabel.text = [NSString stringWithFormat:@"%i", current];
	}
	countdownLabel.text = [NSString stringWithFormat:@"%i", self.countdownTimer];
    if (countdownTimer < 10) [countdownLabel setTextColor:[UIColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:1.0]]; 
}


- (void)dealloc {
    [super dealloc];
}

@end
