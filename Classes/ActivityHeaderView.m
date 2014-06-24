//
//  ActivityHeaderView.m
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. All rights reserved.
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
			activityLevelImg.image = [UIImage imageNamed:@"YellowBelt.png"];
			break;
		case kActLevelGreenBelt:
			activityLevelImg.image = [UIImage imageNamed:@"GreenBelt.png"];
			break;
		case kActLevelRedBelt:
			activityLevelImg.image = [UIImage imageNamed:@"RedBelt.png"];
			break;
		case kActLevelBlackBelt:
			activityLevelImg.image = [UIImage imageNamed:@"BlackBelt.png"];
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
