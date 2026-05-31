//
//  MenuViewController.h
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Modified by SVV Satyanarayana, under contract to NSC Partners LLC on 28/04/10.
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Copyright 2026 Island Innovation LLC.  All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsModalViewController.h"
#import "ClockView.h"
#import "TransitionView.h"
#import "RandomInteger.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class TopScoresActivitySelector;
@class SettingsModalViewController;
@class HelpViewController;
@class ActivityViewController;

@interface MenuViewController : UIViewController </*DismissSettings, */MFMailComposeViewControllerDelegate> {
	UIButton *tellTimeButton;
	UIButton *setTimeButton;
	UIButton *elapsedTimeButton;
	UIButton *tellTimeAfterButton;
	UIButton *tellTimeBeforeButton;
	UIButton *mixedModeButton;
	UIButton *topScoresButton;
	UIButton *helpButton;
	UIButton *tellAFriendButton;
	UISegmentedControl *choiceActivityType;
	TransitionView *clipArtView;
	UIImageView *logoImageView;
	UIImageView *clipArtImageView;
	ClockView *clockView;
	NSString* message;
	HelpViewController *helpVC;
	ActivityViewController *activityVC;
}

- (void) refreshClock;
- (void) changeClipArt;
- (IBAction) tellTimeButtonPressed: (id) sender;
- (IBAction) setTimeButtonPressed: (id) sender;
- (IBAction) elapsedTimeButtonPressed: (id) sender;
- (IBAction) tellTimeAfterButtonPressed: (id) sender;
- (IBAction) tellTimeBeforeButtonPressed: (id) sender;
- (IBAction) mixedModeButtonPressed: (id) sender;
- (IBAction) topScoresButtonPressed: (id) sender;
- (IBAction) helpButtonPressed: (id) sender;
- (IBAction) tellAFriendButtonPressed: (id) sender;
- (IBAction) setActivityType: (id) sender;
- (IBAction) settingsActivated;



@property (retain, nonatomic) IBOutlet UIButton *tellTimeButton;
@property (retain, nonatomic) IBOutlet UIButton *setTimeButton;
@property (retain, nonatomic) IBOutlet UIButton *elapsedTimeButton;
@property (retain, nonatomic) IBOutlet UIButton *mixedModeButton;
@property (retain, nonatomic) IBOutlet UIButton *tellTimeAfterButton;
@property (retain, nonatomic) IBOutlet UIButton *tellTimeBeforeButton;
@property (retain, nonatomic) IBOutlet UIButton *topScoresButton;
@property (retain, nonatomic) IBOutlet UIButton *helpButton;
@property (retain, nonatomic) IBOutlet UIButton *tellAFriendButton;
@property (retain, nonatomic) IBOutlet UISegmentedControl *choiceActivityType;
@property (retain, nonatomic) IBOutlet ClockView *clockView;
@property (retain, nonatomic) IBOutlet UIImageView *logoImageView;
@property (retain, nonatomic) IBOutlet UIImageView *clipArtImageView;
@property (retain, nonatomic) IBOutlet TransitionView *clipArtView;

@property(nonatomic, retain) IBOutlet TopScoresActivitySelector* topScoresActVC;
@property(nonatomic, retain) IBOutlet SettingsModalViewController* settingsVC;
@property(nonatomic, retain) IBOutlet HelpViewController *helpVC;
@property(nonatomic, retain) IBOutlet ActivityViewController *activityVC;
-(void)displayComposerSheet;
-(void)launchMailAppOnDevice;
- (IBAction) launchApp:(id)sender;
@end
