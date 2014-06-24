//
//  ScoreCard.m
//  MathFlashCards
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. All rights reserved.
//

#import "ScoreCard.h"

@implementation ScoreCard

@synthesize playerName;
@synthesize activity;
@synthesize activityType;
@synthesize activityLevel;
@synthesize questionsAsked;
@synthesize questionsAttempted;
@synthesize rightAnswers;
@synthesize wrongAnswers;
@synthesize percentScore;
@synthesize secondsTaken;
@synthesize scoreDateTime;
@synthesize scoreCard;
@synthesize scoreRank;
@synthesize isTopScore;

- (NSDictionary *) newScoreCard {
	NSMutableDictionary *newScore = [[NSMutableDictionary alloc] init];
	[newScore setObject:[NSString stringWithString:self.playerName] forKey:kPlayerName];
	[newScore setObject:[NSNumber numberWithInt:self.activity] forKey:kActivity];
	[newScore setObject:[NSNumber numberWithInt:self.activityType] forKey:kActivityType];
	[newScore setObject:[NSNumber numberWithInt:self.activityLevel] forKey:kActivityLevel];
	[newScore setObject:[NSNumber numberWithInt:self.questionsAsked] forKey:kQuestionsAsked];
	[newScore setObject:[NSNumber numberWithInt:self.questionsAttempted] forKey:kQuestionsAttempted];
	[newScore setObject:[NSNumber numberWithInt:self.rightAnswers] forKey:kRightAnswers];
	[newScore setObject:[NSNumber numberWithInt:self.wrongAnswers] forKey:kWrongAnswers];
	[newScore setObject:[NSNumber numberWithFloat:self.percentScore] forKey:kPercentScore];
	[newScore setObject:[NSNumber numberWithInt:self.secondsTaken] forKey:kSecondsTaken];
	[newScore setObject:[NSDate date] forKey:kScoreDateTime];
	
	//pre-load topscore boolean and rank variables
	isTopScore = NO;
	scoreRank = -1; //-1 denotes unranked
		
	if (rightAnswers > 0) {
		//Now get the file name - root for documents directory + "/Scores/"
		NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString *filePath = [docPath stringByAppendingString:@"/"];
		NSString *fileName = [NSString stringWithFormat:kFileVarScores,self.activity,self.activityType,self.activityLevel];
		NSString *fileNameWithPath = [filePath stringByAppendingString:fileName];
		//First read scores array from disk
		NSArray *scoresArray = [[NSArray alloc] initWithContentsOfFile:fileNameWithPath];
		
		//Now Loop throgh the sorted array and see if the score is greater than any other score in the array
		if ([scoresArray count] <= [KidsTimeFunAppState sharedState].sizeOfTopScoreList) {
			isTopScore = YES;
			scoreRank = [scoresArray count]+1;
		}
		for (int i=0; i < [scoresArray count]; i++) {
			//if first - just add is as top score #1
			if ([scoresArray count] == 0) (scoreRank = 1);
			//initialize sort keys
			long long thisSortKey = 0, arrSortKey = 0;
			//sortkey creators
			int thisNumQT, thisNumQR, thisSec, arrNumQT, arrNumQR, arrSec, thisPer10000, arrPer10000;
			switch (self.activityType) {
				case kActTypeNumbered:
					//create sort key - for numbered quiz the rank order is %, total number of questions, time
					//time should be in descending order, so subtract seconds from 15 minutes i.e. 900 seconds
					thisPer10000 = (int) (self.percentScore*10000.0f);
					thisNumQT = self.questionsAsked;
					thisSec = 900-self.secondsTaken;
					thisSortKey = [[NSString stringWithFormat:@"%i%i%i",thisPer10000,thisNumQT,thisSec] longLongValue];
					arrPer10000 = (int) ([[[scoresArray objectAtIndex:i] valueForKey:kPercentScore] floatValue]*10000.0f);
					arrNumQT = [[[scoresArray objectAtIndex:i] valueForKey:kQuestionsAsked] intValue];
					arrSec = 900-[[[scoresArray objectAtIndex:i] valueForKey:kSecondsTaken] intValue];
					arrSortKey = [[NSString stringWithFormat:@"%i%i%i",arrPer10000,arrNumQT,arrSec] longLongValue];					
					break;
				case kActTypeTimed:
					//create sort key - for timed quiz the rank order is time, number of questions right, total number of questions
					thisSec = 900-self.secondsTaken;
					thisNumQT = self.questionsAsked;
					thisNumQR = self.rightAnswers;
					thisSortKey = [[NSString stringWithFormat:@"%i%i%i",thisSec,thisNumQT,thisNumQR] longLongValue];
					arrSec = 900-[[[scoresArray objectAtIndex:i] valueForKey:kSecondsTaken] intValue];
					arrNumQT = [[[scoresArray objectAtIndex:i] valueForKey:kQuestionsAsked] intValue];
					arrNumQR = [[[scoresArray objectAtIndex:i] valueForKey:kRightAnswers] intValue];
					arrSortKey = [[NSString stringWithFormat:@"%i%i%i",arrSec,arrNumQT,arrNumQR] longLongValue];
					break;
				default:
					break;
			}
			//now the moment thissortkey is greater than or equal the array sort key - that is the rank
			//it assumes the data is in sorted order
			//which is the responsibility of file writer to write it in this sorted order
			if (thisSortKey >= arrSortKey) {
				scoreRank = i+1;
				isTopScore = YES;
				break; //break out of the loop the moment you find a rank
			}
		} //for loop
		//now release the array
		[scoresArray release];
	} //if rightanswers > 0
	//set rank and top scores
	[newScore setObject:[NSNumber numberWithInt:self.scoreRank] forKey:kScoreRank];
	scoreCard = [[NSDictionary dictionaryWithDictionary:newScore] retain];
	[newScore release];
	return scoreCard;
}

- (BOOL) writeScoreCard {
	BOOL returnValue = NO;
	if (!self.isTopScore) return returnValue;
	//Now get the file name - root for documents directory + "/Scores/"
	NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *filePath = [docPath stringByAppendingString:@"/"];
	NSString *fileName = [NSString stringWithFormat:kFileVarScores,self.activity,self.activityType,self.activityLevel];
	NSString *fileNameWithPath = [filePath stringByAppendingString:fileName];
	//First read scores array from disk
	NSArray *scoresArray = [[NSArray alloc] initWithContentsOfFile:fileNameWithPath];
	//Create New Scores Array to write
	//Load elements 0 to rank-1 from old array
	//then current score
	//then rank+1 to size of array-1 from old array
	NSMutableArray *newScoresArray = [[NSMutableArray alloc] init];
	for (int i=0; i<self.scoreRank-1; i++) {
		[newScoresArray addObject:[scoresArray objectAtIndex:i]];
	}
	[newScoresArray addObject:self.scoreCard];
	int newArraySize = ([scoresArray count]<[KidsTimeFunAppState sharedState].sizeOfTopScoreList)?[scoresArray count]+1:[KidsTimeFunAppState sharedState].sizeOfTopScoreList;
	for (int i=self.scoreRank; i<newArraySize; i++) {
		[newScoresArray addObject:[scoresArray objectAtIndex:i-1]];
	}
	//Now write file
	NSString *errorDesc;
	NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:newScoresArray format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorDesc];
    if (plistData) {
		returnValue = [plistData writeToFile:fileNameWithPath atomically:NO];
    }
    else {
        //NSLog(errorDesc);
        [errorDesc release];
		returnValue = NO;
	}
	[scoresArray release];
	[newScoresArray release];
	return returnValue;
}

- (void) dealloc {
	[scoreDateTime release];
	[playerName release];
	[scoreCard release];
	[super dealloc];
}

@end
