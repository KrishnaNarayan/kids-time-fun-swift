//
//  TellAFriendViewController.h
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
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface TellAFriendViewController : UIViewController <MFMailComposeViewControllerDelegate> {
	NSString* message;
}

-(void)displayComposerSheet;
-(void)launchMailAppOnDevice;
-(IBAction)tellAFirend:(id)sender;
@end
