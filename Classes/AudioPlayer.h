//
//  AudioPlayer.h
//  KTF-v1.7
//
//  Created by satya on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioPlayer : NSObject <AVAudioPlayerDelegate> {
	BOOL audioPlaying;
	AVQueuePlayer* queuePlayer;	
}
@property(nonatomic,retain) AVQueuePlayer* queuePlayer;	

-(void)playAudioForHours:(int)hours andMinutes:(int)minutes;
-(void)playAudioTime:(NSString*)time;
-(void)playQueuedFiles:(NSArray*)fileNames;
+(AudioPlayer*)getInstance;
-(void)playCorrectWrong:(BOOL)correct;
-(void)playAudioFile:(NSString*)fileName;
-(void)playAudioFile:(NSString*)fileName withTime:(NSString*)strTime;
-(void)playTellTime:(NSString*)fileName playHours:(BOOL)pHrs hours:(NSString*)hrs playMinutes:(BOOL)pMnts minutes:(NSString*)mnts playAnd:(BOOL)sAnd playAgo:(BOOL)sAgo;

@end
