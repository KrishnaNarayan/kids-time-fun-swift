//
//  ScoreViewController.m
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
//

#import "ScoreViewController.h"
#import "KidsTimeFunAppState.h"

@implementation ScoreViewController

/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	/*		NSString *topScoreAlertTitle = [NSString stringWithString:kStrTopScoreMessage];
		if (yourScoreCard.isTopScore) {
			UIAlertView *topScoreAlert = [[UIAlertView alloc] initWithTitle:topScoreAlertTitle message:kStrTopScoreMessage delegate:self cancelButtonTitle:@"Record" otherButtonTitles:nil];
			NSString *textFieldDefault = [[NSString alloc] init];
			if ([yourScoreCard.playerName isEqualToString:kStrBlank] || [yourScoreCard.playerName isEqualToString:kDefaultPlayerName]) {
				textFieldDefault = kStrBlank;
			}
			else {
				textFieldDefault = yourScoreCard.playerName;
			}

			[topScoreAlert addTextFieldWithValue:textFieldDefault label:kStrYourNameHereMessage];
			[topScoreAlert show];
			[textFieldDefault release];
			[topScoreAlert release];
		}
	 */
	[super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
