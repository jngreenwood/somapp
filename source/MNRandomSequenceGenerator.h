//
//  MNRandomSequenceGenerator.h
//  Aural Development X
//
//  Created by Michael Norris on Sat Jun 21 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
@class MNBaseSequence;

enum {
    kTonic      = 0,
    kSubdominant,
    kDominant,
    kDominantMinor,
    kRelativeMajor,
    kRelativeMinor,
    kSuperTonic,
    kFlattenedLeadingNote
};


#define kDupleMetre	2
#define kTripleMetre	3
    

@interface MNRandomSequenceGenerator : NSObject {
}

// ** loads in the random rhythms from the xml file, into a global dictionary
+ (void)loadInRhythms;

// ** Generates chromatic interval based on a matrix of possible intervals
+ (MNBaseSequence *)chromaticIntervalWithDuration:(int)dur
                                         interval:(int*)interval
                              addHarmonicInterval:(BOOL)harm
                                    intervalArray:(NSMutableArray*)cells
                                     allowTritone:(BOOL)trit;

// ** Generates diatonic interval based on a matrix of possible intervals
+ (MNBaseSequence *)diatonicIntervalWithDuration:(int)dur
                                       fromTonic:(BOOL)fromTonic
                                            mode:(int)mode
                                     startDegree:(int*)startDegree
                                        interval:(int*)interval
                                      tonicTriad:(BOOL)tonicTriad
                             addHarmonicInterval:(BOOL)harm
                                   intervalArray:(NSMutableArray*)cells;

// ** Generates a chromatic interval between -12 and +12
// ** Start pitch is anywhere between 0 and 11
+ (MNBaseSequence *)chromaticIntervalWithDuration:(int)dur
                                         interval:(int*)interval
                              addHarmonicInterval:(BOOL)harm
                                     allowTritone:(BOOL)trit;

// ** Generates a diatonic interval between -7 and +7
+ (MNBaseSequence *)diatonicIntervalWithDuration:(int)dur
                                       fromTonic:(BOOL)fromTonic
                                            mode:(int)mode
                                     startDegree:(int*)startDegree
                                        interval:(int*)interval
                                      tonicTriad:(BOOL)tonicTriad
                             addHarmonicInterval:(BOOL)harm;

// ** Generates a random melody using the associated parameters
+ (MNBaseSequence *)randomMelodyWithTimeSigEnum:(int)e
                                   timeSigDenom:(int)d
                                   numberOfBars:(int)n
                                leapProbability:(int)leapProb  	// 0-100
                                        maxLeap:(int)maxLeap 	// degree
                                 tieProbability:(int)tieProb
                                restProbability:(int)restProb
                              maxNumLedgerLines:(int)maxNumLedgerLines
                                           mode:(int)mode
                                     keySigCode:(int)sigCode
                                  chromaticness:(int)c		// 0-100
                          minRhythmicDifficulty:(int)r1	// if 0, then dur = timeSigEnum
                          maxRhythmicDifficulty:(int)r2
                                 startingOctave:(int)o
                                           clef:(int)clef
                                          range:(int)range
                                   startingDegree:(int)startingDegree
									rhythmArray:(NSArray*)rhythmArray;

// ** Generates a random harmonization of the base sequence
+ (MNBaseSequence *)harmonizeBaseSequence:(MNBaseSequence *)inSequence
                           startingOctave:(int)o
                                     clef:(int)clef;

// ** Generates a random diatonic chord
+ (MNBaseSequence *)randomDiatonicChordWithDuration:(int)dur
                               possibleDegreesArray:(NSArray*)array
                                            sigCode:(int)sigCode
                                               mode:(int)mode
                                             degree:(int*)degree
                                          inversion:(int)inversion;

// ** Adding random accidentals to a sequence

+ (void)addRandomTonalAccidentalsToSequence:(MNBaseSequence*)sequence;
+ (void)addRandomAccidentals:(int)n
                  toSequence:(MNBaseSequence*)sequence;

// ** Generates a random chord
+ (void)randomChordWithDuration:(int)dur
                      triadType:(int*)triadType
                      inversion:(int*)inversion
                   openPosition:(BOOL*)openPos
                 chromaticPitch:(int*)pitch
                     RHSequence:(MNBaseSequence**)RHSequence
                     LHSequence:(MNBaseSequence**)LHSequence
                randomizeValues:(BOOL)randomize;

// ** Generates random cadences
+ (void)generateRandomCadence:(int*)type
             oneChordInverted:(int)inv
                      sigCode:(int)sigCode
                         mode:(int)mode
                          dur:(float)dur
                   tonicTriad:(BOOL)tonic
                   RHSequence:(MNBaseSequence**)RHSequence
                   LHSequence:(MNBaseSequence**)LHSequence;

+ (void)generateRandomCadence:(int*)type
             oneChordInverted:(int)inv
                      sigCode:(int)sigCode
                         mode:(int)mode
                          dur:(float)dur
                   tonicTriad:(BOOL)tonic
                   RHSequence:(MNBaseSequence**)RHSequence
                   LHSequence:(MNBaseSequence**)LHSequence
               customizeCells:(NSMutableArray*)cells;

+ (void)generateRandom2ChordProgression:(int*)correctAnswer
                                sigCode:(int)sigCode
                                   mode:(int)mode
                                    dur:(float)dur
                             tonicTriad:(BOOL)tonicTriad
                             RHSequence:(MNBaseSequence**)RHSequence
                             LHSequence:(MNBaseSequence**)LHQSequence
							 chosenProg:(BOOL)chosenProg;

+ (void)generateRandom3ChordProgression:(int*)correctAnswer
                               minLevel:(int)minLevel
                               maxLevel:(int)maxLevel
                                sigCode:(int)sigCode
                                   mode:(int)mode
                                    dur:(float)dur
                             tonicTriad:(BOOL)tonicTriad
                             RHSequence:(MNBaseSequence**)RHSequence
                             LHSequence:(MNBaseSequence**)LHQSequence
							 chosenProg:(BOOL)chosenProg;

+ (void)randomChoralePhrase:(int*)modulation
                    cadence:(int*)cadence
                    sigCode:(int*)sigCode
                       mode:(int*)mode
                 tonicTriad:(BOOL)tonicTriad
            sopranoSequence:(MNBaseSequence**)sopranoSequence
               altoSequence:(MNBaseSequence**)altoSequence 
              tenorSequence:(MNBaseSequence**)tenorSequence 
               bassSequence:(MNBaseSequence**)bassSequence;

+ (MNBaseSequence*)generateRandomScale:(int)startScale
							  endScale:(int)endScale
						   chosenScale:(int*)chosenScale;

+ (NSMutableArray *)getRhythmArrayForMetre:(int)metre
                              grade:(int)grade;
@end
