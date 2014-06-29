//
//  TopScoresActivitySelector.m
//  ScoresDisplay
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
//

#import "TopScoresActivitySelector.h"
#import "KidsTimeFunAppState.h"
#import "TopScoresActivityLevelSelector.h"

@implementation TopScoresActivitySelector

@synthesize activity;

- (void)viewDidLoad {
	self.title = kStrTopScores;
	UIBarButtonItem *homeBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Top Scores"] style:UIBarButtonItemStyleBordered target:self action:nil];
	self.navigationItem.backBarButtonItem = homeBarButton;
	[homeBarButton release];	
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
	NSLog(@"Index path is %ld",(long)indexPath.row);
	// Configure the cell.
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RightArrowAccessory"]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
	switch (indexPath.row) {
		case kActTellTime:
            [cell setBackgroundColor:[UIColor colorWithRed:.956 green:.423 blue:.109 alpha:0.50]];
            cell.textLabel.text = kStrTellTime;
			break;
		case kActSetTime:
            [cell setBackgroundColor:[UIColor colorWithRed:.408 green:0.0 blue:.972 alpha:0.50]];
            cell.textLabel.text = kStrSetTime;
			break;
		case kActTimeAfter:
            [cell setBackgroundColor:[UIColor colorWithRed:.984 green:0.0 blue:.972 alpha:0.50]];
            cell.textLabel.text = kStrTimeAfter;
			break;
		case kActTimeBefore:
            [cell setBackgroundColor:[UIColor colorWithRed:.043 green:.808 blue:.11 alpha:0.50]];
            cell.textLabel.text = kStrTimeBefore;
			break;
		case kActElapsedTime:
            [cell setBackgroundColor:[UIColor colorWithRed:.043 green:.349 blue:.976 alpha:0.50]];
            cell.textLabel.text = kStrElapsedTime;
			break;
		case kActMixed:
            [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"MixedPattern"]]];
			cell.textLabel.text = kStrMixed;
			break;				
		default:
			break;
	}
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
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

- (void)dealloc {
    [super dealloc];
}


@end

