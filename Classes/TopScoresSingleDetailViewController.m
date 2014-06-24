//
//  TopScoresSingleDetailViewController.m
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. All rights reserved.
//

#import "TopScoresSingleDetailViewController.h"
#import "KidsTimeFunAppState.h"

@implementation TopScoresSingleDetailViewController

@synthesize activity;
@synthesize activityType;
@synthesize activityLevel;
@synthesize scoresArray;

- (id)initWithActivity:(int)act andType:(int)type andLevel:(int)level withNibName: (NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNil {
	self.activity = act;
	self.activityType = type;
	self.activityLevel = level;
	return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = kStrTopScores;
	[self loadScoreForActivity:self.activity andType:self.activityType andLevel:self.activityLevel];
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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (([scoresArray count]>0)?[scoresArray count]:1);
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Activity";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
//		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		if ([scoresArray count] > 0) {
			NSDictionary *score = [scoresArray objectAtIndex:indexPath.row];
			NSMutableString *cellText = [[NSMutableString alloc] init];
			[cellText appendFormat:@"%i", (indexPath.row+1)];
			[cellText appendString:@". "];
			[cellText appendString:[score valueForKey:kPlayerName]];
			[cellText appendString:@", "];
			if (self.activityType == kActTypeNumbered) {
				[cellText appendFormat:@"%1.0f%%", [[score valueForKey:kPercentScore] floatValue]*100.0f];
				[cellText appendString:@", "];
				[cellText appendFormat:@"%i right",[[score valueForKey:kRightAnswers] intValue]];
				[cellText appendString:@", "];
				[cellText appendFormat:@"%i wrong", [[score valueForKey:kWrongAnswers] intValue]];
				[cellText appendString:@", "];
			}
			else {
				[cellText appendFormat:@"%i questions", [[score valueForKey:kRightAnswers] intValue] + [[score valueForKey:kWrongAnswers] intValue]];
				[cellText appendString:@", "];
			}
			[cellText appendFormat:@"%i sec",[[score valueForKey:kSecondsTaken] intValue]];
			cell.textLabel.text = [NSString stringWithString:cellText];
			[cellText release];
		}
		else cell.textLabel.text = kStrBlank ;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
		{
			cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0f];
		}
		else 
		{
			cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];	
		}
	}
	// Configure the cell.
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	return 24;
//}

/*
// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
*/

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void) loadScoreForActivity: (int)activity andType: (int)activityType andLevel: (int)activityLevel {
	//create scores Array
	//Now get the file name - root for documents directory + "/Scores/"
	NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *filePath = [docPath stringByAppendingString:@"/"];
	NSString *fileName = [NSString stringWithFormat:kFileVarScores,self.activity,self.activityType,self.activityLevel];
	NSString *fileNameWithPath = [filePath stringByAppendingString:fileName];
	//Now read scores array from disk
	scoresArray = [[NSArray alloc] initWithContentsOfFile:fileNameWithPath];
}

- (void)dealloc {
	[scoresArray release];
    [super dealloc];
}


@end
