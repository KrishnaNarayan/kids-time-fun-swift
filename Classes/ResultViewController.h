//
//  ResultViewController.h
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KidsTimeFunAppState.h"

@class ScoreCard;

@protocol DismissResultDelegate <NSObject>
- (void) didDismissResult: (id)sender;
@end

@interface ResultViewController : UIViewController {
	id<DismissResultDelegate> delegate;
	int scoreRank;
	int rightAnswers;
	int wrongAnswers;
	int totalQuestions;
	float percentScore;
	int timeTakenInSeconds;
@private
	IBOutlet UILabel *lblScoreMessage;
	IBOutlet UIImageView *imgViewTopScore;
	IBOutlet UILabel *lblScoreRank;
	IBOutlet UITextField *txtName;
	IBOutlet UIButton *btnSave;
	IBOutlet UILabel *lblRightAnswers;
	IBOutlet UILabel *lblWrongAnswers;
	IBOutlet UILabel *lblPercentScore;
	IBOutlet UILabel *lblTotalQuestions;
	IBOutlet UILabel *lblTimeTaken;
	IBOutlet UIButton *btnDone;
	IBOutlet UIButton *btnDismissKeyboard;
	IBOutlet UIView *headerView;
	IBOutlet UIView *topScoreHeaderView;
	IBOutlet UIView *noTopScoreHeaderView;
}

- (IBAction) dismissKeyboard;
- (IBAction) saveScore;
- (IBAction) done;

@property (assign) id delegate;
@property (assign) int scoreRank;
@property (assign) int rightAnswers;
@property (assign) int wrongAnswers;
@property (assign) int totalQuestions;
@property (assign) float percentScore;
@property (assign) int timeTakenInSeconds;

@end
