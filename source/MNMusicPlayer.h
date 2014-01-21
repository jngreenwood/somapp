//
//  MNMusicPlayer.h
//  MIDITest
//
//  Created by Michael Norris on Wed Jan 29 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/MusicPlayer.h>
#import "MNMusicSequence.h"

@class MNMusicSequence;
#define kSnareDrumPitch 	40

@interface MNMusicPlayer : NSObject {
    MusicPlayer		player;
    MNMusicSequence	*sequence;
    NSTimer		*timer;
}
//- (void)syncWithView:(NSView *)view;
- (void)setSequence:(MNMusicSequence *)s;
- (void)preroll;
- (void)start;
- (void)startWithCallbackWhenFinishedToObject:(id)obj selector:(SEL)sel;
//- (void)checkView:(NSTimer*)timer;
- (void)pause;
- (void)stop;
- (void)unpause;
- (void)setTime:(float)beats;
- (BOOL)isPlaying;
- (MusicPlayer)player;
- (void)deleteSequence;
- (float)sequenceDurationInSeconds;
- (MusicTimeStamp)time;
- (BOOL)isPastEndOfSequence;
- (MNMusicSequence*)sequence;
@end
