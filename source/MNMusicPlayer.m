//
//  MNMusicPlayer.m
//  MIDITest
//
//  Created by Michael Norris on Wed Jan 29 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//
#import "MNMusicPlayer.h"
#import "MNMusicTrack.h"
#import "MNMusicSequence.h"

extern AUGraph	gAUGraph;
extern AUNode	gPianoNode,gPercussionNode;

#define kDoAUStuff  YES


@implementation MNMusicPlayer

- (id)init{
    OSStatus	status;
    self = [super init];
    if (self) {
        status = NewMusicPlayer(&player);
        if (status != 0) NSLog (@"NewMusicPlayer: %d",(int)status);
    }
    return self;
}

-(void)setSequence:(MNMusicSequence *)s{
    OSStatus	status;
    if (s == nil) {
		[self stop];
        status = MusicPlayerSetSequence (player,NULL);
        if (status != 0) {
			NSLog (@"MusicPlayerSetSequence: %d",(int)status);
		}
    } else {
        status = MusicPlayerSetSequence (player, [s sequence]);
        if (status != 0) {
			NSLog (@"MusicPlayerSetSequence: %d",(int)status);
		}
		status = MusicSequenceSetAUGraph([s sequence],gAUGraph);
		if (status != 0) NSLog (@"MusicSequenceSetAUGraph: %d",(int)status);
		status = MusicTrackSetDestNode([[s track] track],gPianoNode);
		if (status != 0) NSLog (@"MusicTrackSetDestNode1: %d",(int)status);
		status = MusicTrackSetDestNode([[s percussionTrack] track],gPercussionNode);
		if (status != 0) NSLog (@"MusicTrackSetDestNode2: %d",(int)status);
    }
    sequence = s;
}

- (void)preroll{
    OSStatus	status;
    //NSLog(@"setSequence");
    status = MusicPlayerPreroll (player);
    if (status != 0) NSLog (@"MusicPlayerPreroll: %d",(int)status);
}
/*- (void)syncWithView:(NSView*)view {
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(checkView:) userInfo:view repeats:YES];
}*/

- (void)start{
    OSStatus        status;
    AudioUnit       myAudioUnit;
    Boolean          isPlaying;
    
    status = MusicPlayerIsPlaying(player, &isPlaying);
    
    
    
    if (kDoAUStuff) {
        
        // ** GET THE AUDIO UNIT ** //
        status = AUGraphNodeInfo(gAUGraph,gPianoNode,nil,&myAudioUnit);
        if (status != 0) NSLog (@"AUGraphGetNodeInfo: %d",(int)status);
    
        // ** RESET IT **//
        status = AudioUnitReset(myAudioUnit,kAudioUnitScope_Global,0);
        if (status != 0) NSLog (@"AudioUnitReset: %d",(int)status);
    
        // ** START PLAYERS GRAPH 1st **//
        status = AUGraphStart(gAUGraph);
    
        if (status != 0)  NSLog (@"AUGraphStart: %d",(int)status);
    }
    
    // now start
    [self setTime:0.0];
    
    
    if (!isPlaying) {
        [self preroll];
        status = MusicPlayerStart (player);
        if (status != 0) {
            NSLog (@"MusicPlayerStart: %d",(int)status);
        }
    }
}

- (void)unpause {
    OSStatus	status;
    status = MusicPlayerStart (player);
    if (status != 0) {
        NSLog (@"MusicPlayerStart: %d",(int)status);
    }
}

- (void)startWithCallbackWhenFinishedToObject:(id)obj selector:(SEL)sel {
    float sequenceDuration = [self sequenceDurationInSeconds];
    //NSLog(@"Timer scheduled for %f secs",sequenceDuration);
    timer = [NSTimer scheduledTimerWithTimeInterval:sequenceDuration
                                              target:obj
                                            selector:sel
                                            userInfo:nil
                                             repeats:NO];
    [self start];
}

/*- (void)checkView:(NSTimer*)theTimer {
    NSView	*view = [theTimer userInfo];
    if (![view needsDisplay]) {
        [theTimer invalidate];
        [self start];
    }
}*/

- (void)pause {
    OSStatus	status;
    status = MusicPlayerStop (player);
    if (status != 0) NSLog (@"MusicPlayerStop: %d",(int)status);
}

- (void)stop{
    OSStatus	status;
    //NSLog(@"stop");
    if (timer != nil) {
        if ([timer isValid]) {
            [timer invalidate];
        }
        timer = nil;
    } 
	if ([self isPlaying]) {
		status = MusicPlayerStop (player);
		if (status != 0) NSLog (@"MusicPlayerStop: %d",(int)status);
		
		// stop the graph next
		if (kDoAUStuff) {
			status = AUGraphStop(gAUGraph);
			if (status != 0) NSLog (@"AUGraphStop: %d",(int)status);
		}
	}
}

- (void)setTime:(float)beats{
    OSStatus	status;
    status = MusicPlayerSetTime(player, beats);
    if (status != 0) NSLog (@"MusicPlayerSetTime: %d",(int)status);
}

- (float)sequenceDurationInSeconds {
    float	tempDur = [sequence duration], tempo = [sequence tempo];
    return 60.0 * tempDur / tempo ;
}



- (BOOL)isPlaying {
    Boolean 	playing;
    OSStatus	status;
    status = MusicPlayerIsPlaying (player, &playing);
    if (status != 0) NSLog (@"MusicPlayerIsPLaying: %d",(int)status);
    return (BOOL)playing;
}

- (MusicPlayer)player { return player; }

- (void)deleteSequence {
    if (sequence != NULL) {
        sequence = NULL;
    }
}

- (MusicTimeStamp)time {
    OSStatus 		status;
    MusicTimeStamp	outTime;
    status = MusicPlayerGetTime(player,&outTime);
    if (status != 0) {
        NSLog (@"MusicPlayerGetTime: %d",(int)status);
        return 0.0;
    }
    return outTime;
}

- (BOOL)isPastEndOfSequence {
    MusicTimeStamp 	t;
    float		seqDur;
    bool		isPast;
    t = [self time];
    seqDur = [sequence duration];
    isPast = (t>seqDur && [self isPlaying] && t<6000);
    return isPast;
}


- (MNMusicSequence*)sequence {
    return sequence;
}

- (void)dealloc{
    OSStatus	status;
    //UInt32 numTracks;
    [self stop];
    status = DisposeMusicPlayer(player);
    if (status != 0) NSLog (@"DisposeMusicPlayer: %d",(int)status);
}
@end
