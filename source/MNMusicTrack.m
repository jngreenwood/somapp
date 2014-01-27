//
//  MNMusicTrack.m
//  MIDITest
//
//  Created by Michael Norris on Wed Jan 29 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "MNMusicTrack.h"
#import "MNMusicSequence.h"
#import "MNTimeSignature.h"
#import "MNKeySignature.h"
#import "MNBaseSequence.h"
//#import "MNMIDIClient.h"

extern AUNode   gPercussionNode;
extern AUGraph  gAUGraph;


@implementation MNMusicTrack
+(MNMusicTrack*)newTrackWithSequence:(MNMusicSequence*)s
                               track:(MusicTrack)t {
    MNMusicTrack    *newTrack;
    
    newTrack = [[self alloc] init];
    if (newTrack) {
        [newTrack setSequence:s];
        [newTrack setTrack:t];
    }
    return newTrack;
}

- (id)init {
	self = [super init];
    if (self) {
		track = nil;
	}
    return self;
}

-(id)initWithSequence:(MNMusicSequence *)s {
    OSStatus	status;
    self = [super init];
    if (self) {
        status = MusicSequenceNewTrack([s sequence],&track);
        if (status != 0) NSLog (@"MusicSequenceNewTrack: %d",(int)status);
        [self setSequence:s];
        [self setDuration:0.0];
    }
    return self;
}

-(void)clear {
    OSStatus status;
    if (duration > 0) {
        status = MusicTrackClear (track,0.0,kMusicTimeStamp_EndOfTrack);
        if (status != 0) {
            NSLog (@"MusicTrackClear: %d",(int)status);
        }
    }
    [self setDuration:0.0];
}

-(void)newMIDINote:(UInt8)n
           channel:(UInt8)c
          velocity:(UInt8)v
            atTime:(double)t
          duration:(double)d {
    
    OSStatus		status;
    MusicTimeStamp	timeStamp;
    MIDINoteMessage	noteMessage;
    
    noteMessage.channel = c;
    noteMessage.note = n;
    noteMessage.velocity = v;
    noteMessage.duration = d;
    
    timeStamp = t;
    
    status = MusicTrackNewMIDINoteEvent (
                                         track, timeStamp, &noteMessage);
    if (status != 0) NSLog (@"MusicTrackNewMIDINoteEvent: %d",(int)status);
    
    if (timeStamp + d > duration) [self setDuration:timeStamp+d];
    
}

- (void)addClickTrackForTimeSignature:(MNTimeSignature*)timeSig
                            startTime:(float)startTime
{
    NSMutableArray	*beamStructure = [timeSig beamStructure];
    int 		i,timeSigEnum = [timeSig timeSigEnum];
    int			nextDownBeat = 0, beatIndex = 0;
    int			metronomeSound,currentBeatDuration;
    int			velocity;
    
    //[self setNode:gPercussionNode];
    currentBeatDuration = [[beamStructure objectAtIndex:0] intValue];
    nextDownBeat = currentBeatDuration;
    for (i=0;i<timeSigEnum;i++) {
        // downbeat always on one
        // but only on one for a one-beat beat structure
        // for a multiple-beat structure
        if (i == 0 || ((currentBeatDuration == 1) && (i == 0)) || ((currentBeatDuration > 1) && (i == nextDownBeat))) {
            metronomeSound = kDownbeatPitch;
            velocity = 60;
        } else {
            metronomeSound = kOffbeatPitch;
            velocity = 30;
        }
        if (i == nextDownBeat) {
            beatIndex ++;
            currentBeatDuration = [[beamStructure objectAtIndex:beatIndex] intValue];
            nextDownBeat += currentBeatDuration;
        }
        
        [self newMIDINote:metronomeSound
                  channel:kMetronomeChannel
                 velocity:velocity
                   atTime:startTime
                 duration:0.9];
        startTime ++;
    }
}

- (void)setTrack:(MusicTrack)inTrack {
    OSStatus			status;
    UInt32				ioLength;
	MusicTimeStamp		dur;
	
    track = inTrack;
	
	status = MusicTrackGetProperty(	inTrack,kSequenceTrackProperty_TrackLength,&dur,&ioLength);
	[self setDuration:dur];
}

- (BOOL)getPitch:(int*)pitch
chromaticAlteration:(int*)alt
        duration:(float*)dur
          atTime:(float)time
    keySignature:(MNKeySignature*)keySig
     eventOffset:(int)offset
{
    MusicEventIterator  myIterator;
    OSStatus            status;
    MusicTimeStamp	timeStamp;
    MusicEventType	eventType;
    UInt32		eventDataSize;
    Boolean                eventFound;
    MIDINoteMessage     *MIDIPacket;
    // const void**         eventData;
    int                 MIDINote,i;
    
    status = NewMusicEventIterator(track,&myIterator);
    if (status != 0) NSLog(@"NewMusicEventIterator returned an error: %d",(int)status);
    
    
    status = MusicEventIteratorSeek(myIterator,time+0.75);
    if (status != 0) NSLog(@"MusicEventIteratorSeek returned an error: %d",(int)status);
    
    // check for current event
    status = MusicEventIteratorHasPreviousEvent(myIterator,&eventFound);
    
    if (status != 0) NSLog(@"MusicEventIteratorHasPreviousEvent returned an error: %d",(int)status);
    if (!eventFound) {
        status = DisposeMusicEventIterator(myIterator);
        if (status != 0) NSLog(@"DisposeMusicEventIterator returned an error: %d",(int)status);
        return NO;
    }
    
    for (i=0; i<offset;i++) {
        status = MusicEventIteratorPreviousEvent(myIterator);
        if (status != 0) NSLog(@"MusicEventIteratorPreviousEvent returned an error: %d",(int)status);
    }
    
    status = MusicEventIteratorGetEventInfo(myIterator,&timeStamp,&eventType,(const void**)&MIDIPacket,&eventDataSize);
    if (status != 0) NSLog(@"MusicEventIteratorGetEventInfo returned an error: %d",(int)status);
    
    // is it a MIDI note?
    if (eventType == kMusicEventType_MIDINoteMessage) {
        //MIDIPacket = (MIDINoteMessage*)eventData;
        MIDINote = MIDIPacket->note;
        *dur = MIDIPacket->duration;
        [keySig convertMIDINote:MIDINote toPitch:pitch chromaticAlteration:alt];
    }
    
    
    status = DisposeMusicEventIterator (myIterator);
    if (status != 0) NSLog(@"DisposeMusicEventIterator returned an error: %d",(int)status);
    return YES;
}

- (void)convertMIDIToBaseSequence:(MNBaseSequence*)baseSequence
                        startTime:(MusicTimeStamp)startTime
                         duration:(float)dur {
    MusicEventIterator  myIterator;
    OSStatus            status;
    MusicTimeStamp	timeStamp;
    MusicEventType	eventType;
    UInt32		eventDataSize;
    Boolean                eventFound;
    MIDINoteMessage     *MIDIPacket;
    // const void**         eventData;
    int                 MIDINote;
    MNKeySignature      *keySig;
    int                 pitch,alt,oldPitch,oldAlt;
    float               noteDur;
	BOOL				exit;
    
    keySig = [baseSequence keySignature];
    
    status = NewMusicEventIterator(track,&myIterator);
    if (status != 0) NSLog(@"NewMusicEventIterator returned an error: %d",(int)status);
    
    
    status = MusicEventIteratorSeek(myIterator,startTime);
    if (status != 0) NSLog(@"MusicEventIteratorSeek returned an error: %d",(int)status);
    
    // check for current event
    
    status = MusicEventIteratorHasCurrentEvent(myIterator,&eventFound);
    if (status != 0) NSLog(@"MusicEventIteratorHasCurrentEvent returned an error: %d",(int)status);
    
    if (!eventFound) {
        status = MusicEventIteratorNextEvent(myIterator);
        if (status != 0) NSLog(@"MusicEventIteratorNextEvent returned an error: %d",(int)status);
    }
    
    status = MusicEventIteratorGetEventInfo(myIterator,&timeStamp,&eventType,(const void**)&MIDIPacket,&eventDataSize);
    if (status != 0) NSLog(@"MusicEventIteratorGetEventInfo returned an error: %d",(int)status);
    
    if (((float)timeStamp - startTime) > dur) {
        // weird things
        NSLog(@"Weird things are afoot.");
    }
    if (timeStamp - startTime > 0) {
        // add rests
        [baseSequence addRestWithDuration:((float)timeStamp-startTime)];
    }
    noteDur = 0;
	oldPitch = 0;
	oldAlt = 0;
	exit = NO;
	
    while ((timeStamp+noteDur) <= (startTime + dur) && !exit) {
		
		// Get the time stamp and MIDI information for this event
		status = MusicEventIteratorGetEventInfo(myIterator,&timeStamp,&eventType,(const void**)&MIDIPacket,&eventDataSize);
		if (status != 0) {
			NSLog(@"MusicEventIteratorGetEventInfo returned an error: %d",(int)status);
			exit = YES;
		}
		
        if (eventType == kMusicEventType_MIDINoteMessage) {
            //MIDIPacket = (MIDINoteMessage*)eventData;
            MIDINote = MIDIPacket->note;
			noteDur = MIDIPacket->duration;
			
            if (timeStamp+noteDur >= startTime+dur) {
                noteDur = startTime+dur-timeStamp;
				exit = YES;
            }
			
			if (noteDur == 0) {
				noteDur = 1;
			} else {
				[keySig convertMIDINote:MIDINote toPitch:&pitch chromaticAlteration:&alt];
				// check for harmonic direction
				if (pitch == 1 && alt == -1) {
					if (oldPitch == 0 && oldAlt == 0) {
						pitch = 0;
						alt = 1;
					}
				}
				if (pitch == 4 && alt == -1) {
					if (oldPitch == 3 && oldAlt == 0) {
						pitch = 3;
						alt = 1;
					}
				}
				[baseSequence addNoteWithPitch:pitch
                           chromaticAlteration:alt
                                      duration:noteDur];
				oldPitch = pitch;
				oldAlt = alt;
			}
        }
        
		if (!exit) {
			status = MusicEventIteratorNextEvent(myIterator);
			if (status != 0) {
				NSLog(@"MusicEventIteratorNextEvent returned an error: %d",(int)status);
				exit = YES;
			}
		}
    }
    
    status = DisposeMusicEventIterator (myIterator);
    if (status != 0) NSLog(@"DisposeMusicEventIterator returned an error: %d",(int)status);
}

- (void)dealloc {
    AUNode      theNode;
    MusicTrackGetDestNode(track,&theNode);
    
    //NSLog(@"track dealloc'ed (node:%i)",theNode);
    OSStatus	status;
	if (track != nil) {
		status = MusicSequenceDisposeTrack([sequence sequence],track);
		if (status != 0) NSLog (@"MusicSequenceDisposeTrack: %d",(int)status);
    }
}
@synthesize track,duration,node,sequence;
@end
