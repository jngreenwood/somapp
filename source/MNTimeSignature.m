//
//  MNTimeSignature.m
//  NotationTest
//
//  Created by Michael Norris on Wed Apr 30 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "MNTimeSignature.h"
#import "MNKeySignature.h"
//#import "MNGlyphs.h"
//#import "MNGlyphElement.h"
//#import "MNBar.h"
//#import "MNSystem.h"


#define kTimeSignatureXOffset			-15.0
#define kTimeSignatureOffsetFromStart	44.0
#define kTimeSignatureYOffset			-18.5
#define kTimeSigDenomYOffset			0.0

@implementation MNTimeSignature

+ (MNTimeSignature *)timeSignatureWithEnum:(int)e denom:(int)d {
    return [[MNTimeSignature alloc] initWithEnum:e denom:d];
}

- (id)initWithEnum:(int)e denom:(int)d {
    int i;
    self = [super init];
    if (self) {
        timeSigEnum = e;
        timeSigDenom = d;
        beamStructure = [[NSMutableArray alloc] init];
        // if it's a basic time sig then we can fill in the beat struct ourselves
        // for more complex time sigs, beamStructure can be overridden
        switch (timeSigEnum) {
            case 5:
                [beamStructure addObject:@3];
                [beamStructure addObject:@2];
                break;
            case 7:
                [beamStructure addObject:@3];
                [beamStructure addObject:@2];
                [beamStructure addObject:@2];
                break;
            case 3:
                if (d <= 4) {
                    for (i=0;i<timeSigEnum;i++) {
                        [beamStructure addObject:@1];
                    }
                } else {
                    for (i=0;i<timeSigEnum/3;i++) {
                        [beamStructure addObject:@3];
                    }
                }
                break;
            case 6:
            case 9:
            case 12:
                for (i=0;i<timeSigEnum/3;i++) {
                    [beamStructure addObject:@3];
                }
                break;
            default:
                for (i=0;i<timeSigEnum;i++) {
                    [beamStructure addObject:@1];
                }
                break;
        }
    }
    return self;
}

- (id)initWithEnum:(int)e denom:(int)d beamStructure:(NSMutableArray *)array {
    self = [super init];
    if (self) {
        timeSigEnum = e;
        timeSigDenom = d;
        beamStructure = array;
    }
    return self;
}
/*
- (void)addObjectsToDisplayList:(NSMutableArray*)displayList
                            bar:(MNBar *)bar
{
    float				glyphWidth;
    MNGlyphElement		*g;
    NSPoint				p;
	MNSystem			*system = [bar system];
    NSRect				barRect = [bar rect], systemRect = [system systemRect];
    float				midStaffYCoord = [[bar system] midStaffYCoord];
    float				x,y;
    NSString            *enumStr,*denomStr;
	MNKeySignature		*ks = [system keySignature];
		
    glyphWidth = [MNGlyphs glyphWidth:@"4"];
    x = NSMinX(barRect)+kTimeSignatureXOffset;
    // subtract more if at start of system
    if (bar == [[bar system] barAtIndex:0]) {
		x = NSMinX(systemRect)+kTimeSignatureOffsetFromStart + [ks numberOfAccidentals]*kKeySignatureSpacing;
    }
    
    y = midStaffYCoord+kTimeSignatureYOffset;
    enumStr = [NSString stringWithFormat:@"%i",timeSigEnum];
    p = NSMakePoint(x-([enumStr length]-1)*(glyphWidth/2),y);
    g = [[MNGlyphElement alloc] initWithString:enumStr atPoint:p withAttributes:nil];
    [displayList addObject:g];
    
    p.y += kTimeSignatureYOffset+kTimeSigDenomYOffset;
    denomStr = [NSString stringWithFormat:@"%i",timeSigDenom];
    p.x = x-([denomStr length]-1)*(glyphWidth/2);
    g = [[MNGlyphElement alloc] initWithString:denomStr atPoint:p withAttributes:nil];
    [displayList addObject:g];
}
    */
/*
- (int)durationToGlyph:(float)d {

    if (timeSigDenom == 2) {
        if (d>=4) {
            return kNoteheadBreveGlyph;
        }
        
        if (d>=2) {
            return kNoteheadWholeGlyph;
        }
        
        if (d>=1) {
            return kNoteheadHollowGlyph;
        }
    }
    
    // notehead whole: only if duration = 4 or 6 in x/4 time
    if (timeSigDenom == 4) {
        if (d >= 4) {
            return kNoteheadWholeGlyph;
        }

        // notehead hollow if 2 or 3
        if (d == 2 || d == 3) {
            return kNoteheadHollowGlyph;
        }
    }

    if (timeSigDenom == 8) {
        if (d == 4 || d == 6) {
            return kNoteheadHollowGlyph;
        }
    }

    return kNoteheadFilledGlyph;
}

- (int)durationToRestGlyph:(float)d {
    
    if (d == timeSigEnum) {
        return kWholeBarRestGlyph;
    }
    
    if (timeSigDenom == 2) {
        if (d>=2) {
            return kWholeBarRestGlyph;
        }
        if (d>=1) {
            return kMinimRestGlyph;
        }
        if (d>=0.5) {
            return kCrotchetRestGlyph;
        }
        if (d>=0.25) {
            return kQuaverRestGlyph;
        }
    }
    
    if (timeSigDenom == 4) {

        if (d>=4) {
            return kWholeBarRestGlyph;
        }
        
        if (d>=2) {
            return kMinimRestGlyph;
        }

        if (d>=1) {
            return kCrotchetRestGlyph;
        }

        if (d>=0.5) {
            return kQuaverRestGlyph;
        }

        if (d>=0.25) {
            return kSemiquaverRestGlyph;
        }
    }

    if (timeSigDenom == 8) {

        if (d>=8) {
            return kWholeBarRestGlyph;
        }
        
        if (d>=4) {
            return kMinimRestGlyph;
        }

        if (d>=2) {
            return kCrotchetRestGlyph;
        }

        if (d>=1) {
            return kQuaverRestGlyph;
        }

        if (d>=0.5) {
            return kSemiquaverRestGlyph;
        }
        
        if (d>=0.25) {
            return kDemisemiquaverRestGlyph;
        }
    }
    
    if (timeSigDenom == 16) {
        
        if (d>=16) {
            return kWholeBarRestGlyph;
        }
        
        if (d>=8) {
            return kMinimRestGlyph;
        }
        
        if (d>=4) {
            return kCrotchetRestGlyph;
        }
        
        if (d>=2) {
            return kQuaverRestGlyph;
        }
        
        if (d>=1) {
            return kSemiquaverRestGlyph;
        }
        
        if (d>=0.5) {
            return kDemisemiquaverRestGlyph;
        }
        
        if (d>=0.25) {
            return kHemidemisemiquaverRestGlyph;
        }
    }

    return kQuaverRestGlyph;
}*/

- (int)beamCodeForDuration:(float)d
              nextDuration:(float)next
              prevDuration:(float)prev
                 startTime:(float)s {
    float actualDur,actualDurNext,actualDurPrev;
    BOOL prevIsBeamable, nextIsBeamable, c1, c2, c3, c4;
    BOOL is48, is416, isOnDown, nextOnDown;
    
    is48 = (timeSigEnum == 4) && (timeSigDenom == 8);
    is416 = (timeSigEnum == 4) && (timeSigDenom == 16);
    
    actualDur = (d*4.0)/timeSigDenom;
    actualDurNext = (next*4.0)/timeSigDenom;
    actualDurPrev = (prev*4.0)/timeSigDenom;

    prevIsBeamable = (actualDurPrev > 0.0) && (actualDurPrev < 1.0);
    nextIsBeamable = (actualDurNext > 0.0) && (actualDurNext < 1.0);
    nextOnDown = [self isOnDownBeat:s+d];
    isOnDown = [self isOnDownBeat:s];
       
    if (is48) {
        if (isOnDown && (s==1.0 || s==3.0)) {
            isOnDown = NO;
        }
        if (nextOnDown && (s+d==1.0 || s+d==3.0)) {
            nextOnDown = NO;
        }
    }
    
    if (is416) {
        if (isOnDown && s>0) {
            isOnDown = NO;
        }
        if (nextOnDown && s+d < 4.0) {
            nextOnDown = NO;
        }
    }
        
    // if the duration is a crotchet or greater, then there's no beam
    //
    // ... obviously
    if (actualDur >= 1.0) {
        return kNoBeam;
    }

    // START OF BEAM CONSTRAINTS
    // 1. ( We are on the downbeat
    c1 = isOnDown;
    // 2. OR prev was unbeamable (i.e. in 6/8 time: crotch sq sq))
    c2 = !prevIsBeamable;
    // 3. AND next note is beamed
    c3 = nextIsBeamable;
    // not next on down
    c4 = !nextOnDown;
    if ((c1 || c2 ) && c3 && c4) {
        return (kStartOfBeam | kInBeamGroup);
    }

    // END OF BEAM CONSTRAINTS
    
    // 1. we are not downbeat
    c1 = !isOnDown;
    // 2. AND ( next is not beamable
    c2 = !nextIsBeamable;
    // 3. OR next note *is* on the beat) 
    c3 = nextOnDown;
    // 4. AND Previous note was beamed
    c4 = prevIsBeamable;
    
    if ((c1 && (c2 || c3)) && c4) {
        return (kEndOfBeam | kInBeamGroup);
    }

    // MIDDLE BEAM CONSTRAINTS
    // 1. Not on on a downbeat
    c1 = !isOnDown;
    // 2. AND next note not on downbeat
    c2 = !nextOnDown;
    // 3. AND next must be beamable
    c3 = nextIsBeamable;
    // 4. AND prev must be beamable
    c4 = prevIsBeamable;
    if (c1 && c2 && c3 && c4) {
        return kInBeamGroup;
    }

    //default
    return kNoBeam;
}

- (BOOL)durationNeedsAugmentationDot:(float)d {
    // brute-force method
    float x[4] = {0.75,1.5,3,6};
    int i;
    for (i=0;i<4;i++) {
        if (d==x[i]) return YES;
    }
    return NO;
}

- (BOOL)durationNeedsStem:(float)d { return ((d*4/timeSigDenom) < 4); }

- (BOOL)isOnDownBeat:(float)startTime {
    int i,beats=0;
    // gotta be a whole number for a start
    if (round(startTime) != startTime) {
        return NO;
    }
    for (i=0;i<[beamStructure count];i++) {
        if (startTime == beats) {
            return YES;
        }
        beats += [[beamStructure objectAtIndex:i] intValue];
    }
    if (startTime == beats) {
        return YES;
    }
    return NO;
}

- (float)denomInCrotchets {
    return 4.0/timeSigDenom;
}

- (int)timeSigEnum { return timeSigEnum; }
- (void)setTimeSigEnum:(int)e {
	timeSigEnum = e;
}
- (void)setTimeSigDenom:(int)d {
	timeSigDenom = d;
}
- (int)timeSigDenom { return timeSigDenom; }


- (float)defaultTempo {
    switch (timeSigDenom) {
        case 4:
            return kBaseTempo;
            break;
        case 8:
            return kBaseTempo;
            break;
    }
    return kBaseTempo;
}
/*
- (int)defaultBarWidth {
	if (timeSigEnum <=1) {
		return kBarWidth / 4;
	}
	
    if (timeSigEnum <= 6) {
        return kBarWidth;
    }
    if (timeSigEnum <= 9) {
        return kBarWidth * 1.8;
    }
    if (timeSigEnum <= 12) {
        return kBarWidth * 2.2;
    }
    return kBarWidth * 4;
}
*/
- (NSMutableArray *)beamStructure { return beamStructure; }

@end