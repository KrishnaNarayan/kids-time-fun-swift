//
//  TellAFriendViewController.m
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
//

#import "TellAFriendViewController.h"


@implementation TellAFriendViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
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
	self.title = kStrTellAFriend;
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

#pragma mark -
#pragma mark Compose Mail

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet 
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"Kids Time Fun App"];
	
	
	// Set up recipients
	//NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"]; 
	
	//[picker setToRecipients:toRecipients];
	

	// Fill out the email body text
	NSString *emailBody = @"Please try this really cool app:  http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=318350766";
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentViewController:picker animated:YES completion:nil];
    [picker release];
}


// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			message = @"Your information saved successfully";
			break;
		case MFMailComposeResultSent:
			message = @"Your friends were informed about this application";
			break;
		case MFMailComposeResultFailed:
			message = @"Sorry, I couldn't inform your friend. Try again";
			break;
		default:
			message = @"Result: not sent";
			break;
	}
	[self dismissViewControllerAnimated:YES completion:nil];
	UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Tell A Friend" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[av show];
	[av release];
}


#pragma mark -
#pragma mark Workaround

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
	NSString *recipients = @"mailto:?subject=Learn To Tell Time--Kids iPhone/iPod/iPad App!";
	NSString *body = @"&body=Please try this really cool app:  http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=318350766";
	
	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

-(IBAction)tellAFirend:(id)sender
{
	//Check whether the device can be able to show in-app mail. Else show normal mail
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])	
		{
			[self displayComposerSheet];
		}
		else
		{
			[self launchMailAppOnDevice];
		}
	}
	else
	{
		[self launchMailAppOnDevice];
	}	
}

@end
