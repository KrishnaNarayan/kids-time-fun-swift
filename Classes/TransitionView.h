// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Copyright 2026 Island Innovation LLC.  All rights reserved.

/*

File: TransitionView.h

Apple sample code

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import <UIKit/UIKit.h>


// A protocol to inform a delegate of transition events.
// The delegate is not used in this example, but it may be useful for you in your own projects.

@class TransitionView;

@protocol TransitionViewDelegate <NSObject>
@optional
- (void)transitionViewDidStart:(TransitionView *)view;
- (void)transitionViewDidFinish:(TransitionView *)view;
- (void)transitionViewDidCancel:(TransitionView *)view;
@end


// This class uses the built-in Core Animation transitions to animate the replacement of a given subview by a new one.

@interface TransitionView : UIView
{
@private
	BOOL transitioning, wasEnabled;
	id<TransitionViewDelegate> delegate;
}

@property (assign) id<TransitionViewDelegate> delegate;
@property (readonly, getter=isTransitioning) BOOL transitioning;

- (void)replaceSubview:(UIView *)oldView withSubview:(UIView *)newView transition:(NSString *)transition direction:(NSString *)direction duration:(NSTimeInterval)duration;
- (void)cancelTransition;

@end
