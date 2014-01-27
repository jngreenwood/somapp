//
//  MNMusicSequence.h
//  MIDITest
//
//  Created by Michael Norris on Wed Jan 29 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/MusicPlayer.h>

@class MNMusicPlayer;
@class MNMusicTrack;


#define kQuietVel 75
#define kLoudVel 127


@interface MNMusicSequence : NSObject {
}

+ (MNMusicSequence *)newSequenceFromMIDIFile:(NSString*)MIDIFilePath;
//- (void)exportSequenceToMIDIFilename:(NSString*)filename directory:(NSString*)dir;
- (id)initWithTempo:(float)bps;
- (MNMusicTrack*)newTrack;
- (MusicSequence)sequence;
- (void)updateTracks;
- (void)setTempo:(float)bpm;
- (void)newTempoEvent:(Float64)bpm atTime:(Float64)t;
- (int)trackCount;
- (MNMusicTrack*)trackAtIndex:(int)i;
- (void)dealloc;
- (void)play;
- (void)playWithBeatsCountIn:(int)b;
//- (void)syncWithView:(NSView*)view;
- (void)clear;
- (MNMusicTrack*)track;
- (MNMusicTrack*)percussionTrack;
- (float)tempo;
- (void)mergePerformanceArray:(NSMutableArray*)myPerformanceArray
              beatsForNothing:(int)b;
- (float)duration;
- (void)mergeWithMusicSequence:(MNMusicSequence*)seq;
- (MNMusicSequence*)copyFromTimeStamp:(float)start
                             duration:(float)duration
                          keepCountIn:(BOOL)keepCountIn;
- (void)setPitchAtTimeStamp:(float)timeStampForPitchChange
                toMIDIPitch:(UInt8)MIDIPitch;
-(void) changeNoteAtTimeStamp:(float)oldTimeStamp
                  toTimeStamp:(float)newTimeStamp;

@property (strong) NSMutableArray *tracks;
@property float tempo;
@property (nonatomic) MusicSequence sequence;
@property float musicStartTimestamp;

@end
