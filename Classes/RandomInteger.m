//
//  RandomInteger.m
//  MathFlashCards
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

#import "RandomInteger.h"

@implementation RandomInteger

@synthesize rangeLow;
@synthesize rangeHigh;
@synthesize randomInteger;

- (id) init {
	if (self = [super init]) {
		srandom((unsigned int)time(NULL));
	}
	return self;
}

- (id) initWithRange: (int)low To: (int)high {
//	[self init];    //satyam
    if (self = [super init])
    {
        self.rangeLow = low;
        self.rangeHigh = high;
    }
	return self;
}
		
- (int) nextRandomInteger {
	int r;
	r = random() % (self.rangeHigh-self.rangeLow+1) + self.rangeLow; //generate a random number in given range
	srandom((unsigned int)time(NULL)*(unsigned int)random()); //seed again, this time with a random number
	return r;
}

- (int) nextRandomIntegerInRange: (int)low To: (int)high {
	self.rangeLow = low;
	self.rangeHigh = high;
	return [self nextRandomInteger];
}

@end