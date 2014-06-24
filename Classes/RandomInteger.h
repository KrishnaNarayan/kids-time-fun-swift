//
//  RandomInteger.h
//  MathFlashCards
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <stdlib.h>

@interface RandomInteger : NSObject {
	int rangeLow;
	int rangeHigh;
	int randomInteger;
}

- (id) initWithRange: (int)low To: (int)high;
- (int) nextRandomInteger;
- (int) nextRandomIntegerInRange: (int)low To: (int)high;

@property (assign) int rangeLow;
@property (assign) int rangeHigh;
@property (readonly, getter=nextRandomInteger) int randomInteger;

@end
