// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Copyright 2026 Island Innovation LLC.  All rights reserved.

/*

File: TransitionView.m

Apple Sample Code 

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import <QuartzCore/QuartzCore.h>
#import "TransitionView.h"

#define kAnimationKey @"transitionViewAnimation"

@implementation TransitionView

@synthesize delegate, transitioning;

// Method to replace a given subview with another using a specified transition type, direction, and duration
- (void)replaceSubview:(UIView *)oldView withSubview:(UIView *)newView transition:(NSString *)transition direction:(NSString *)direction duration:(NSTimeInterval)duration {
	
	// If a transition is in progress, do nothing
	if (transitioning) {
		return;
	}
	
	NSArray *subViews = [self subviews];
	NSUInteger index = -1;
	
	if ([oldView superview] == self) {
		// Find the index of oldView so that we can insert newView at the same place
		for(index = 0; [subViews objectAtIndex:index] != oldView; ++index) {}
		[oldView removeFromSuperview];
	}
	
	// If there's a new view and it doesn't already have a superview, insert it where the old view was
	if (newView && ([newView superview] == nil))
		[self insertSubview:newView atIndex:index];
	
	
	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	// Set the type and if appropriate direction of the transition, 
	if (transition == kCATransitionFade) {
		[animation setType:kCATransitionFade];
	} else {
		[animation setType:transition];
		[animation setSubtype:direction];
	}
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:duration];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[self layer] addAnimation:animation forKey:kAnimationKey];
}


// Not used in this example, but may be useful in your own project
- (void)cancelTransition {
	// Remove the animation -- cleanup performed in animationDidStop:finished:
	[[self layer] removeAnimationForKey:kAnimationKey];
}


- (void)animationDidStart:(CAAnimation *)animation {
	
	transitioning = YES;
    
	// Record the current value of userInteractionEnabled so it can be reset in animationDidStop:finished:
	wasEnabled = self.userInteractionEnabled;
	
	// If user interaction is not already disabled, disable it for the duration of the animation
	if (wasEnabled) {
		self.userInteractionEnabled = NO;
    }
    
	// Inform the delegate if the delegate implements the corresponding method
	if ([delegate respondsToSelector:@selector(transitionViewDidStart:)]) {
		[delegate transitionViewDidStart:self];
    }
}


- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished {
	
	transitioning = NO;
	
	// Reset the original value of userInteractionEnabled
	if (wasEnabled) {
		self.userInteractionEnabled = YES;
	}
    
	// Inform the delegate if it implements the corresponding method
	if (finished) {
		if ([delegate respondsToSelector:@selector(transitionViewDidFinish:)]) {
			[delegate transitionViewDidFinish:self];
        }
	}
	else {
		if ([delegate respondsToSelector:@selector(transitionViewDidCancel:)]) {
			[delegate transitionViewDidCancel:self];
        }
	}
}


@end
