//
//  SettingsModalViewController.h
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

//@protocol DismissSettings <NSObject>
//- (void)didDismissSettings:(id)sender;
//@end

@interface SettingsModalViewController : UIViewController {
	//id<DismissSettings> delegate;
	BOOL isDirty;
	int numberOfQuestions;
	int numberOfMinutes;
	int activityLevel;
	BOOL playSoundInApplication;
	@private
		IBOutlet UISlider *numberOfQuestionsSlider;
		IBOutlet UISlider *numberOfMinutesSlider;
		IBOutlet UISegmentedControl *activityLevelChoiceControl;
		IBOutlet UILabel *numberOfQuestionsLabel;
		IBOutlet UILabel *numberOfMinutesLabel;
		IBOutlet UIView *activityLevelDescriptionDropDownView;
		IBOutlet UILabel *activityLevelLabel;
		IBOutlet UILabel *activityLevelDescriptionLabel;
		IBOutlet UISwitch *playSoundDecider;
}

- (IBAction) maxNumberOfQuestionsChanged: (id) sender;
- (IBAction) maxNumberOfMinutesChanged: (id) sender;
- (IBAction) activityLevelChoiceChanged: (id) sender;
- (IBAction) settingsDone: (id) sender;
- (IBAction) playSound: (id)sender;

//@property (assign) id delegate;
@property (assign) BOOL isDirty;
@property (assign) int numberOfQuestions;
@property (assign) int numberOfMinutes;
@property (assign) int activityLevel;
@property (assign) BOOL playSoundInApplication;
@end
