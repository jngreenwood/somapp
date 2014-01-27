//
//  MNMusicTrack.h
//  MIDITest
//
//  Created by Michael Norris on Wed Jan 29 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/MusicPlayer.h>

@class MNMusicSequence;
@class MNTimeSignature;
@class MNKeySignature;
@class MNBaseSequence;

#define kDownbeatPitch	67
#define kOffbeatPitch	61

enum {
    kPianoChannel = 0,
    kMetronomeChannel,
    kFluteChannel,
    kPercussionChannel
};

@interface MNMusicTrack : NSObject {
}
+(MNMusicTrack*)newTrackWithSequence:(MNMusicSequence*)s
                               track:(MusicTrack)t;
-(id)initWithSequence:(MNMusicSequence *)s;
-(void)clear;
-(void)newMIDINote:(UInt8)n
           channel:(UInt8)c
          velocity:(UInt8)v
            atTime:(double)t
          duration:(double)d;
- (MusicTrack)track;
- (void)setTrack:(MusicTrack)inTrack;
- (void)setSequence:(MNMusicSequence*)s;
- (BOOL)getPitch:(int*)pitch
chromaticAlteration:(int*)alt
        duration:(float*)dur
          atTime:(float)time
    keySignature:(MNKeySignature*)keySig
     eventOffset:(int)offset;
- (void)convertMIDIToBaseSequence:(MNBaseSequence*)sequence
                        startTime:(MusicTimeStamp)startTime
                         duration:(float)dur;
- (void)addClickTrackForTimeSignature:(MNTimeSignature*)timeSig
                            startTime:(float)startTime;

@property (nonatomic) MusicTrack track;
@property (strong) MNMusicSequence *sequence;
@property (nonatomic) AUNode node;
@property float duration;
@end

