//
//  MenuViewController.m
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

#import <QuartzCore/QuartzCore.h>
#import "MenuViewController.h"
#import "ActivityViewController.h"
#import "KidsTimeFunAppState.h"
#import "HelpViewController.h"
#import "TellAFriendViewController.h"
#import "TopScoresActivitySelector.h"
#import "SettingsModalViewController.h"
#import <FloopSDK/FloopSDK.h>

@implementation MenuViewController

@synthesize tellTimeButton;
@synthesize setTimeButton;
@synthesize elapsedTimeButton;
@synthesize tellTimeAfterButton;
@synthesize tellTimeBeforeButton;
@synthesize mixedModeButton;
@synthesize topScoresButton;
@synthesize helpButton;
@synthesize tellAFriendButton;
@synthesize choiceActivityType;
@synthesize clockView;
@synthesize logoImageView;
@synthesize clipArtImageView;
@synthesize clipArtView;

@synthesize topScoresActVC;
@synthesize settingsVC;
@synthesize helpVC;
@synthesize activityVC;

NSTimer *clockTimer;
NSTimer *clipArtTimer;

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
    //Put Title - App Name/Menu
    self.title = kStrAppTitle;
    //Customize navItem - add settings button and top cores button
    UIBarButtonItem *settingsBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings"] style:UIBarButtonItemStyleBordered target:self action:@selector(settingsActivated)];
    self.navigationItem.rightBarButtonItem = settingsBarButton;
    UIBarButtonItem *topScoresBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Top Scores"] style:UIBarButtonItemStyleBordered target:self action:@selector(topScoresButtonPressed:)];
    self.navigationItem.leftBarButtonItem = topScoresBarButton;
    
    
    //[settingsBarButton release];
    //Custom Back Button - home button
    UIBarButtonItem *homeBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kImgHome] style:UIBarButtonItemStylePlain target:self action:@selector(goHome)];
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:0.055 green:0.478 blue:0.996 alpha:1.000]];
    self.navigationItem.backBarButtonItem = homeBarButton;
    [homeBarButton release];
    //set activity Type to default
    choiceActivityType.selectedSegmentIndex = [KidsTimeFunAppState sharedState].activityType;
    clipArtTimer = nil;
    clipArtImageView.frame = logoImageView.frame = CGRectMake(0, 0, clipArtView.frame.size.width, clipArtView.frame.size.height);
    clipArtImageView.contentMode = logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [clipArtView addSubview:logoImageView];
    clipArtTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(changeClipArt) userInfo:NULL repeats:YES];
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    //set labels for activity type choices
    NSString *tmpTitle = [NSString stringWithFormat:kStrVarMaxQuestions, [KidsTimeFunAppState sharedState].maxQuestions];
    [choiceActivityType setTitle:tmpTitle forSegmentAtIndex:kActTypeNumbered];
    int minutes = [KidsTimeFunAppState sharedState].maxTimeInSeconds/60;
    if (minutes == 1) tmpTitle = [NSString stringWithFormat:kStrOneMinute];
    else tmpTitle = [NSString stringWithFormat:kStrVarMaxMinutes, minutes];
    [choiceActivityType setTitle:tmpTitle forSegmentAtIndex:kActTypeTimed];
    //set timer
    [self refreshClock];
    clockTimer = nil;
    clockTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshClock) userInfo:NULL repeats:YES];
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [clockTimer invalidate];
    clockTimer = nil;
    [super viewWillDisappear:animated];
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
    [clipArtTimer invalidate];
    clipArtTimer = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [tellTimeButton release];
    [setTimeButton release];
    [elapsedTimeButton release];
    [tellTimeAfterButton release];
    [tellTimeBeforeButton release];
    [mixedModeButton release];
    [topScoresButton release];
    [helpButton release];
    [tellAFriendButton release];
    [choiceActivityType release];
    [clockView release];
    [logoImageView release];
    [clipArtImageView release];
    [clipArtView release];
    [super dealloc];
}


#pragma mark -
#pragma mark Custom Event Handlers

- (void) changeClipArt {
    RandomInteger *randomInt = [[RandomInteger alloc] initWithRange:kClipArtFileRangeLow To:kClipArtFileRangeHigh];
    clipArtImageView.image = [UIImage imageNamed:[NSString stringWithFormat:kClipArtFileMask, randomInt.randomInteger,kClipArtFileType]];
    [clipArtView replaceSubview:[[clipArtView subviews] objectAtIndex:0] withSubview:clipArtImageView transition:kCATransitionPush direction:kCATransitionFromLeft duration:0.10];
    [randomInt release];
}

- (void) refreshClock {
    //set clock
    //create date components for current date
    //NSDateComponents *dateComponents = ;
    //Hours first
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *timeComponents = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:[NSDate date]];
    clockView.hours = [timeComponents hour];
    //Then AM/PM
    //clockView.PM = [[NSDate date] AMSymbol];
    //rounded to nearest multiple of timeInterval
    clockView.minutes = [timeComponents minute];
    //No seconds for now
    clockView.seconds = [timeComponents second];
    clockView.showSeconds = YES;
    //other clock properties
    clockView.showClockAsAnalog = YES;
    clockView.showMinutesOffsetInHoursHand = YES;
    clockView.showAMPM = NO;
    clockView.showDayNight = NO;
    [clockView setNeedsDisplay];
}

- (IBAction) tellTimeButtonPressed: (id) sender {
    //ActivityViewController *activityVC = [[ActivityViewController alloc] initWithNibName:kNibActivity bundle:nil];
    [KidsTimeFunAppState sharedState].activity = kActTellTime;
    //	activityVC.activity = [KidsTimeFunAppState sharedState].activity;
    //	activityVC.activityType = [KidsTimeFunAppState sharedState].activityType;
    //	activityVC.activityLevel = [KidsTimeFunAppState sharedState].activityLevel;
    [self.navigationController pushViewController:activityVC animated:YES];
    //[activityVC release];
}

- (IBAction) setTimeButtonPressed: (id) sender {
    //	ActivityViewController *activityVC = [[ActivityViewController alloc] initWithNibName:kNibActivity bundle:nil];
    [KidsTimeFunAppState sharedState].activity = kActSetTime;
    //	activityVC.activity = [KidsTimeFunAppState sharedState].activity;
    //	activityVC.activityType = [KidsTimeFunAppState sharedState].activityType;
    //	activityVC.activityLevel = [KidsTimeFunAppState sharedState].activityLevel;
    [self.navigationController pushViewController:activityVC animated:YES];
    //	[activityVC release];
}

- (IBAction) elapsedTimeButtonPressed: (id) sender {
    //	ActivityViewController *activityVC = [[ActivityViewController alloc] initWithNibName:kNibActivity bundle:nil];
    [KidsTimeFunAppState sharedState].activity = kActElapsedTime;
    //	activityVC.activity = [KidsTimeFunAppState sharedState].activity;
    //	activityVC.activityType = [KidsTimeFunAppState sharedState].activityType;
    //	activityVC.activityLevel = [KidsTimeFunAppState sharedState].activityLevel;
    [self.navigationController pushViewController:activityVC animated:YES];
    //	[activityVC release];
}

- (IBAction) tellTimeAfterButtonPressed: (id) sender {
    //	ActivityViewController *activityVC = [[ActivityViewController alloc] initWithNibName:kNibActivity bundle:nil];
    [KidsTimeFunAppState sharedState].activity = kActTimeAfter;
    //	activityVC.activity = [KidsTimeFunAppState sharedState].activity;
    //	activityVC.activityType = [KidsTimeFunAppState sharedState].activityType;
    //	activityVC.activityLevel = [KidsTimeFunAppState sharedState].activityLevel;
    [self.navigationController pushViewController:activityVC animated:YES];
    //	[activityVC release];
}

- (IBAction) tellTimeBeforeButtonPressed: (id) sender {
    //	ActivityViewController *activityVC = [[ActivityViewController alloc] initWithNibName:kNibActivity bundle:nil];
    [KidsTimeFunAppState sharedState].activity = kActTimeBefore;
    //	activityVC.activity = [KidsTimeFunAppState sharedState].activity;
    //	activityVC.activityType = [KidsTimeFunAppState sharedState].activityType;
    //	activityVC.activityLevel = [KidsTimeFunAppState sharedState].activityLevel;
    [self.navigationController pushViewController:activityVC animated:YES];
    //	[activityVC release];
}

- (IBAction) mixedModeButtonPressed: (id) sender {
    //	ActivityViewController *activityVC = [[ActivityViewController alloc] initWithNibName:kNibActivity bundle:nil];
    [KidsTimeFunAppState sharedState].activity = kActMixed;
    //	activityVC.activity = [KidsTimeFunAppState sharedState].activity;
    //	activityVC.activityType = [KidsTimeFunAppState sharedState].activityType;
    //	activityVC.activityLevel = [KidsTimeFunAppState sharedState].activityLevel;
    [self.navigationController pushViewController:activityVC animated:YES];
    //	[activityVC release];
}

- (IBAction) topScoresButtonPressed: (id) sender {
    //	TopScoresActivitySelector *topScoresActVC = [[TopScoresActivitySelector alloc] initWithNibName:@"TopScoresActivitySelectorView" bundle:nil];
    [self.navigationController pushViewController:self.topScoresActVC animated:YES];
    
    //	[topScoresActVC release];
}

- (IBAction) helpButtonPressed: (id) sender {
    //HelpViewController *helpVC = [[HelpViewController alloc] initWithNibName:kNibHelp bundle:nil];
    [self.navigationController pushViewController:self.helpVC animated:YES];
    //[helpVC release];
}

- (IBAction) tellAFriendButtonPressed: (id) sender {
    
    /*
     NSString *recipients = @"mailto:  ?subject=Learn to Tell Time";
     NSString *body = @"&body=Please check out this really cool app:  http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=318350766&mt=8";
     
     
     NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
     email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
     
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
     
     TellAFriendViewController *tellAFriendVC = [[TellAFriendViewController alloc] initWithNibName:kNibTellAFriend bundle:nil];
     [self.navigationController pushViewController:tellAFriendVC animated:YES];
     [tellAFriendVC release];
     */
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


- (IBAction) setActivityType: (id) sender {
    [KidsTimeFunAppState sharedState].activityType = (int) [sender selectedSegmentIndex];
}

- (IBAction) settingsActivated {
    if ([self.navigationController topViewController] == self) {
        [self.navigationController pushViewController:settingsVC animated:YES];
    }
}

//#pragma mark -
//#pragma mark DissmissSettings Protocol Methods
//
//- (void) didDismissSettings: (id)sender {
//	[self dismissModalViewControllerAnimated:YES];
//}

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
            message = @"User cancelled";
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

// Application Launcher
- (IBAction) launchApp:(id)sender {
    
    UIButton *buttonClicked = (UIButton *)sender;
    
    NSString* appLauchFilePath = [[NSBundle mainBundle] pathForResource:@"AppLaunchInfo" ofType:@"plist"];
    NSURL *appLaunchFileURL = [NSURL fileURLWithPath:appLauchFilePath];
    NSArray *appLauchInfo = [NSArray arrayWithContentsOfURL:appLaunchFileURL];
    
    UIApplication *ourApplication = [UIApplication sharedApplication];
    NSInteger ourAppIndex = buttonClicked.tag-700;
    NSDictionary *ourApp = appLauchInfo[ourAppIndex];
    NSURL *AppLaunchURL = [NSURL URLWithString:ourApp[@"AppLaunchURL"]];
    NSURL *appStoreURL = [NSURL URLWithString:ourApp[@"AppStoreURL"]];
    
    if ([ourApplication canOpenURL:AppLaunchURL]) {
        [ourApplication openURL:AppLaunchURL];
    }
    else {
        [[FloopSdkManager sharedInstance] showParentalGate:^(BOOL success) {
            if(success)
            {
                [ourApplication openURL:appStoreURL];
            }
            ;}];
    }
}
@end
