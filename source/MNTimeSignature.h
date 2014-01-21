//
//  MNTimeSignature.h
//  NotationTest
//
//  Created by Michael Norris on Wed Apr 30 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
//@class MNBar;

#define kNoBeam		0
#define kStartOfBeam	1
#define kEndOfBeam	2
#define kInBeamGroup	4



#define	kBaseTempo	105.0

@interface MNTimeSignature : NSObject {
    int 		timeSigDenom, timeSigEnum;
    NSMutableArray	*beamStructure;
}
+ (MNTimeSignature *)timeSignatureWithEnum:(int)e denom:(int)d;
- (id)initWithEnum:(int)e denom:(int)d;
- (id)initWithEnum:(int)e denom:(int)d beamStructure:(NSMutableArray *)array;
/*- (void)addObjectsToDisplayList:(NSMutableArray *)displayList
                         bar:(MNBar*)bar;*/
//- (int)durationToGlyph:(float)d;
//- (int)durationToRestGlyph:(float)d;
- (int)beamCodeForDuration:(float)d
              nextDuration:(float)next
              prevDuration:(float)prev
                 startTime:(float)s;
- (BOOL)durationNeedsAugmentationDot:(float)d;
- (BOOL)durationNeedsStem:(float)d;
- (BOOL)isOnDownBeat:(float)s;
- (float)denomInCrotchets;
- (int)timeSigDenom;
- (void)setTimeSigEnum:(int)e;
- (void)setTimeSigDenom:(int)d;
- (int)timeSigEnum;
- (float)defaultTempo;
- (NSMutableArray*)beamStructure;
//- (int)defaultBarWidth;
@end
