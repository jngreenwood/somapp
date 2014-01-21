//
//  MNKeySignature.h
//  NotationTest
//
//  Created by Michael Norris on Wed Apr 30 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MNTimeSignature.h"
#import "MNCommonFunctions.h"
//#import "MNGlyphElement.h"
//#import "MNSystem.h"
//#import "MNBar.h"
#import "MNBaseSequence.h"


	// ** THE "BASEPITCH" IVAR IS A NUMBER FROM 0 TO 11			** //
    // ** WHERE 0 IS MIDDLE C, THEN WORKING UP IN SEMITONES		** //
	// ** SIGCODE INDICATES THE NUMBER OF ACCIDENTALS IN THE	** //
	// ** KEY SIGNATURE, WHERE POSITIVE IS SHARPS, AND NEGATIVE ** //
	// ** IS FLATS (e.g. -3 is 3 flats, so Eb major)			** //


// Common scale name tags
enum {
    kMajorMode			= 0,
    kHarmonicMinorMode	= 1,
    kNaturalMinorMode,
    kIonianMode,
    kDorianMode,
    kPhrygianMode		= 5,
    kLydianMode,
    kMixolydianMode,
    kAeolianMode,
    kLocrianMode,
	kAcousticMode		= 10,
	kMixolydianFlatSixMode,
	kAeolianFlatFiveMode,
	kMelodicMinorAscendingMode,
    kLydianAugmentedMode,
	kOctatonicMode		= 15,
	kWholeToneMode,
	kHarmonicMajorMode,
	kDorianFlatFiveMode,
	kMelodicMinorAscendingRaisedFourthMode,
	kHarmonicMinor2Mode	= 20,
	kLocrianRaisedSixMode,
	kDorianRaisedFourMode,
	kHexatonicMode,
   // kMajorLocrianMode,
    kNumModes
};


enum {
	kDiatonicPressingScale = 0,
	kAcousticPressingScale,
	kOctatonicPressingScale,
	kWholeTonePressingScale,
	kHarmonicMajorPressingScale,
	kHarmonicMinorPressingScale,
	kHexatonicPressingScale
};

// interval types
enum {
    kMaj = 1,
    kMin,
    kPerf,
    kAug,
    kDim
};

// ascDesc
enum {
    kAscending = 1,
    kDescending = -1
};

enum {
    kNaturalFlag = 0,
    kFlatFlag	= -1,
    kSharpFlag = +1
};

#define kKeySignatureXOffset		40.0
#define kKeySignatureSpacing		7.0
#define kMiddleCMIDI	60
//@class MNSystem;


@interface MNKeySignature : NSObject {
    int		basePitch;	// int from 0-11 representing the chromatic pitch from middle to B that is the key signature. Eb major would be 3, for instance
    int		mode;		// int representing mode: e.g. major/minor
    int		sigCode;	// int representing number of accidentals in the key sig: e.g. -3 means three flats (Eb major or C minor)
    BOOL	display;	// Boolean specifying whether key sig should be displayed
    int		basePitchOffsetFromB;
	int		numScaleTones; 
}
+ (MNKeySignature *)keySignatureWithBasePitch:(int)bp mode:(int)m;
- (void)initModeNames;
- (id)initWithBasePitch:(int)i mode:(int)m;
- (id)initWithSigCode:(int)i mode:(int)m;
- (int)pitchFromChromaticPitch:(int)i;
- (int)altFromChromaticPitch:(int)i;
- (int)chromaticPitchFromPitch:(int)i;
- (int)chromaticPitchFromPitch:(int)p
						   alt:(int)a;
- (int)actualAccidentalForPitch:(int)p
							 alt:(int)a;
//- (void)addObjectsToDisplayList:(NSMutableArray *)displayList system:(MNSystem*)system;
- (int)numberOfAccidentals;
- (int)sigCode;
- (void)setSigCode:(int)i;
- (int)basePitchOffsetFromMiddleB;
- (void)setBasePitch:(int)b;
- (void)convertChromaticToDiatonicPitch:(int*)pitch alteration:(int*)alt;
- (int)semitonesFromDegree:(int)i toDegree:(int)j;
- (int)intervalCodeFromStartDegree:(int)start
                         endDegree:(int)end;
- (int)MIDIPitchWithPitch:(int)pitch chromaticAlteration:(int)a;
- (void)convertMIDINote:(int)MIDINote toPitch:(int*)pitch chromaticAlteration:(int*)alt;
- (void)setMode:(int)m;
//- (float)keySignatureWidth;
/*- (int)pitchToNumLedgerLines:(int)pitch
                        clef:(int)clef;*/
- (int)mode;
- (int)convertScaleDegreeToStaffOffset:(int)p;
- (int)getDegree:(int)d;
- (int)getOctave:(int)d;
- (void)getCorrectAltForPitch:(int*)pitch
			STOffsetFromTonic:(int*)alt;
- (void)chromaticIntervalFromPitch:(int)pitch1
           fromChromaticAlteration:(int)alt1
                      intervalCode:(int)chosenIntervalCode
                           ascDesc:(int)ascDesc
                          outPitch:(int*)pitch
            outChromaticAlteration:(int*)alt;
/*- (int)convertYCoordToPitch:(float)y
                   midStaff:(float)midStaff
                       clef:(int)clef
                 maxLedgers:(int)maxLedgers;*/
- (int)semitonesFromIntervalCode:(int)chosenIntervalCode;
- (BOOL)getPitchAndAltFromStartDegree:(int)start
                         intervalCode:(int)code
                              ascDesc:(int)ascDesc
                                pitch:(int*)pitch
                  chromaticAlteration:(int*)alt;
//- (int)getAccGlyphForAccidental:(int)acc;
- (int)nonKSAltForPitch:(int)pitch;
- (int)KSAltForPitch:(int)pitch;
- (int)pitchPositionFromB:(int)pitch;
//- (int)pitchPositionOnStaff:(int)pitch clef:(int)clef;
- (void)setDisplay:(BOOL)b;
- (BOOL)display;
- (MNKeySignature *)copyWithZone:(NSZone *)zone;
- (NSString*)modeDescription;
- (NSString*)description;
- (int)pressingScale;
- (int)bestChromaticAlterationForDegree:(int)p;
- (int)desperateChromaticAlterationForDegree:(int)p;
- (int)numScaleTones;
- (void)setNumScaleTones:(int)i;
- (int)calculateNumScaleTones;
@end
