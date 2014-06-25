//
//  AudioPlayer.m
//  KTF-v1.7
//
//  Created by satya on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioPlayer.h"
#import "KidsTimeFunAppState.h"

static AudioPlayer* audioPlayer = nil;

@implementation AudioPlayer
@synthesize queuePlayer;

+(AudioPlayer*)getInstance
{
	if (audioPlayer == nil) {
		audioPlayer = [[AudioPlayer alloc] init];
	}
	return audioPlayer;
}

-(void)playAudioForHours:(int)hours andMinutes:(int)minutes
{
	NSMutableArray* filesToPlay = [NSMutableArray array];
	NSString* audioFilePath;

	if (minutes == 0)	//If minutes == 0
	{
		if (hours == 12) //If hours == 12
		{
			int randVar = arc4random() % 3;
			switch (randVar) 
			{
				case 0:
					audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"12_m"] ofType:@"mp3"];
					[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
					audioFilePath = [[NSBundle mainBundle] pathForResource:@"oclock_m" ofType:@"mp3"];
					[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
					break;
				case 1:
					audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"12_midnight_m"] ofType:@"mp3"];
					[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
					break;
				case 2:
				default:
					audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"12_noon_m"] ofType:@"mp3"];
					[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
					break;
			}			
		}
		else //If hours != 12
		{
			audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d_m",hours] ofType:@"mp3"];
			[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
            audioFilePath = [[NSBundle mainBundle] pathForResource:@"oclock_m" ofType:@"mp3"];
			[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
		}
	}
	else if (minutes == 15)
	{
		int randVar = arc4random() % 2;
		switch (randVar) 
		{
			case 0:
				audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d_m",hours] ofType:@"mp3"];
				[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
				audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"15_m"] ofType:@"mp3"];
				[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];				
				break;
			case 1:
			default:
				audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"quarter_past_m"] ofType:@"mp3"];
				[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];								
				audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d_m",hours] ofType:@"mp3"];
				[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
				break;
		}
	}
	else if (minutes == 30)
	{
		int randVar = arc4random() % 2;
		switch (randVar) 
		{
			case 0:
				audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d_m",hours] ofType:@"mp3"];
				[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
				audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"30_m"] ofType:@"mp3"];
				[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];				
				break;
			case 1:
			default:
				audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"half_past_m"] ofType:@"mp3"];
				[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];								
				audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d_m",hours] ofType:@"mp3"];
				[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
				break;
		}		
	}
	else if (minutes == 45)
	{
		int randVar = arc4random() % 2;
		switch (randVar) 
		{
			case 0:
				audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d_m",hours] ofType:@"mp3"];
				[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
				audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"45_m"] ofType:@"mp3"];
				[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];				
				break;
			case 1:
			default:
				audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"quarter_til_m"] ofType:@"mp3"];
				[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];								
				audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d_m",hours == 12 ? 1 : hours+1] ofType:@"mp3"];
				[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
				break;
		}				
	}
	else if (minutes <= 29)
	{
		audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d_m",minutes] ofType:@"mp3"];
		[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
		audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"minutes_past_m"] ofType:@"mp3"];
		[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];						
		audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d_m",hours] ofType:@"mp3"];
		[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
	}
	else 
	{
		int randVar = arc4random() % 2;
		switch (randVar) 
		{
			case 0:
				audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d_m",minutes] ofType:@"mp3"];
				[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
				audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"minutes_past_m"] ofType:@"mp3"];
				[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];						
				audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d_m",hours] ofType:@"mp3"];
				[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
				break;
			case 1:
			default:
				audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d_m",60-minutes] ofType:@"mp3"];
				[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
				audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"minutes_til_m"] ofType:@"mp3"];
				[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];						
				audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d_m",hours == 12 ? 1 : hours+1] ofType:@"mp3"];
				[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
				break;
		}						
	}

	[self playQueuedFiles:filesToPlay];
}

-(void)playAudioTime:(NSString*)time
{
	NSArray* timeComponents = [time componentsSeparatedByString:@":"];
	[self playAudioForHours:[[timeComponents objectAtIndex:0] intValue] andMinutes:[[timeComponents objectAtIndex:1] intValue]];
}

-(void)playQueuedFiles:(NSArray*)fileNames
{
	if (![[KidsTimeFunAppState sharedState] appSoundState]) {
		return;
	}
	
	NSMutableArray* queueFiles = [NSMutableArray array];
	for (NSURL* url in fileNames) {
		AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:url];
		[queueFiles addObject:playerItem];
	}
	
	[self.queuePlayer removeAllItems];
	self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:queueFiles];
	[self.queuePlayer play];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{

}

-(void)dealloc
{
	if (audioPlayer) {
		[audioPlayer release];
	}	
	[super dealloc];
}

-(void)playCorrectWrong:(BOOL)correct
{
	int randNum = arc4random() % 9 + 1;
	NSString* soundFile;
	if (correct) 
	{
		soundFile = [NSString stringWithFormat:@"%dcorrect.mp3",randNum];
	}
	else 
	{
		soundFile = [NSString stringWithFormat:@"%dwrong.mp3",randNum];
	}

	NSString* audioFilePath = [[NSBundle mainBundle] pathForResource:soundFile ofType:nil];
	NSMutableArray* filesToPlay = [NSMutableArray array];
	[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
	[self playQueuedFiles:filesToPlay];
}

-(void)playAudioFile:(NSString*)fileName
{
	NSString* audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_m",fileName] ofType:@"mp3"];

	NSMutableArray* filesToPlay = [NSMutableArray array];
	[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
	[self playQueuedFiles:filesToPlay];	
}

-(void)playAudioFile:(NSString*)fileName withTime:(NSString*)strTime
{
	NSMutableArray* filesToPlay = [NSMutableArray array];
	NSString* audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_m",fileName] ofType:@"mp3"];
	[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
	
	NSArray* timeComponents = [strTime componentsSeparatedByString:@":"];
	
	audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d_m",[[timeComponents objectAtIndex:0] intValue]] ofType:@"mp3"];
	[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];

	if([[timeComponents objectAtIndex:1] intValue] != 0)
	{
		audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d_m",[[timeComponents objectAtIndex:1] intValue]] ofType:@"mp3"];
		[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];		
	}
    else
    {
        audioFilePath = [[NSBundle mainBundle] pathForResource:@"oclock_m" ofType:@"mp3"];
        [filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
    }

	[self playQueuedFiles:filesToPlay];	
}

-(void)playTellTime:(NSString*)fileName playHours:(BOOL)pHrs hours:(NSString*)hrs playMinutes:(BOOL)pMnts minutes:(NSString*)mnts playAnd:(BOOL)sAnd playAgo:(BOOL)sAgo
{
	NSMutableArray* filesToPlay = [NSMutableArray array];
	NSString* audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_m",fileName] ofType:@"mp3"];
	[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
	
	NSArray* tComponens;
	if (pHrs) {
		tComponens = [hrs componentsSeparatedByString:@" "];
		audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_m",[tComponens objectAtIndex:0]] ofType:@"mp3"];
		[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
		audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_m",[tComponens objectAtIndex:1]] ofType:@"mp3"];
		[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];		
	}

	if (sAnd) {
		audioFilePath = [[NSBundle mainBundle] pathForResource:@"and_m" ofType:@"mp3"];
		[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
	}
	
	if (pMnts) {
		tComponens = [mnts componentsSeparatedByString:@" "];
		audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_m",[tComponens objectAtIndex:0]] ofType:@"mp3"];
		[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
		audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_m",[tComponens objectAtIndex:1]] ofType:@"mp3"];
		[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];		
	}
	
	if (sAgo) {
		audioFilePath = [[NSBundle mainBundle] pathForResource:@"ago_m" ofType:@"mp3"];
		[filesToPlay addObject:[NSURL fileURLWithPath:audioFilePath]];
	}
	[self playQueuedFiles:filesToPlay];	
}

@end
