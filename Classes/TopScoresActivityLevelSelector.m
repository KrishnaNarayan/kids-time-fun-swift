//
//  TopScoresActivityLevelSelector.m
//  ScoresDisplay
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
//

#import "TopScoresActivityLevelSelector.h"
#import "KidsTimeFunAppState.h"
#import "TopScoresDetailViewController.h"

@implementation TopScoresActivityLevelSelector

@synthesize activity;
@synthesize activityLevel;

- (void)viewDidLoad {
	self.title = kStrTopScores;
	UIBarButtonItem *homeBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Top Scores"] style:UIBarButtonItemStyleBordered target:self action:nil];
	self.navigationItem.backBarButtonItem = homeBarButton;
	[homeBarButton release];	
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
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
    return kNumberOfActivityLevels;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Activity";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
	// Configure the cell.
	switch (indexPath.row) {
		case kActLevelYellowBelt:
			cell.imageView.image = [UIImage imageNamed:@"Yellow Belt"];
			cell.textLabel.text = @"Yellow Belt";
			break;
		case kActLevelGreenBelt:
			cell.imageView.image = [UIImage imageNamed:@"Green Belt"];
			cell.textLabel.text = @"Green Belt";
			break;
		case kActLevelRedBelt:
			cell.imageView.image = [UIImage imageNamed:@"Red Belt"];
			cell.textLabel.text = @"Red Belt";
			break;			
		case kActLevelBlackBelt:
			cell.imageView.image = [UIImage imageNamed:@"Black Belt"];
			cell.textLabel.text = @"Black Belt";
			break;
		default:
			break;
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.activityLevel = (int) indexPath.row;
	TopScoresDetailViewController *topScoreDetailViewController = nil;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
	{
		topScoreDetailViewController = [[TopScoresDetailViewController alloc] initWithActivity:self.activity andType:[KidsTimeFunAppState sharedState].activityType andLevel:self.activityLevel showActivityTypeSelection:YES withNibName:@"TopScoresDetailView-iPad" andBundle:nil];
	}
	else {
		topScoreDetailViewController = [[TopScoresDetailViewController alloc] initWithActivity:self.activity andType:[KidsTimeFunAppState sharedState].activityType andLevel:self.activityLevel showActivityTypeSelection:YES withNibName:@"TopScoresDetailView" andBundle:nil];		
	}


	[self.navigationController pushViewController:topScoreDetailViewController animated:YES];
	[topScoreDetailViewController release];
}

- (void)dealloc {
    [super dealloc];
}


@end

