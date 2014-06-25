//
//  TopScoresActivitySelector.m
//  ScoresDisplay
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. All rights reserved.
//

#import "TopScoresActivitySelector.h"
#import "KidsTimeFunAppState.h"
#import "TopScoresActivityLevelSelector.h"

@implementation TopScoresActivitySelector

@synthesize activity;

- (void)viewDidLoad {
	self.title = kStrTopScores;
	UIBarButtonItem *homeBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TopScores20.png"] style:UIBarButtonItemStyleBordered target:self action:nil];
	self.navigationItem.backBarButtonItem = homeBarButton;
	[homeBarButton release];	
	[super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kNumberOfActivities;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Activity";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
	NSLog(@"Index path is %ld",(long)indexPath.row);
	// Configure the cell.
	switch (indexPath.row) {
		case kActTellTime:
			cell.imageView.image = [UIImage imageNamed:@"TellTimeOrange.png"];
			//cell.text = kStrTellTime;
			break;
		case kActSetTime:
			cell.imageView.image = [UIImage imageNamed:@"SetTimeMagenta.png"];
			//cell.text = kStrSetTime;
			break;
		case kActTimeAfter:
			cell.imageView.image = [UIImage imageNamed:@"TimeAfterStrawberry.png"];
			//cell.text = kStrTimeAfter;
			break;
		case kActTimeBefore:
			cell.imageView.image = [UIImage imageNamed:@"TimeBeforeGreen.png"];
			//cell.text = kStrTimeBefore;
			break;
		case kActElapsedTime:
			cell.imageView.image = [UIImage imageNamed:@"TellDifferenceAqua.png"];
			//cell.text = kStrElapsedTime;
			break;
		case kActMixed:
			cell.imageView.image = [UIImage imageNamed:@"MixedRainbow.png"];			
			//cell.text = kStrMixed;
			break;				
		default:
			break;
	}
	/*cell.selectionStyle = UITableViewCellSelectionStyleGray;*/
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	/*
	if (indexPath.row%2) [[[cell subviews] objectAtIndex:0] setBackgroundColor:[UIColor lightGrayColor]];
	else [[[cell subviews] objectAtIndex:0] setBackgroundColor:[UIColor whiteColor]];
	 */
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	return 60;
//}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.activity = (int) indexPath.row;
	TopScoresActivityLevelSelector *topScoresActivityLevelSelector = nil;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
	{
		topScoresActivityLevelSelector = [[TopScoresActivityLevelSelector alloc] initWithNibName:@"TopScoresActivityLevelSelectorView-iPad" bundle:nil];
	}
	else 
	{
		topScoresActivityLevelSelector = [[TopScoresActivityLevelSelector alloc] initWithNibName:@"TopScoresActivityLevelSelectorView" bundle:nil];	
	}

	
	topScoresActivityLevelSelector.activity = self.activity;
	topScoresActivityLevelSelector.activityLevel = kActLevelNone;
	[self.navigationController pushViewController:topScoresActivityLevelSelector animated:YES];
	[topScoresActivityLevelSelector release];
}


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


- (void)dealloc {
    [super dealloc];
}


@end

