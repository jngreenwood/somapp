//
//  MNRandomSequenceGenerator.m
//  Aural Development X
//
//  Created by Michael Norris on Sat Jun 21 2003.
//  Copyright (c) 2004 Victoria University of Wellington. All rights reserved.
//
#import "MNRandomSequenceGenerator.h"
#import "MNBaseSequence.h"
#import "MNKeySignature.h"
#import "MNSequenceNote.h"
#import "MNSequenceBar.h"
#import "MNCommonFunctions.h"
#import "MNMusicSequence.h"
#import "MNMusicTrack.h"
#import "TouchXML.h"
//#import "MNGlyphs.h"
#define kMaxNumLedgerLines 1

NSArray							*g2ChordProgs,*gChorales;
NSMutableArray					*g3ChordProgs;
NSMutableDictionary				*gRhythmsDict;
int								lastRandom = 0;

enum {
    kPerfectCadenceChorale = 0,
    kPerfectCadenceTierceChorale,
    kImperfectCadenceChorale
};

@implementation MNRandomSequenceGenerator

#define strToPitch(arr,n) ([[[arr objectAtIndex:n] stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]] intValue])
#define strToAlt(arr,n) (([[arr objectAtIndex:n] hasPrefix:@"s"])?1:([[arr objectAtIndex:n] hasPrefix:@"f"]?-1:0))
#define RandomRange(start,end) (start + random()%(end-start))

#define kCourseNames		@"courses"
#define kRhythms 		@"rhythms"



// NSDictionary -> "duple", "triple"
// NSDictionary -> "1","2","3", etc
// NSMutableArray -> NSMutableArrays
// NSMutableArray -> 0.25 etc.

+ (void)loadInRhythms {
    NSString				*valueStr,*rhythmStr,*gradeStr;
    CXMLDocument			*theTree;
    CXMLElement             *theRhythmsList;
    CXMLNode                *rhythmsArray,*rhythm;
    int						numberOfMetres,i,j,k,n,nValues;
    float					value;
    NSNumber				*valueNumber;
    NSMutableArray				*tempArray,*tempArray2;
    NSArray					*rhythmicValuesArray;
    NSMutableDictionary		*tempDict;
    NSError                 *err;
    
	gRhythmsDict = [NSMutableDictionary dictionaryWithCapacity:50];
    NSURL *XMLFilePath = [[NSBundle mainBundle] URLForResource:kRhythms withExtension:@"xml"];
    theTree = [[CXMLDocument alloc] initWithContentsOfURL:XMLFilePath options:0 error:&err];
    if (theTree == NULL) {
        NSLog(@"Error in rhythms.xml file. Please validate.");
    } else {
        theRhythmsList = [theTree rootElement];
        numberOfMetres = [theRhythmsList childCount];
        for (i=0;i<numberOfMetres;i++) {
            rhythmsArray = [theRhythmsList childAtIndex:i];
            if ([[rhythmsArray name] isEqualToString:@"timesignature"]) {
                tempDict = [NSMutableDictionary dictionary];
                NSString *r = [[(CXMLElement*)rhythmsArray attributeForName:@"name"] stringValue];
                [gRhythmsDict setObject:tempDict forKey:r];
                n = [rhythmsArray childCount];
                for (j=0;j<n;j++) {
                    rhythm = [rhythmsArray childAtIndex:j];
                    gradeStr = [[(CXMLElement*)rhythm attributeForName:@"grade"] stringValue];
                    tempArray = [tempDict objectForKey:gradeStr];
                    if (tempArray == nil) {
                        tempArray = [[NSMutableArray alloc] init];
                        [tempDict setObject:tempArray forKey:gradeStr];
                    }
                    rhythmStr = [rhythm stringValue];
                    rhythmicValuesArray = [rhythmStr componentsSeparatedByString:@" "];
                    tempArray2 = [[NSMutableArray alloc] init];
                    nValues = [rhythmicValuesArray count];
                    for (k=0;k<nValues;k++) {
                        valueStr = [rhythmicValuesArray objectAtIndex:k];
                        value = [valueStr floatValue];
                        valueNumber = @(value);
                        [tempArray2 addObject:valueNumber];
                    }
                    [tempArray addObject:tempArray2];
                }
            }
        }
    }
}


+ (MNBaseSequence *)chromaticIntervalWithDuration:(int)dur
                                         interval:(int*)interval
                              addHarmonicInterval:(BOOL)harm
                                    intervalArray:(NSMutableArray*)cells
                                     allowTritone:(BOOL)trit
{
    if (cells!=nil) {
        /*if ([cells count] == 0) NSLog(@"cells count == 0");
        n = random()%[cells count];
        *interval = [(NSCell*)[cells objectAtIndex:n] tag];*/
    }
    return [self chromaticIntervalWithDuration:dur
                                      interval:interval
                           addHarmonicInterval:harm
                                  allowTritone:trit];
}

+ (MNBaseSequence *)diatonicIntervalWithDuration:(int)dur
                                       fromTonic:(BOOL)fromTonic
                                            mode:(int)mode
                                     startDegree:(int*)startDegree
                                        interval:(int*)interval
                                      tonicTriad:(BOOL)tonicTriad
                             addHarmonicInterval:(BOOL)harm
                                   intervalArray:(NSMutableArray*)cells
{
    int 		n,absTag,tag=0,i;
    NSMutableArray	*startDegreeArray;
    startDegreeArray = [[NSMutableArray alloc] init];
    if (cells!=nil) {
        if ([cells count] == 0) NSLog(@"cells count == 0");
        n = random()%[cells count];
		if ([[cells objectAtIndex:n] isKindOfClass:[NSNumber class]]) {
			tag = [[cells objectAtIndex:n] intValue];
		}
		/*if ([[cells objectAtIndex:n] isKindOfClass:[NSButtonCell class]]) {
			tag = [(NSCell*)[cells objectAtIndex:n] tag];
		}*/
        absTag = abs(tag);
        if (fromTonic) {
            *interval = tag;
			if (*interval == 0) *interval=99;
        }
        if (absTag > 255) {
            *interval = ((absTag >> 8) & 0x00FF) * ((tag<0)?-1:1);
            for (i=0;i<7;i++) {
                if ((absTag >> i) & 0x0001) {
                    [startDegreeArray addObject:@(i)];
                }
            }
            *startDegree = [[startDegreeArray objectAtIndex:random()%[startDegreeArray count]] intValue];
        }
    }
    return [self diatonicIntervalWithDuration:dur
                                    fromTonic:fromTonic
                                         mode:mode
                                  startDegree:startDegree
                                     interval:interval
                                   tonicTriad:tonicTriad
                          addHarmonicInterval:harm];
}
// ENSURE INTERVAL IS 0 UPON CALLING TO MAKE THIS ROUTINE
// GENERATE THE RANDOM NUMBER
+ (MNBaseSequence *)chromaticIntervalWithDuration:(int)dur
                                         interval:(int*)interval
                              addHarmonicInterval:(BOOL)harm
                                     allowTritone:(BOOL)trit
{
    MNBaseSequence	*sequence;
    MNSequenceNote	*note;
    int			pitch1,alteration1,pitch2,alteration2,start,correctDegree;
    int			correctDegrees[13] = {0,1,1,2,2,3,3,4,5,5,6,6,7};
    BOOL		goodInterval;
    MNKeySignature	*keySig;
    int			ll,ll1,ll2;
    
    // choose a random interval betwen -12 and +12
    // i.e. one octave up and down
    start = random()%12;
    goodInterval = (*interval != 0);
    while (!goodInterval) {
        *interval = (random()%12)+1;
        if (random()%2) (*interval)*=-1; // isn't C wonderful?
        goodInterval = YES;
        if (!trit) {
            goodInterval = (*interval != 6) && (*interval != -6);
        }
    }
    if (abs(*interval)<1 || abs (*interval) > 12) {
        NSLog(@"Bad interval in chromaticIntervalWithDuration");
        *interval = 1;
    }
    correctDegree = correctDegrees[abs(*interval)]*((*interval<0)?-1:1);
    // create an empty sequence
    sequence = [[MNBaseSequence alloc] initWithTimeSigEnum:4
                                              timeSigDenom:4
                                                 basePitch:0
                                                      mode:kMajorMode
                                                      clef:kTrebleClef];
    keySig = [sequence keySignature];
    // hide key signature
    [keySig setDisplay:NO];
    
    // Add start note
    // alteration of 0 signifies that diatonic pitch will be most sensible spelling
    pitch1 = start; alteration1 = 0;
    [keySig convertChromaticToDiatonicPitch:&pitch1
								 alteration:&alteration1];
    
    // Add end note
    // non-zero alteration means that alt holds the offset in semitones from bp
    pitch2 = pitch1+correctDegree; alteration2 = *interval+start;
    [keySig getCorrectAltForPitch:&pitch2
				STOffsetFromTonic:&alteration2];
    
    // Check Ledger Lines
    ll1 = 0; //[keySig pitchToNumLedgerLines:pitch1 clef:kTrebleClef];
    ll2 = 0; //[keySig pitchToNumLedgerLines:pitch2 clef:kTrebleClef];
    
    if (abs(ll1) > abs(ll2)) {
        ll = ll1;
    } else {
        ll = ll2;
    }
    if (abs(ll) > 1) {
        pitch1 += (ll<0)?7:-7;
        pitch2 += (ll<0)?7:-7;
    }
    
    // add notes to sequence
    [sequence addNoteWithPitch:pitch1
           chromaticAlteration:alteration1
                      duration:dur];
    [sequence addNoteWithPitch:pitch2
           chromaticAlteration:alteration2
                      duration:dur];
    
    // add harmonic interval, if req
    if (harm) {
        note = [sequence addNoteWithPitch:pitch1
                      chromaticAlteration:alteration1
                                 duration:dur];
        [note addPitch:pitch2 chromaticAlteration:alteration2];
    }
    
    return sequence;
}
// ENSURE INTERVAL IS 0 UPON CALLING TO MAKE THIS ROUTINE
// GENERATE THE RANDOM NUMBER
+ (MNBaseSequence *)diatonicIntervalWithDuration:(int)dur
                                       fromTonic:(BOOL)fromTonic
                                            mode:(int)mode
                                     startDegree:(int*)startDegree
                                        interval:(int*)interval
                                      tonicTriad:(BOOL)tonicTriad
                             addHarmonicInterval:(BOOL)harm
{
    MNBaseSequence	*sequence;
    MNSequenceNote	*note;
    int			endPitch,startSigCode;
    int			ll,ll1,ll2;
    MNKeySignature	*keySig;
    
    // between 2 flats and 2 sharps
    startSigCode = (random()%7)-3;
    if (*interval == 0) {
        if (fromTonic) {
            *startDegree = 0;
        } else {
            *startDegree = random()%7;
        }
        (*interval) = (random()%7)+1;
        if (random()%2) (*interval)=(*interval)*-1;
    }
	if (*interval == 99) *interval=0;
    sequence = [[MNBaseSequence alloc] initWithTimeSigEnum:4
                                              timeSigDenom:4
                                                keySigCode:startSigCode
                                                      mode:mode
                                                      clef:kTrebleClef];
    keySig = [sequence keySignature];
    
    // Add triad
    if (tonicTriad) {
        [sequence addTriadOnDegree:0
                         triadType:kDiatonicTriad
                         inversion:kRootPosition
                           seventh:NO
                          duration:dur*2];
    }
    // Add end note
    endPitch = (*interval)+(*startDegree);
    // Check Ledger Lines
    ll1 = 0; // [keySig pitchToNumLedgerLines:*startDegree clef:kTrebleClef];
    ll2 = 0; // [keySig pitchToNumLedgerLines:endPitch clef:kTrebleClef];
    
    if (abs(ll1) > abs(ll2)) {
        ll = ll1;
    } else {
        ll = ll2;
    }
    if (abs(ll) > 1) {
        *startDegree += (ll<0)?7:-7;
        endPitch += (ll<0)?7:-7;
    }
    
    // Add start note
    [sequence addNoteWithPitch:(*startDegree)
           chromaticAlteration:0
                      duration:dur];
    [sequence addNoteWithPitch:endPitch
           chromaticAlteration:0
                      duration:dur];
    // add harmonic interval
    if (harm) {
        note = [sequence addNoteWithPitch:*startDegree
                      chromaticAlteration:0
                                 duration:dur];
        [note addPitch:endPitch chromaticAlteration:0];
    }
    return sequence;
}
+ (MNBaseSequence *)randomMelodyWithTimeSigEnum:(int)e
                                   timeSigDenom:(int)d
                                   numberOfBars:(int)numBars
                                leapProbability:(int)leapProb  	// 0-100
                                        maxLeap:(int)maxLeap 	// degree
                                 tieProbability:(int)tieProb
                                restProbability:(int)restProb
                              maxNumLedgerLines:(int)maxNumLedgerLines
                                           mode:(int)mode
                                     keySigCode:(int)sigCode
                                  chromaticness:(int)c		// 0-100
                          minRhythmicDifficulty:(int)minR
                          maxRhythmicDifficulty:(int)maxR	// set to 0 for whole
                                 startingOctave:(int)o
                                           clef:(int)clef
                                          range:(int)range
                                   startingDegree:(int)startingDegree
									rhythmArray:(NSArray*)userRhythmArray
                            
{
    int				numPhrases = 0, i,metreType=0;
    int				grade,pitch=0,nRhythms,j,alt,dir;
    int				prevPitch,prev2Pitch,prev3Pitch,tempPitch;
    float			totalDur,dur,prevDur=0;
    MNBaseSequence	*sequence;
    NSMutableArray	*rhythmArray=nil,*oldRhythmArray=nil;
    BOOL			repeated=NO,rhythmRepeated=NO,newNoteChosen,prevWasARest=NO;
    BOOL			failedConstraint,failedRhythmConstraint,iGotRhythm,prevWasTied=NO;
    MNKeySignature	*keySig;
    int				degree,prevDegree=0,prev2Degree=0,prev3Degree=0;
    int				pitchDegree=0,numberOfRhythms,doTriad=0,phraseLength=0,repeatCount;
    MNSequenceNote  *note;
	NSString		*tempStr;
    
	note = nil;
    // create a new blank sequence
    sequence = [[MNBaseSequence alloc] initWithTimeSigEnum:e
                                              timeSigDenom:d
                                                keySigCode:sigCode
                                                      mode:mode
                                                      clef:clef];
    keySig = [sequence keySignature];
    //NSLog(@"In: %i",numBars);
    switch (e) {
        case 4:
        case 2:
            phraseLength = 2;
            numPhrases = (e/2)*numBars;
            metreType = kDupleMetre;
            break;
        case 3:
        case 6:
        case 9:
        case 12:
            phraseLength = 3;
            numPhrases = (e/3)*numBars;
            metreType = kTripleMetre;
            break;
        case 5:
            phraseLength = 5;
            numPhrases = 2*numBars;
            metreType = 0;
            break;
        case 7:
            phraseLength = 7;
            numPhrases = 3*numBars;
            metreType = 0;
            break;
    }
    //NSLog(@"numPhrases: %i",numPhrases);
    // loop start
    prevPitch = prev2Pitch = prev3Pitch = 99;
    repeated = NO;
    
    numberOfRhythms = maxR-minR+1;
    
    for (i=0; i<numPhrases; i++) {
        grade = 0;
        
        // ** START CONDITIONS ** //
        if (i==0) {
            
            // should we start on the tonic?
            /*if (tonic) {
                pitch = 0;
            } else {
                // choose starting tone - one note from the root triad
                if (mode == kHarmonicMinorMode) {
                    switch (random()%2) {
                        case 0:
                            pitch = 0;
                            break;
                        case 1:
                            pitch = 4;
                            break;
                    }
                } else {
                    pitch = 2*(random ()%3);
                }
            }*/
            
            pitch = startingDegree;
            
           /* if (abs([keySig pitchToNumLedgerLines:pitch+(o*7)
                                                        clef:clef]) > maxNumLedgerLines) {
                pitch += ([keySig pitchToNumLedgerLines:pitch+(o*7)
                                                              clef:clef]<0)?7:-7;
            }*/
        }
        
        // HACK FOR ODD METRES, eg 5/4 7/4
        if (e == 5) {
            switch (i%2) {
                case 0:
                    metreType = kTripleMetre;
                    phraseLength = 3;
                    break;
                case 1:
                    metreType = kDupleMetre;
                    phraseLength = 2;
                    break;
            }
        }
        if (e == 7) {
            switch (i%3) {
                case 0:
                    metreType = kTripleMetre;
                    phraseLength = 3;
                    break;
                case 1:
                case 2:
                    metreType = kDupleMetre;
                    phraseLength = 2;
                    break;
            }
        }
        
        // ** CHOOSE A RHYTHM. ARE WE ONLY DOING WHOLE NOTES? ** //
        oldRhythmArray = rhythmArray;
        rhythmArray = nil;
		
		// ** HAS THE MODULE SUPPLIED A RHYTHM ARRAY?
		if (userRhythmArray != nil) {
			if (i == numPhrases-1) {
				grade = 1;
				rhythmArray = [self getRhythmArrayForMetre:metreType grade:grade];
				failedRhythmConstraint = NO;
			} else {
				// choose a random rhythm
				tempStr = [userRhythmArray objectAtIndex:random()%[userRhythmArray count]];
				// parse out tempStr
				rhythmArray = [NSMutableArray arrayWithArray:[tempStr componentsSeparatedByString:@"-"]];
			}
		} else {
		
			// ** MODULE HASN"T SUPPLIED ARRAY. JUST USE A RANGE OF DIFFICULTY ** //
			if (maxR==0) {
				// signal for whole notes
				nRhythms = 1;
			} else {
				// choose random rhythmic phrase
				failedRhythmConstraint = YES;
				
				// ** ARE WE AT THE END OF THE MELODY? ** //
				// ** IF SO, CHOOSE A WHOLE NOTE ** //
				if (i == numPhrases-1) {
					grade = 1;
					rhythmArray = [self getRhythmArrayForMetre:metreType grade:grade];
					failedRhythmConstraint = NO;
				}
                
                if (numPhrases == 8) {
                    switch (i) {
                        case 0:
                            grade = 3;
                            break;
                        case 1:
                        case 5:
                            grade = 4;
                            break;
                        case 2:
                        case 6:
                            grade = 5;
                            break;
                        case 3:
                            grade = 2;
                            break;
                        case 4:
                            rhythmArray = [NSMutableArray arrayWithArray:[[sequence barAtIndex:0] rhythmArray]];
                            break;
                    }
                    if (rhythmArray == nil) rhythmArray = [self getRhythmArrayForMetre:metreType grade:grade];
                    failedRhythmConstraint = NO;
                    
                }
                
				
				// START OF MELODY??
				if (i == 0 && rhythmArray == nil) {
                    
                    // ** Not sure this is quite right - might need to check this block of code
					if (maxR > 3) {
						if (minR < 3) {
							grade = 2 + random()%2;
						} else {
							grade = 2;
						}
					} else {
						if (maxR >= 2) {
							grade = 2 + random ()%(maxR-1);
						} else {
							grade = minR + random()%numberOfRhythms;
						}
					}
					rhythmArray = [self getRhythmArrayForMetre:metreType grade:grade];
					failedRhythmConstraint = NO;
				}
				
				while (failedRhythmConstraint) {
					failedRhythmConstraint = NO;
					
					// ** IF WE HAVEN'T CHOSEN A RHYTHM SO FAR
					// ** THEN CHOOSE A RANDOM ONE
					
					// NB: array does not need to be released
					iGotRhythm = NO;
					while (!iGotRhythm) {
						grade = minR + random()%numberOfRhythms;
						if (grade == 1) rhythmRepeated = YES;
						rhythmArray = [self getRhythmArrayForMetre:metreType grade:grade];
						iGotRhythm = ([rhythmArray count] != 0);
						if ([rhythmArray isEqual:oldRhythmArray] && maxR!=minR && rhythmRepeated) {
							iGotRhythm = NO;
						}
					}
					
					// ** FIRST CONSTRAINT ** //
					// ** NO MORE THAN ONE REPETITION OF A RHYTHMIC CELL
					// ** AND NO REPETITIONS OF A WHOLE NOTE **//
					if (rhythmRepeated) rhythmRepeated = NO;
					if ([rhythmArray isEqual:oldRhythmArray] && maxR!=minR) {
						rhythmRepeated = YES;
					}
					
					// ** SECOND CONSTRAINT ** //
					// Don't pick a rhythm that goes over a bar line
					if (grade==1 && maxR>1) {
						switch (e) {
							case 2:
								failedRhythmConstraint = YES;
								break;
							case 3:
							case 6:
								break;
							case 4:
							case 5:
								failedRhythmConstraint = (i%2);
								break;
							case 7:
							case 9:
								failedRhythmConstraint = (i%3)==2;
								break;
						}
					}
				}
			}
		}
		
		if (maxR != 0) {
			nRhythms = [rhythmArray count];
			dur = 0;
			if (nRhythms == 0) {
				NSLog(@"nRhythms == 0!");
			}
		}
		
        for (j = totalDur = 0; j<nRhythms;j++) {
            
            prevDur = dur;
            
            // IF Rhythmic grade = 0, then use full bar durations
            if (maxR==0) {
                dur = e;
            } else {
                dur = [[rhythmArray objectAtIndex:j] floatValue];
            }
            
            // PITCH CONSTRAINTS
            failedConstraint = YES;
            repeatCount = 0;
            while (failedConstraint) {
                failedConstraint = NO;
                
                // CONSTRAINT 1: NO LEDGER LINES
                /*if (abs([keySig pitchToNumLedgerLines:pitch+(o*7)
                                                            clef:clef]) > maxNumLedgerLines) {
                    count = 0;
                    while (abs([keySig pitchToNumLedgerLines:pitch+(o*7)
                                                                   clef:clef]) > maxNumLedgerLines) {
                        pitch += ([keySig pitchToNumLedgerLines:pitch+(o*7)
                                                                      clef:clef]<0)?1:-1;
                        count ++;
                        if (count > 10) {
                            NSLog(@"Help ledgerlines pitch:%i",pitch);
                        }
                    }
                }*/
                
                
                // ** CONSTRAINT 2: NO REPEATED NOTES ** //
                if (pitch == prevPitch) {
                    failedConstraint = YES;
                }
                
                // ** CONSTRAINT 3: NO REPEATED PAIRS **//
                if (pitch == prev2Pitch && prevPitch == prev3Pitch) {
                    failedConstraint = YES;
                }
                
                // ** CONSTRAINT 4: AVOID TRITONES ** //
                degree = [keySig getDegree:pitch];
                if (
                    (degree == 3 && prevDegree == 6) ||
                    (degree == 6 && prevDegree == 3)) {
                    failedConstraint = YES;
                }
                if (mode == kHarmonicMinorMode) {
                    if (
                        (degree == 1 && prevDegree == 5) ||
                        (degree == 5 && prevDegree == 1)) {
                        failedConstraint = YES;
                    }
                }
                
                // ** CONSTRAINT 5: CHECK RANGE ** //
                if (pitch>range) {
                    failedConstraint = YES;
                    pitch = range;
                }
                if (pitch<-range) {
                    failedConstraint = YES;
                    pitch = -range;
                }
                
                // ** CONSTRAINT 6: MAX LEAPS ** //
                if (prevPitch != 99) {
                    if (abs(pitch-prevPitch)>maxLeap) {
                        pitch -= (pitch-prevPitch)/2;
                        failedConstraint = YES;
                    }
                }
                
                // ** NO TWO LEAPS IN SAME DIRECTION **//
                if (prev2Pitch != 99) {
                    if (abs(pitch-prevPitch)>2 && abs(prevPitch-prev2Pitch)>2) {
                        if (sign(pitch-prevPitch) == sign(prevPitch-prev2Pitch)) {
                            failedConstraint = YES;
                            pitch -= sign(pitch-prevPitch);
                        }
                    }
                }
                
                // WE FAILED A CONSTRAINT, SO TRY ANOTHER PITCH //
                if (failedConstraint) {
                    pitch += (random()%2==0)?-1:1;
                }
                repeatCount ++;
                if (repeatCount == 100) {
                    // bail
                    failedConstraint = NO;
                }
            }
            // end on the tonic
            if (
                (
                 (i == numPhrases-1) ||
                 ((i == numPhrases - 2) && (dur == 4))
                 ) &&
                (j == (nRhythms-1))) {
                pitch = 7*round(prevPitch/7.0);
            }
            // second to last note is a dominant note
            if (((
                  (i == numPhrases-2) && (dur != 4)) ||
                 ((i == numPhrases-3) && (dur == 4))) &&
                (j == (nRhythms-1))) {
                degree = [keySig getDegree:prevPitch];
                switch (degree) {
                    case 0:
                    case 2:
                        degree = -1;
                        break;
                    case 1:
                    case 3:
                    case 6:
                        degree = -2;
                        break;
                    case 4:
                        degree = 2;
                        break;
                    case 5:
                        degree = 1;
                        break;
                }
                pitch = prevPitch+degree;
            }
            
            prev3Pitch = prev2Pitch;
            prev2Pitch = prevPitch;
            prevPitch = pitch;
            if ((dur>3) && (i==numPhrases-1)) {
                dur/=2;
            }
            // check for chromatic alteration
            if ((random()%101) < c) {
                alt = [keySig bestChromaticAlterationForDegree:pitch];
            } else {
                alt = 0;
            }
            
            
            
            // ** ADD NOTE TO SEQUENCE
            
            // Only add a rest under these conditions:
            // 1. We choose a random number within the restProb parameter
            // 2. We're on the beat
            // 3. The previous note was not tied to this one
            // 4. The previous note was not a rest as well
            // 5. This duration does not take up a whole phrase length
            if (random()%100<restProb && (round(totalDur)==totalDur) && !prevWasTied && !prevWasARest && nRhythms>1) {
                note = [sequence addRestWithDuration:dur];
                prevWasARest = YES;
            } else {
                note = [sequence addNoteWithPitch:pitch + (o*7)
                              chromaticAlteration:alt
                                         duration:dur];
                prevWasARest = NO;
            }
            totalDur+=dur;
            
            
            
            // ** CHOOSE NEXT PITCH
            pitchDegree = [keySig getDegree:pitch];
            dir = (random()%2)==0?-1:1;
            newNoteChosen = NO;
            
            prev3Degree = [keySig getDegree:prev3Pitch];
			prev2Degree = [keySig getDegree:prev2Pitch];
			prevDegree = [keySig getDegree:prevPitch];
            
            // ** CLICHÉS
            
            //3-4-5
            if (!newNoteChosen && prev2Degree == 2 && prevDegree == 3) {
                pitch = prevPitch+1;
                newNoteChosen = YES;
            }
            //5-4-3
            if (!newNoteChosen && prev2Degree == 4 && prevDegree == 3) {
                pitch = prevPitch-1;
                newNoteChosen = YES;
            }
			//5-6-7
			if (!newNoteChosen && prev2Degree == 5 && prevDegree == 6) {
                pitch = prevPitch+1;
                newNoteChosen = YES;
            }
			// jump after 6 - 0 -.1..
			if (!newNoteChosen && prev3Degree == 6 && prev2Degree == 0 && prevDegree == 1) {
                switch (random()%3) {
					case 0:
						pitch = prevPitch+1;
						break;
					case 1:
						pitch = prevPitch+2;
						break;
					case 3:
						pitch = prevPitch-2;
						break;
				}
                newNoteChosen = YES;
            }
            // jump after 3-4-5/5-4-3
            if (!newNoteChosen && prev3Degree == 2 && prev2Degree == 3 && prevDegree == 4) {
                newNoteChosen = YES;
                if (maxLeap > 2) {
                    switch (random()%4) {
                        case 0:
                            pitch = prevPitch-3;
                            break;
                        case 1:
                            pitch = prevPitch-2;
                            break;
                        case 2:
                            pitch = prevPitch+2;
                            break;
                        case 3:
                            pitch = prevPitch+3;
                            break;
                    }                        
                } else {
                    pitch += maxLeap * dir;
                }
            }
            if (!newNoteChosen && prev3Degree == 4 && prev2Degree == 3 && prevDegree == 2) {
                newNoteChosen = YES;
                if (maxLeap > 2) {
                    switch (random()%4) {
                        case 0:
                            pitch = prevPitch - 2;
                            break;
                        case 1:
                            pitch = prevPitch - 1;
                            break;
                        case 2:
                            pitch = prevPitch + 2;
                            break;
                        case 3:
                            pitch = prevPitch + 3;
                            break;
                    }
                } else {
                    pitch += maxLeap * dir;
                }
            }
            // 6-7-8
            if (!newNoteChosen && prev2Degree == 5 && prevDegree == 6) {
                pitch = prevPitch+1;
                newNoteChosen = YES;
            }
            // 7-6-5/7-7
            if (!newNoteChosen && prev2Degree == 0 && prevDegree == 6) {
                pitch = prevPitch+dir;
                newNoteChosen = YES;
            }
            //6-5-4
            if (!newNoteChosen && prev2Degree == 6 && prevDegree == 5) {
                pitch = prevPitch-1;
                newNoteChosen = YES;
            }
            //6-5-4-jump
            if (!newNoteChosen && prev3Degree == 6 && prev2Degree == 5 && prevDegree == 4) {
                newNoteChosen = YES;
                
                if (maxLeap > 2) {
                    switch (random()%4) {
                        case 0:
                            pitch = prevPitch - 3;
                            break;
                        case 1:
                            pitch = prevPitch - 2;
                            break;
                        case 2:
                            pitch = prevPitch -1;
                            break;
                        case 3:
                            pitch = prevPitch + 3;
                            break;
                    }                    
                } else {
                    pitch -= maxLeap;
                }
            }
            
            //delete
            //6-7-8-9/6-7-8-5
            if (!newNoteChosen && prev3Degree == 5 && prev2Degree == 6 && prevDegree == 0) {
                newNoteChosen = YES;
                switch (random()%3) {
                    case 0:
                        pitch = prevPitch - 3;
                        break;
                    case 1:
                        pitch = prevPitch + 2;
                        break;
                    case 2:
                        pitch = prevPitch + 1;
                        break;
                }
            }
            
            // LEAP
            if (!newNoteChosen) {
                if (maxLeap > 1) {
                    if (pitchDegree < 5) {
                        if (abs(pitch-prevPitch)<2) {
                            if ((random()%101)<leapProb) {
                                // choose leap
                                pitch += dir*(1+(random()%(maxLeap-1)));
                                newNoteChosen = YES;
                            }
                        }
                    }
                }
            }
            // should we jump to a triad note?
            if (!newNoteChosen) {
                doTriad = (j%2)?10:75;
                if ((random()%100)<doTriad) {
                    tempPitch = 2.0*floor(pitchDegree/2.0);
                    if (tempPitch == 6) tempPitch = 7;
                    pitch = tempPitch + [sequence getOctave:pitch]*7;
                    newNoteChosen = YES;
                }
            }
            
            // DEFAULT
            if (!newNoteChosen) {
                pitch += dir;
                newNoteChosen = YES;
            }
            
            // set tiedFromPrev flag if necc
            if (prevWasTied) {
                prevWasTied = NO;
                [note setPitchAtIndex:0 toPitch:prevPitch];
                // pitch = prevPitch;
            }
        }
        
        // ADD A TIE
        // Only add a tie under these conditions:
        // 1. We choose a random number within the tieProb parameter
        // 2. We're not on the last note
        // 3. The current note is not a rest        
        if (random()%100 < tieProb && i < numPhrases-1 && ![note isARest]) {
            [note setTied:YES];
            prevWasTied = YES;
        }
        
        if (totalDur > 3) {
            // NSLog(@"Total dur: %f",totalDur);
            i++;
        }
        if (totalDur < phraseLength) {
            NSLog(@"Total dur: %f",totalDur);
        }
    }
    
    // ** LEADING NOTES etc IN HARMONIC MINOR
    if (mode == kHarmonicMinorMode) {
        [sequence addLeadingNoteAlterations];
    }
    
    // ** add dynamics to sequence **//
        //NSLog(@"Out: %i",[sequence countBars]);
    return sequence;
}






+ (MNBaseSequence *)harmonizeBaseSequence:(MNBaseSequence *)inSequence
                           startingOctave:(int)o
                                     clef:(int)clef
{
    MNKeySignature	*keySig = [inSequence keySignature];
    MNTimeSignature	*timeSig = [inSequence timeSignature];
    MNBaseSequence	*outSequence;
    NSMutableArray	*bars,*notes;
    int			i,n,j,m,k,l,mode,count,increment=0;
    int			rootNote,currentInterval,prevInterval;
    int			prevTrebDegree=0,prevBassDegree=0,trebDegree=0,bassDegree=0;
    int			trebPitch,nextTrebPitch,bassPitch=0,prevBassPitch=99;
    BOOL		failedConstraint,allowRepeatedNotes,allowLargeLeaps;
    float		dur,nextDur;
    MNSequenceBar	*tempBar,*nextBar;
    MNSequenceNote	*tempNote,*nextNote;
    //int			possHarmonizations[7][3] = {{0,3,5},{1,4,6},{0,2,5},{1,3,6},{0,2,4},{1,3,5},{4,4,6}};
    mode = [keySig mode];
    outSequence = [[MNBaseSequence alloc] initWithTimeSignature:timeSig
                                                   keySignature:keySig
                                                           clef:clef];
    bars = [inSequence bars];
    n = [bars count];
    for (i=0;i<n;i++) {
        tempBar = [bars objectAtIndex:i];
        if (i<n-1) {
            nextBar = [bars objectAtIndex:i+1];
        } else {
            nextBar = nil;
        }
        m = [tempBar countNotes];
        notes = [tempBar notes];
        for (j=0;j<m;j++) {
            tempNote = [notes objectAtIndex:j];
            if (j<m-1) {
                nextNote = [notes objectAtIndex:j+1];
            } else {
                if (nextBar != nil) {
                    nextNote = [nextBar noteAtIndex:0];
                } else {
                    nextNote = nil;
                }
            }
            trebPitch = [tempNote pitch];
            if (nextNote != nil) {
                nextTrebPitch = [nextNote pitch];
            } else {
                nextTrebPitch = 0;
            }
            failedConstraint = YES;
            
            // first note's always good
            if (j == 0 && i == 0) {
                bassPitch = 0;
                failedConstraint = NO;
            }
            
            // final note always good
            if (i == n-1 && j == m-1) {
                // round to nearest octave
                bassPitch = 7*round(prevBassPitch/7.0);
                // avoid part crossing
                while (bassPitch+(o*7) >= trebPitch) {
                    bassPitch -= 7;
                }
                failedConstraint = NO;
            }
            
            // now calculate duration
            dur = [tempNote duration];
            if (nextNote != nil) {
                nextDur = [nextNote duration];
            } else {
                nextDur = 0;
            }
            // we want a perfect cadence either in the last bar, second to last note
            // or the second-to-last bar if there's only one note in the last bar
            // or on the third-to-last note if it's a particular rhythm
            // or second to last note of second to last bar and one note in last bar
            if ((i == n-1 && j == m-2) ||
                (i == n-2 && j == m-1 && [nextBar countNotes] == 1) ||
                (((i == n-1 && j == m-3) || (i == n-2 && j == m-2 && [nextBar countNotes] == 1)) && ((dur == 0.5 && nextDur == 0.5) || (dur == 1.5 && nextDur == 0.5)))){
                // round to perfect cadence
                bassPitch = 4+[inSequence getOctave:prevBassPitch]*7;
                // don't go V-I if melody line is too
                if ([keySig getDegree:trebPitch] == 4) {
                    bassPitch += 2;
                }
                // avoid partcrossing
                while (bassPitch+(o*7) >= trebPitch) {
                    bassPitch -= 7;
                }
                failedConstraint = NO;
            }
            // THE FOLLOWING ARE NOT CONSTRAINTS, BUT SUGGESTIONS
            if (failedConstraint) {
                prevBassDegree = [keySig getDegree:prevBassPitch];
                // are we on the leading note? if so, try going to tonic
                if (prevBassDegree == 6) {
                    increment = 1;
                } else {
                    // otherwise try contrary motion
                    increment = ((nextTrebPitch > trebPitch)?-1:1);
                }
                bassPitch = prevBassPitch + increment;
            } else {
                /*ledg = [keySig pitchToNumLedgerLines:bassPitch+(o*7)
                                                           clef:clef];
                if (abs(ledg) > kMaxNumLedgerLines) {
                    bassPitch += 7*((ledg<0)?1:-1);
                }*/
            }
            // this loop looks for a pitch that fulfils various constraints
            count = 0;
            allowRepeatedNotes = allowLargeLeaps = NO;
            while (failedConstraint) {
                // this flag whether we failed any of the constraints
                failedConstraint = NO;
                // LEDGER LINE CONSTRAINT
                /*ledg = [keySig pitchToNumLedgerLines:bassPitch+(o*7)
                                                           clef:clef];
                if (abs(ledg) > kMaxNumLedgerLines) {
                    failedConstraint = YES;
                    increment = (ledg<0)?1:-1;
                    while (abs([keySig pitchToNumLedgerLines:bassPitch+(o*7)
                                                                   clef:clef]) > kMaxNumLedgerLines) {
                        bassPitch += increment;
                    }
                }*/
                
                // REPEATED NOTE CONSTRAINT
                if (!failedConstraint && !allowRepeatedNotes) {
                    if (bassPitch == prevBassPitch) {
                        failedConstraint = YES;
                    }
                }
                trebDegree = [keySig getDegree:trebPitch];
                bassDegree = [keySig getDegree:bassPitch];
                
                // AVOID TRITONES between bass notes
                if (!failedConstraint) {
                    if ((prevBassDegree == 3 && bassDegree == 6) ||
                        (prevBassDegree == 6 && bassDegree == 3)) {                        failedConstraint = YES;
                    }
                }
                
                // AVOID TRITONES between treb & bass
                if (!failedConstraint) {
                    if (
                        (bassDegree == 6 && trebDegree == 3) ||
                        (bassDegree == 3 && trebDegree == 6)) {
                        failedConstraint = YES;
                    }
                }
                
                // AVOID AUG 2nds & TRITONES IN MINOR KEY
                if (!failedConstraint) {
                    if (mode == kHarmonicMinorMode) {
                        if (prevBassDegree == 5 && bassDegree == 6) {
                            failedConstraint = YES;
                        }
                        if (prevBassDegree == 6 && bassDegree == 5) {
                            failedConstraint = YES;
                        }
                        if (prevBassDegree == 1 && bassDegree == 5) {
                            failedConstraint = YES;
                        }
                        if (prevBassDegree == 5 && bassDegree == 1) {
                            failedConstraint = YES;
                        }
                    }
                }
                
                // AVOID TRITONES BETWEEN treb & bass
                // ALSO AVOID HARMONIZING LN WITH 3rd
                if (!failedConstraint) {
                    if (mode == kHarmonicMinorMode) {
                        if (bassDegree == 1 && trebDegree == 5) {
                            failedConstraint = YES;
                        }
                        if (bassDegree == 5 && trebDegree == 1) {
                            failedConstraint = YES;
                        }
                        if (trebDegree == 6 && bassDegree == 2) {
                            failedConstraint = YES;
                        }
                        if (trebDegree == 2 && bassDegree == 6) {
                            failedConstraint = YES;
                        }
                    }
                }
                
                // LEADING NOTE CONSTRAINT
                if (!failedConstraint) {
                    if (prevBassDegree == 6) {
                        if (bassDegree != 0 && bassDegree != 1 && bassDegree != 4) {
                            failedConstraint = YES;
                        }
                    }
                }
                
                // UNISON CONSTRAINT
                if (!failedConstraint) {
                    if (bassDegree == trebDegree) {
                        failedConstraint = YES;
                    }
                }
                
                // CONSECUTIVE 4ths + 5ths CONSTRAINT
                if (!failedConstraint) {
                    currentInterval = abs(trebDegree-bassDegree);
                    prevInterval = abs(prevTrebDegree-prevBassDegree);
                    if (
                        (currentInterval == 3 || currentInterval == 4) &&
                        (prevInterval == 3 || prevInterval == 4)
                        ) {
                        failedConstraint = YES;
                    }
                }
                
                // PART CROSSING CONSTRAINT
                if (!failedConstraint) {
                    if ((bassPitch+(o*7)) > trebPitch) {
                        failedConstraint = YES;
                        increment = -1;
                    }
                }
                
                // LEAP CONSTRAINT
                if (!failedConstraint && !allowLargeLeaps) {
                    if (abs(bassPitch - prevBassPitch) > 5) {
                        bassPitch = bassPitch + ((bassPitch<prevBassPitch)?7:-7);
                        failedConstraint = YES;
                    }
                }
                
                // HARMONY NOTE CONSTRAINT
                // MUST GET THIS FAR TO BE CONSIDERED
                if (!failedConstraint) {
                    failedConstraint = YES;
                    for (k=0;k<3;k++) {
                        rootNote = (trebDegree+3+2*k)%7;
                        for (l=0;l<3;l++) {
                            if (bassDegree == rootNote) {
                                failedConstraint = NO;
                            }
                            rootNote = (rootNote+2)%7;
                        }
                    }
                }
                
                if (failedConstraint) {
                    count ++;
                    bassPitch += increment;
                }
                
                if (count == 100) {
                    // try something drastic
                    bassPitch -= 7;
                    allowLargeLeaps = YES;
                }
                if (count == 200) {
                    // try something drastic
                    bassPitch += 7;
                    allowRepeatedNotes = YES;
                }
                if (count == 300) {
                    // really bail
                    failedConstraint = NO;
                }
            }
            prevTrebDegree = [keySig getDegree:trebPitch];
			prevBassDegree = [keySig getDegree:bassPitch];
            prevBassPitch = bassPitch;
            if ((dur == 0.5 && nextDur == 0.5) || (dur == 1.5 && nextDur == 0.5)) {
                dur = dur+nextDur;
                j++;
            }
            [outSequence addNoteWithPitch:bassPitch + (o*7)
                      chromaticAlteration:0
                                 duration:dur];
        }
    }
    return outSequence;
}


+ (void)addRandomTonalAccidentalsToSequence:(MNBaseSequence*)sequence {
    NSArray		*searchArray=nil,*accArray,*searchStringArray;
    int			i,j,nPatterns,nNotes,nAcc;
    NSMutableString	*seqStr;
    NSString		*accStr,*searchStr,*tempStr;
    BOOL		strFound;
    int			pitch,degree,nIndex;
    int			startChar,endChar,len,startSearch=0,endSearch=0;
    MNKeySignature	*ks = [sequence keySignature];
    int			mode = [ks mode];
    NSRange		foundRange;
    MNSequenceNote	*note;
    
    // these strings are formatted as a list of degrees to search for followed by ":"
    // followed by the accidentals for each degree
    
    nNotes = [sequence countNotes];
    
    switch (mode) {
        case kMajorMode:
            // major key possibilities are mods to dom (#4) or subdom (b7)
            searchArray = @[@"0 6 5 4:0 -1 0 0",@"4 3 4:0 1 0",@"2 3 4:0 1 0",@"2 1 2:0 1 0",@"5 3 4:0 1 0"];
            startSearch = nNotes * 0.2;
            endSearch = nNotes * 0.8;
            break;
            
        case kHarmonicMinorMode:
            // minor key possibilities are the raised 6th + 7th going up, flat going down
            // harmonic minor is mode
            // @"6 5 6:0 1 0",@"6 5 4:-1 0 0",@"4 5 6:0 1 0" - these ones now
            // handled by generateRandomMelody
            searchArray = @[@"4 3 4:0 1 0"];
            startSearch = 0;
            endSearch = nNotes;
            break;
    }
    
    
    // now go through the sequence searching for the patterns
    // to use the inbuilt string searching features we can convert base sequence to
    // a list of degrees
    
    seqStr = [NSMutableString stringWithCapacity:255];
    for (i=startSearch;i<endSearch;i++) {
        note = [sequence noteAtIndex:i];
        pitch = [note pitch];
        degree = [sequence getDegree:pitch];
        // add as a string
        [seqStr appendFormat:@"%i ",degree];
    }
    
    nPatterns = [searchArray count];
    for (i=0;i<nPatterns;i++) {
        tempStr = [searchArray objectAtIndex:i];
        searchStringArray = [tempStr componentsSeparatedByString:@":"];
        searchStr = [searchStringArray objectAtIndex:0];
        accStr = [searchStringArray objectAtIndex:1];
        accArray = [accStr componentsSeparatedByString:@" "];
        nAcc = [accArray count];
        // now search for searchStr;
        strFound = YES;
        startChar = 0; len = [seqStr length]; endChar = len-1;
        while (strFound) {
            if (len<1 || startChar >= endChar) {
                
                strFound = NO;
                
            } else {
                foundRange = [seqStr rangeOfString:searchStr
                                           options:NSCaseInsensitiveSearch
                                             range:NSMakeRange(startChar,len)];
                strFound = (foundRange.location != NSNotFound);
                
                if (strFound) {
                    // we have a match - location will be at twice the note index, due to the space.
                    nIndex = startSearch+(foundRange.location/2);
                    for (j=0;j<nAcc;j++,nIndex++) {
                        note = [sequence noteAtIndex:nIndex];
                        [note setAltAtIndex:0
                                      toAlt:[[accArray objectAtIndex:j] intValue]];
                    }
                    // add 1 for trailing space.
                    startChar = foundRange.location+foundRange.length+1;
                    len = endChar - startChar + 1;
                } 	// strFound
            }
        } 	// while strFound
    }		// searching for patterns
}





+ (void)addRandomAccidentals:(int)n
                  toSequence:(MNBaseSequence*)sequence
{
    NSMutableArray	*barNumbers;
    int 		nBars,nNotes,theIndex,alt;
    MNSequenceBar	*seqBar;
    MNSequenceNote	*theNote=nil;
    BOOL		altered;
    MNKeySignature	*ks = [sequence keySignature];
	
    int 		i,j,k,x,p,p2;
    barNumbers = [[NSMutableArray alloc] init];
    nBars = [sequence countBars];
    for (i=1;i<nBars-1;i++) {
        [barNumbers addObject:@(i)];
    }
    for (i=0; i<n; i++) {
        x = random()%[barNumbers count];
        theIndex = [[barNumbers objectAtIndex:x] intValue];
        seqBar = [sequence barAtIndex:theIndex];
        nNotes = [seqBar countNotes];
        altered = NO;
        theIndex = random()%nNotes;
        for (j=0; j<nNotes && !altered; j++) {
            theNote = [seqBar noteAtIndex:theIndex];
            p = [theNote pitchAtIndex:0];
            alt = [ks bestChromaticAlterationForDegree:p];
            if (alt != 0) {
                altered = YES;
                [theNote setAltAtIndex:0 toAlt:alt];
                // change all others in the bar
                for (k=0; k<nNotes; k++) {
                    theNote = [seqBar noteAtIndex:k];
                    p2 = [theNote pitchAtIndex:0];
                    if (k!=theIndex && p2==p) {
                        [theNote setAltAtIndex:0 toAlt:alt];
                    }
                }
            }
            theIndex = (theIndex+1)%nNotes;
        }
        if (!altered) {
            p = [theNote pitchAtIndex:0];
            alt = [ks desperateChromaticAlterationForDegree:p];
            [theNote setAltAtIndex:0 toAlt:alt];
            for (k=0; k<nNotes; k++) {
                theNote = [seqBar noteAtIndex:k];
                p2 = [theNote pitchAtIndex:0];
                if (k!=theIndex && p2==p) {
                    [theNote setAltAtIndex:0 toAlt:alt];
                }
            }
        }
        [barNumbers removeObjectAtIndex:x];
    }
}
+ (MNBaseSequence *)randomDiatonicChordWithDuration:(int)dur
                               possibleDegreesArray:(NSArray*)array
                                            sigCode:(int)sigCode
                                               mode:(int)mode
                                             degree:(int*)degree
                                          inversion:(int)inversion
{
    MNBaseSequence	*sequence;
    MNSequenceNote	*seqNote;
    *degree = [[array objectAtIndex:random()%[array count]] intValue]-1;
    // chord III in minor should have a flat leading note, so we can now change to natural minor
    if (*degree == 2 && mode == kHarmonicMinorMode) {
        mode = kNaturalMinorMode;
    }
    sequence = [[MNBaseSequence alloc] initWithTimeSigEnum:4
                                              timeSigDenom:4
                                                keySigCode:sigCode
                                                      mode:mode
                                                      clef:kTrebleClef];
    [sequence addTriadOnDegree:*degree
                     triadType:kDiatonicTriad
                     inversion:inversion
                       seventh:NO
                      duration:dur];
    seqNote = [sequence noteAtIndex:0];
    // check highest note for ledger lines
   /* if ([[sequence keySignature] pitchToNumLedgerLines:[seqNote highestPitch]
                                            clef:kTrebleClef] > 0) {
        // down an octave
        for (i=0;i<3;i++) {
            [seqNote setPitchAtIndex:i toPitch:[seqNote pitchAtIndex:i]-7];
        }
    } else {
        if ([[sequence keySignature] pitchToNumLedgerLines:[seqNote lowestPitch]
                                                clef:kTrebleClef] < -1) {
            // up an octave
            for (i=0;i<3;i++) {
                [seqNote setPitchAtIndex:i toPitch:[seqNote pitchAtIndex:i]+7];
            }
        }
    }*/
    return sequence;
}
// ** GENERATES A RANDOM CHORD AND THAT'S ABOUT IT ** //
+ (void)randomChordWithDuration:(int)dur
                      triadType:(int*)triadType
                      inversion:(int*)inversion
                   openPosition:(BOOL*)openPos
                 chromaticPitch:(int*)cpitch
                     RHSequence:(MNBaseSequence**)RHSequence
                     LHSequence:(MNBaseSequence**)LHSequence
                randomizeValues:(BOOL)randomize
{
    int			diaPitch, alt,i;
    MNSequenceNote	*seqNote;
    MNKeySignature	*ks;
    int			nPitches;
    *RHSequence = [[MNBaseSequence alloc] initWithTimeSigEnum:4
                                                 timeSigDenom:4
                                                   keySigCode:0
                                                         mode:kMajorMode
                                                         clef:kTrebleClef];
    [*RHSequence newBar];
    ks = [*RHSequence keySignature];
    *LHSequence = [[MNBaseSequence alloc] initWithTimeSigEnum:4
                                                 timeSigDenom:4
                                                   keySigCode:0
                                                         mode:kMajorMode
                                                         clef:kBassClef];
    [*LHSequence newBar];
    if (randomize) {
        *cpitch = random()%12;
    }
    diaPitch = *cpitch;
    alt = 0;
    [ks convertChromaticToDiatonicPitch:&diaPitch
							 alteration:&alt];
    if (randomize) {
        switch (random()%3) {
            case 0:
                *triadType = kMajorTriad;
                break;
            case 1:
                *triadType = kMinorTriad;
                break;
            case 2:
                *triadType = kDiminishedTriad;
                break;
        }
    }
    // random inversion
    if (randomize) {
        *inversion = random()%3;
    }
    [*RHSequence addTriadOnDegree:diaPitch
                        triadType:*triadType
                        inversion:*inversion
                          seventh:NO
                         duration:dur];
    seqNote = [*RHSequence noteAtIndex:0];
    nPitches = [seqNote countPitches];
    for (i=0;i<nPitches;i++) {
        [seqNote setAltAtIndex:i toAlt:[seqNote altAtIndex:i]+alt];
    }
    
    // avoid ledger lines
    /*
    if ([ks pitchToNumLedgerLines:[seqNote highestPitch]
                                            clef:kTrebleClef] > 0) {
        // down an octave
        nPitches = [seqNote countPitches];
        for (i=0;i<nPitches;i++) {
            [seqNote setPitchAtIndex:i toPitch:[seqNote pitchAtIndex:i]-7];
        }
    } else {
        if ([ks pitchToNumLedgerLines:[seqNote lowestPitch]
                                                clef:kTrebleClef] < -1) {
            // up an octave
            nPitches = [seqNote countPitches];
            for (i=0;i<nPitches;i++) {
                [seqNote setPitchAtIndex:i toPitch:[seqNote pitchAtIndex:i]+7];
            }
        }
    }*/
    
    // make open position?
    if (*openPos) {
        // drop bass down an octave
        [seqNote setPitchAtIndex:*inversion toPitch:[seqNote pitchAtIndex:*inversion]-7];
        [*LHSequence addNoteWithPitch:[seqNote pitchAtIndex:*inversion]-7
                  chromaticAlteration:[seqNote altAtIndex:*inversion]
                             duration:dur];
        // put middle note up an octave
        [seqNote setPitchAtIndex:(*inversion+1)%3 toPitch:[seqNote pitchAtIndex:(*inversion+1)%3]+7];
        // check for ledger lines
        /*
        if ([ks pitchToNumLedgerLines:[seqNote highestPitch]
                                                clef:kTrebleClef] > 0) {
            // down an octave
            nPitches = [seqNote countPitches];
            for (i=0;i<nPitches;i++) {
                [seqNote setPitchAtIndex:i toPitch:[seqNote pitchAtIndex:i]-7];
            }
        }*/
        // remove bass note from RH
        [seqNote removePitchAtIndex:*inversion];
        // check for ledger lines
        seqNote = [*LHSequence noteAtIndex:0];
        diaPitch = [seqNote pitchAtIndex:0];
        /*if (abs([ks pitchToNumLedgerLines:diaPitch
                                                    clef:kBassClef]) > 0) {
            [seqNote setPitchAtIndex:0
                             toPitch:diaPitch+
                (([ks pitchToNumLedgerLines:diaPitch
                                                      clef:kBassClef]>0)?-7:7)];
        }*/
    }
}

+ (void)generateRandomCadence:(int*)type
             oneChordInverted:(int)inv
                      sigCode:(int)sigCode
                         mode:(int)mode
                          dur:(float)dur
                   tonicTriad:(BOOL)tonic
                   RHSequence:(MNBaseSequence**)RHSequence
                   LHSequence:(MNBaseSequence**)LHSequence {
    
    [self generateRandomCadence:type
               oneChordInverted:inv
                        sigCode:sigCode
                           mode:mode
                            dur:dur
                     tonicTriad:tonic
                     RHSequence:RHSequence
                     LHSequence:LHSequence
                 customizeCells:nil];
}


+ (void)generateRandomCadence:(int*)type
             oneChordInverted:(int)inv
                      sigCode:(int)sigCode
                         mode:(int)mode
                          dur:(float)dur
                   tonicTriad:(BOOL)tonic
                   RHSequence:(MNBaseSequence**)RHSequence
                   LHSequence:(MNBaseSequence**)LHSequence
               customizeCells:(NSMutableArray*)cells
{
    // meaning of this array is:
    // 1: cadence type
    // 2: root degree for chord 1
    // 3: chord 1 needs a seventh?
    // 4: root inversion of chord 1
    // 5: treble inversion of chord 1
    // 6: root degree for chord 2
    // 7: chord 2 needs a seventh?
    // 8: root inversion of chord 2
    // 9: treble inversion of chord 2
    
#define kNumCadences	17
    
    int cadenceArray[kNumCadences][9] =
    {{kPerfectCadence,4,0,0,2,0,0,0,1},
    {kPerfectCadence,4,1,0,2,0,0,0,1},
    {kPlagalCadence,3,0,0,2,0,0,0,0},
    {kInterruptedCadence,4,0,0,2,5,0,0,1},
    {kInterruptedCadence,4,1,0,2,5,0,0,1},
    {kImperfectCadence,0,0,0,1,4,0,0,2},
    {kImperfectCadence,1,0,0,0,4,0,0,1},
    {kImperfectCadence,3,0,0,2,4,0,0,1},
    {kImperfectCadence,5,0,0,1,4,0,0,2},
        
    {kPerfectCadence,4,0,1,2,0,0,0,1},
    {kPerfectCadence,6,0,1,1,0,0,0,1},
    {kPerfectCadence,4,0,0,2,0,0,1,1},
    {kPerfectCadence,4,1,0,2,0,0,1,1},
    {kPlagalCadence,3,0,1,0,0,0,0,1},
    {kImperfectCadence,0,0,1,1,4,0,0,2},
    {kImperfectCadence,1,0,1,0,4,0,0,1},
    {kImperfectCadence,3,0,1,2,4,0,0,2}};
    int			*cadence,n,nPitches, temp, temp2;
    int			chord1Degree,chord1Seventh,chord1Bass,chord1Inversion;
    int 		chord2Degree, chord2Seventh, chord2Bass, chord2Inversion, i;
    int			bassTranspose,bassLL1,bassLL2,pitch;
    MNSequenceNote	*seqNote;
    BOOL		transposeDown = NO,foundCadence;
    MNKeySignature	*ks;
    
    if (cells != nil) {
       /* n = random()%[cells count];
        n = [(NSCell*)[cells objectAtIndex:n] tag];
        switch (n) {
            case 0:
                *type = kPerfectCadence;
                break;
            case 1:
                *type = kPlagalCadence;
                break;
            case 2:
                *type = kInterruptedCadence;
                break;
            case 3:
                *type = kImperfectCadence;
                break;
        } */
    }
    
    if (*type == 0) {
        switch (random()%4) {
            case 0:
                *type = kPerfectCadence;
                break;
            case 1:
                *type = kPlagalCadence;
                break;
            case 2:
                *type = kInterruptedCadence;
                break;
            case 3:
                *type = kImperfectCadence;
                break;
        }
    }
    
    foundCadence = NO;
    
    while (!foundCadence) {
        n = random()%kNumCadences;
        cadence = &cadenceArray[n][0];
        foundCadence = cadence[0] == *type;
        if (!inv && (cadence[3] || cadence[7])) foundCadence = NO;
    }
    
    chord1Degree = cadence[1];
    chord1Seventh = cadence[2];
    chord1Bass = cadence[3];
    chord1Inversion = cadence[4];
    chord2Degree = cadence[5];
    chord2Seventh = cadence[6];
    chord2Bass = cadence[7];
    chord2Inversion = cadence[8];
    *RHSequence = [[MNBaseSequence alloc] initWithTimeSigEnum:4
                                                 timeSigDenom:4
                                                   keySigCode:sigCode
                                                         mode:mode
                                                         clef:kTrebleClef];
    *LHSequence = [[MNBaseSequence alloc] initWithTimeSigEnum:4
                                                 timeSigDenom:4
                                                   keySigCode:sigCode
                                                         mode:mode
                                                         clef:kBassClef];
    ks = [*RHSequence keySignature];
    
    // ** ADD THE TONIC CHORD ** //
    
    if (tonic) {
        // treble
        [*RHSequence addTriadOnDegree:0
                            triadType:kDiatonicTriad
                            inversion:0
                              seventh:0
                             duration:dur];
        // bass
        [*LHSequence addNoteWithPitch:-14
                  chromaticAlteration:0
                             duration:dur];
        
        [*RHSequence addRestWithDuration:dur];
        [*LHSequence addRestWithDuration:dur];
        
    }
    // FIRST CHORD
    seqNote = [*RHSequence addTriadOnDegree:chord1Degree
                                  triadType:kDiatonicTriad
                                  inversion:chord1Inversion
                                    seventh:chord1Seventh
                                   duration:dur];
    
    
    // double third for imperfect VI-V
    if (*type == kImperfectCadence && (chord1Degree == 5 || (chord1Degree == 3 && chord1Bass == 1))) {
        nPitches = [seqNote countPitches];
        for (i=0;i<nPitches;i++) {
            pitch = [seqNote pitchAtIndex:i];
            if ([*RHSequence getDegree:pitch] == 5) {
                [seqNote setPitchAtIndex:i toPitch:pitch+2];
            }
        }
    }
    
    // double fifth for perfect V(6.3)-I
    if (*type == kPerfectCadence && chord1Degree == 4 && chord1Bass == 1) {
        nPitches = [seqNote countPitches];
        for (i=0;i<nPitches;i++) {
            pitch = [seqNote pitchAtIndex:i];
            if ([*RHSequence getDegree:pitch] == 6) {
                [seqNote setPitchAtIndex:i toPitch:pitch+2];
            }
        }
    }
    
    
  /*  if ([ks pitchToNumLedgerLines:[seqNote highestPitch]
                                            clef:kTrebleClef] > 0) {
        transposeDown = YES;
        // transpose treble staff down octave to avoid ledgers
        nPitches = [seqNote countPitches];
        for (i=0;i<nPitches;i++) {
            pitch = [seqNote pitchAtIndex:i];
            [seqNote setPitchAtIndex:i toPitch:pitch-7];
        }
    }*/
    
    
    
    temp = chord1Degree+chord1Bass*2;
    temp2 = chord2Degree+chord2Bass*2;
    if (temp == 6) temp = -1; // drop 7th down an 8ve
    if (temp == 8) temp = 1;
    if (temp == 5 && temp2 == 0) temp = -2;
    if (temp < -2) {
        NSLog(@"temp was below -1: chord1degree: %i chord1Bass: %i temp:%i",chord1Degree,chord1Bass,temp);
    }
    bassLL1 = 0; //[ks pitchToNumLedgerLines:temp-14 clef:kBassClef];
    bassLL2 = 0; //[ks pitchToNumLedgerLines:chord2Degree+chord2Bass*2-14 clef:kBassClef];
    if (bassLL1 < 0 || bassLL2 < 0) {
        bassTranspose = 7;
    } else {
        bassTranspose = 14;
    }
    [*LHSequence addNoteWithPitch:temp-bassTranspose
              chromaticAlteration:0
                         duration:dur];
    
    seqNote = [*RHSequence addTriadOnDegree:chord2Degree
                                  triadType:kDiatonicTriad
                                  inversion:chord2Inversion
                                    seventh:chord2Seventh
                                   duration:dur];
    
    // double third of chord VI for interrupted cadence
    if (*type == kInterruptedCadence) {
        nPitches = [seqNote countPitches];
        for (i=0;i<nPitches;i++) {
            pitch = [seqNote pitchAtIndex:i];
            if ([*RHSequence getDegree:pitch] == 5) {
                [seqNote setPitchAtIndex:i toPitch:pitch+2];
            }
        }
    }
    
    
    
    if (transposeDown) {
        // down an octave
        nPitches = [seqNote countPitches];
        for (i=0;i<nPitches;i++) {
            [seqNote setPitchAtIndex:i toPitch:[seqNote pitchAtIndex:i]-7];
        }
    }
    if (temp2 < -2) {
        NSLog(@"temp2 was below -1: chord2degree: %i chord2Bass: %i temp:%i",chord2Degree,chord2Bass,temp2);
    }
    [*LHSequence addNoteWithPitch:temp2-bassTranspose
              chromaticAlteration:0
                         duration:dur];
}

+ (void)generateRandom2ChordProgression:(int*)correctAnswer
                                sigCode:(int)sigCode
                                   mode:(int)mode
                                    dur:(float)dur
                             tonicTriad:(BOOL)tonicTriad
                             RHSequence:(MNBaseSequence**)RHSequence
                             LHSequence:(MNBaseSequence**)LHSequence
							 chosenProg:(BOOL)chosenProg
{
    
    NSString    *filePath,*chordProgStr;
    int         nProgs,myWhatMode;
    NSString    *myProgStr,*sStr,*aStr,*tStr,*bStr;
    NSArray     *tempArray,*sArr,*tArr,*aArr,*bArr;
    int         i,sPitch,sAlt,aPitch,aAlt,tPitch,tAlt,bPitch,bAlt,highTen,transpose,maxLedgers,sDeg,aDeg,tDeg,bDeg;
    MNSequenceNote  *seqNote;
    MNKeySignature  *keySig;
    
    // create the sequences
    *RHSequence = [[MNBaseSequence alloc] initWithTimeSigEnum:4
                                                 timeSigDenom:4
                                                   keySigCode:sigCode
                                                         mode:mode
                                                         clef:kTrebleClef];
    
    
    *LHSequence = [[MNBaseSequence alloc] initWithTimeSigEnum:4
                                                 timeSigDenom:4
                                                   keySigCode:sigCode
                                                         mode:mode
                                                         clef:kBassClef];
    
    keySig = [*RHSequence keySignature];
    
    
    
    if (g2ChordProgs == nil) {
        // read in 3 chord progs
        filePath = [[NSBundle mainBundle] pathForResource:@"2chords" ofType:@"txt"];
        chordProgStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        g2ChordProgs = [chordProgStr componentsSeparatedByString:@"\n"];
    }
    nProgs = [g2ChordProgs count];
        
	if (chosenProg) {
		myProgStr = [g2ChordProgs objectAtIndex:*correctAnswer];
		tempArray = [myProgStr componentsSeparatedByString:@"\t"];
		// components order is: MINANSWER | LEVEL | S | A | T | B | WHATMODE
		// WHATMODE is: 0 (both major & minor); 1 (major only); 2 (minor only)
		myWhatMode = [[tempArray objectAtIndex:6] intValue];
	} else {
			
		while (!chosenProg) {
			*correctAnswer = random()%nProgs;
			// read in this prog
			myProgStr = [g2ChordProgs objectAtIndex:*correctAnswer];
			// split into components
			tempArray = [myProgStr componentsSeparatedByString:@"\t"];
			// components order is: MINANSWER | LEVEL | S | A | T | B | WHATMODE
			// WHATMODE is: 0 (both major & minor); 1 (major only); 2 (minor only)
			myWhatMode = [[tempArray objectAtIndex:6] intValue];
			if (mode == kHarmonicMinorMode) {
				*correctAnswer = [[tempArray objectAtIndex:0] intValue];
			}
			chosenProg = YES;
		}
	}
    
    // now work out pitches & alts for S A T B
    
    sStr = [tempArray objectAtIndex:2];
    aStr = [tempArray objectAtIndex:3];
    tStr = [tempArray objectAtIndex:4];
    bStr = [tempArray objectAtIndex:5];
    sArr = [sStr componentsSeparatedByString:@" "];
    aArr = [aStr componentsSeparatedByString:@" "];
    tArr = [tStr componentsSeparatedByString:@" "];
    bArr = [bStr componentsSeparatedByString:@" "];
    
    
    
    // get highest tenor
    highTen = 0;
    for (i=0;i<2;i++) {
        bPitch = strToPitch(bArr,i);
        if (bPitch > highTen) highTen = bPitch;
    }
    // check ledgers
    maxLedgers = 0; //[keySig pitchToNumLedgerLines:highTen-7 clef:kBassClef];
    
    if (maxLedgers>0) {
        // transpose down an octave
        transpose = -7;
    } else {
        transpose = 0;
    }
    
    if (tonicTriad) {
        [*RHSequence addTriadOnDegree:0+transpose
                            triadType:kDiatonicTriad
                            inversion:kRootPosition
                              seventh:NO
                             duration:3];
        [*RHSequence addRestWithDuration:1];
        [*LHSequence addNoteWithPitch:transpose-7
                  chromaticAlteration:0
                             duration:3];
        [*LHSequence addRestWithDuration:1];
    }
    
    for (i=0;i<2;i++) {
        if (i==2) dur *= 2;
        
        sPitch = strToPitch(sArr,i)+transpose;
		sDeg = [*RHSequence getDegree:sPitch];
        sAlt = strToAlt(sArr,i);
        aPitch = strToPitch(aArr,i)+transpose;
		aDeg = [*RHSequence getDegree:aPitch];
        aAlt = strToAlt(aArr,i);
        tPitch = strToPitch(tArr,i)-7+transpose;
		tDeg = [*RHSequence getDegree:tPitch];
        tAlt = strToAlt(tArr,i);
        bPitch = strToPitch(bArr,i)-7+transpose;
		bDeg = [*RHSequence getDegree:bPitch];
        bAlt = strToAlt(bArr,i);
        
        
        
        // no flat 6 in minor
        if (mode == kHarmonicMinorMode) {
            if ((sDeg==5 || sDeg==2) && sAlt == -1) {
                sAlt = 0;
            }
            if ((aDeg==5 || aDeg==2) && aAlt == -1) {
                aAlt = 0;
            }
            if ((tDeg==5 || tDeg==2) && tAlt == -1) {
                tAlt = 0;
            }
            if ((bDeg==5 || bDeg==2) && bAlt == -1) {
                bAlt = 0;
            }
		}
        
        
        seqNote = [*RHSequence addNoteWithPitch:sPitch
                            chromaticAlteration:sAlt
                                       duration:dur];
        [seqNote addPitch:aPitch
      chromaticAlteration:aAlt];
        
        seqNote = [*LHSequence addNoteWithPitch:tPitch
                            chromaticAlteration:tAlt
                                       duration:dur];
        [seqNote addPitch:bPitch
      chromaticAlteration:bAlt];
        
    }
    
}


+ (void)generateRandom3ChordProgression:(int*)correctAnswer
                               minLevel:(int)minLevel
                               maxLevel:(int)maxLevel
                                sigCode:(int)sigCode
                                   mode:(int)mode
                                    dur:(float)dur
                             tonicTriad:(BOOL)tonicTriad
                             RHSequence:(MNBaseSequence**)RHSequence
                             LHSequence:(MNBaseSequence**)LHSequence
							 chosenProg:(BOOL)chosenProg {
    
    NSString		*filePath,*chordProgStr;
    int				nProgs,level,myWhatMode;
    NSString		*myProgStr,*sStr,*aStr,*tStr,*bStr,*levelArrayStr;
    NSArray			*tempArray,*sArr,*tArr,*aArr,*bArr,*levelArray;
    int				i,j,sPitch,sAlt,aPitch,aAlt,tPitch,tAlt,bPitch,bAlt,highTen,transpose,maxLedgers,sDeg,aDeg,tDeg,bDeg;
    MNSequenceNote  *seqNote;
    MNKeySignature  *keySig;
	unichar			nl,tab;
	
	nl = 0x000A;
	tab = 0x0009;
    
    // create the sequences
    *RHSequence = [[MNBaseSequence alloc] initWithTimeSigEnum:4
                                                 timeSigDenom:4
                                                   keySigCode:sigCode
                                                         mode:mode
                                                         clef:kTrebleClef];
    
    
    *LHSequence = [[MNBaseSequence alloc] initWithTimeSigEnum:4
                                                 timeSigDenom:4
                                                   keySigCode:sigCode
                                                         mode:mode
                                                         clef:kBassClef];
    
    keySig = [*RHSequence keySignature];
    
    
    
    if (g3ChordProgs == nil) {
        // read in 3 chord progs
        filePath = [[NSBundle mainBundle] pathForResource:@"3chords" ofType:@"txt"];
        chordProgStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        g3ChordProgs = [NSMutableArray arrayWithArray:[chordProgStr componentsSeparatedByString:[NSString stringWithCharacters:&nl length:1]]];
		[g3ChordProgs removeObjectAtIndex:0];// header row
    }
    nProgs = [g3ChordProgs count];
	
	if (chosenProg) {
		// just generate the progression as it appears
		myProgStr = [g3ChordProgs objectAtIndex:*correctAnswer];
		// split into components
		tempArray = [myProgStr componentsSeparatedByString:@"\t"];
	} else {
		while (!chosenProg) {
			*correctAnswer = lastRandom;
			while (*correctAnswer == lastRandom) {
				*correctAnswer = random()%nProgs;
			}
			lastRandom = *correctAnswer;
			// read in the data for this progression
			myProgStr = [g3ChordProgs objectAtIndex:*correctAnswer];
			// split into components
			tempArray = [myProgStr componentsSeparatedByString:@"\t"];
			// components order is: SET | S | A | T | B | WHATMODE
			myWhatMode = [[tempArray objectAtIndex:5] intValue];
			levelArrayStr = [tempArray objectAtIndex:0];
			levelArray = [levelArrayStr componentsSeparatedByString:@"&"];
			for (j=0; j<[levelArray count];j++) {
				level = [[levelArray objectAtIndex:j] intValue];
				if (level >= minLevel && level <= maxLevel) {
				// WHATMODE is: 0 (both major & minor); 1 (major only); 2 (minor only)
					if (myWhatMode == 0 || (myWhatMode == 1 && mode == kMajorMode) || (myWhatMode ==2 && mode == kHarmonicMinorMode)) {
						chosenProg = YES;
					}
				}
			}
		}
	}
    
    // now work out pitches & alts for S A T B
    
    sStr = [tempArray objectAtIndex:1];
    aStr = [tempArray objectAtIndex:2];
    tStr = [tempArray objectAtIndex:3];
    bStr = [tempArray objectAtIndex:4];
    sArr = [sStr componentsSeparatedByString:@" "];
    aArr = [aStr componentsSeparatedByString:@" "];
    tArr = [tStr componentsSeparatedByString:@" "];
    bArr = [bStr componentsSeparatedByString:@" "];
    
    
    
    // get highest tenor
    highTen = 0;
    for (i=0;i<3;i++) {
        bPitch = strToPitch(bArr,i);
        if (bPitch > highTen) highTen = bPitch;
    }
    // check ledgers
    maxLedgers = 0; //[keySig pitchToNumLedgerLines:highTen-7  clef:kBassClef];
    
    if (maxLedgers>0) {
        // transpose down an octave
        transpose = -7;
    } else {
        transpose = 0;
    }
    
    if (tonicTriad) {
        [*RHSequence addTriadOnDegree:0+transpose
                            triadType:kDiatonicTriad
                            inversion:kRootPosition
                              seventh:NO
                             duration:3];
        [*RHSequence addRestWithDuration:1];
        [*LHSequence addNoteWithPitch:transpose-7
                  chromaticAlteration:0
                             duration:3];
        [*LHSequence addRestWithDuration:1];
    }
    
    for (i=0;i<3;i++) {
        if (i==2) dur *= 2;
		sPitch = strToPitch(sArr,i)+transpose;
		sDeg = [*RHSequence getDegree:sPitch];
        sAlt = strToAlt(sArr,i);
        aPitch = strToPitch(aArr,i)+transpose;
		aDeg = [*RHSequence getDegree:aPitch];
        aAlt = strToAlt(aArr,i);
        tPitch = strToPitch(tArr,i)-7+transpose;
		tDeg = [*RHSequence getDegree:tPitch];
        tAlt = strToAlt(tArr,i);
        bPitch = strToPitch(bArr,i)-7+transpose;
		bDeg = [*RHSequence getDegree:bPitch];
        bAlt = strToAlt(bArr,i);
        
		
        
        
        // no flat 6 in minor
        if (mode == kHarmonicMinorMode) {
            if ((sDeg==5 || sDeg ==2) && sAlt == -1) {
                sAlt = 0;
            }
            if ((aDeg==5 || aDeg==2) && aAlt == -1) {
                aAlt = 0;
            }
            if ((tDeg==5 || tDeg==2) && tAlt == -1) {
                tAlt = 0;
            }
            if ((bDeg==5 || bDeg==2) && bAlt == -1) {
                bAlt = 0;
            }
            // raise 6th for sexondary dominants
            if (sDeg==5 && sAlt == 0 && level == 3) {
                sAlt = 1;
            }
            if (aDeg==5 && aAlt == 0 && level == 3) {
                aAlt = 1;
            }
            if (tDeg==5 && tAlt == 0 && level == 3) {
                tAlt = 1;
            }
        }
        
        
        seqNote = [*RHSequence addNoteWithPitch:sPitch
                            chromaticAlteration:sAlt
                                       duration:dur];
        [seqNote addPitch:aPitch
      chromaticAlteration:aAlt];
        
        seqNote = [*LHSequence addNoteWithPitch:tPitch
                            chromaticAlteration:tAlt
                                       duration:dur];
        [seqNote addPitch:bPitch
      chromaticAlteration:bAlt];
        
    }
    
}

+ (MNBaseSequence*)generateRandomScale:(int)startScale
                    endScale:(int)endScale
                    chosenScale:(int*)chosenScale
{
	MNBaseSequence *sequence;
	int i, numScaleTones;
	MNKeySignature *keySig;
	
	*chosenScale = RandomRange(startScale,endScale);
	sequence = [[MNBaseSequence alloc] initWithTimeSigEnum:8
                                              timeSigDenom:4
                                                 basePitch:random()%12
                                                      mode:*chosenScale
                                                      clef:kTrebleClef];
    keySig = [sequence keySignature];
    // hide key signature
    [keySig setDisplay:NO];
    numScaleTones = [keySig numScaleTones];
	[sequence setTimeSigEnum:numScaleTones+1 timeSigDenom:4];
	for (i=0;i<=numScaleTones;i++) {
		[sequence addNoteWithPitch:i chromaticAlteration:0 duration:1];
	}
	return sequence;
}
		

+ (void)randomChoralePhrase:(int*)modulation
                    cadence:(int*)cadence
                    sigCode:(int*)sigCode
                       mode:(int*)mode
                 tonicTriad:(BOOL)tonicTriad
            sopranoSequence:(MNBaseSequence**)sopranoSequence
               altoSequence:(MNBaseSequence**)altoSequence 
              tenorSequence:(MNBaseSequence**)tenorSequence 
               bassSequence:(MNBaseSequence**)bassSequence {
    
    NSString        *filePath,*chordProgStr,*choraleStr,*MIDIFileName,*MIDIFilePath,*riemen;
    NSArray         *choraleArr;
    int             nChorales,chosenChorale,numBars;
    MNMusicSequence *mySequence;
    BOOL            upbeat,goodPhrase;
    MNKeySignature  *keySig;
    float           sequenceDur,dur1,dur2,d,b;
    int             nPhrases,chosenPhrase,bassPitch1,bassAlt1,bassDegree1,bassPitch2,bassAlt2,bassDegree2;
    MNMusicTrack    *bassTrack,*theTrack,*sopranoTrack,*altoTrack,*tenorTrack;
    BOOL            noteFound;
    MusicTimeStamp  startTime;
    MNSequenceNote  *note;
    int				p11,p12,p21,p22,p31,p32,a11,a12,a21,a22,a31,a32,sopD1,sopD2,altD1,altD2,tenD1,tenD2;
	float			d11,d12,d21,d22,d31,d32;
	
    // choose a random chorale
    if (gChorales == nil) {
        // read in 3 chord progs
        filePath = [[NSBundle mainBundle] pathForResource:@"chorales" ofType:@"txt"];
        chordProgStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        gChorales = [chordProgStr componentsSeparatedByString:@"\n"];
    }
    
    nChorales = [gChorales count];
    chosenChorale = random()%nChorales;
    choraleStr = [gChorales objectAtIndex:chosenChorale];
    choraleArr = [choraleStr componentsSeparatedByString:@"\t"];
    
    // parse tab-delimited array
    // item 1 is Riemenschneider number (unused, for reference only)
	riemen = [choraleArr objectAtIndex:0];
	//NSLog(@"%@",riemen);
    // item 2 is the MIDI file name (need to append .mid)
    MIDIFileName = [choraleArr objectAtIndex:1];
    MIDIFilePath = [[NSBundle mainBundle] pathForResource:MIDIFileName ofType:@"mid"];
    // item 3 is a Boolean for whether there is an upbeat or not
    upbeat = [[choraleArr objectAtIndex:2] intValue];
    // item 4 is the sigCode
    *sigCode = [[choraleArr objectAtIndex:3] intValue];
    // item 5 is a Boolean for whether the chorale is in a minor key
    if ([[choraleArr objectAtIndex:4] intValue]) {
        *mode = kHarmonicMinorMode;
    } else {
        *mode = kMajorMode;
    }
    
    if (upbeat) {
        numBars = 3;
    } else {
        numBars = 2;
    }
    
    // ALLOCATE MEMORY FOR THE NEW SEQUENCES
    
    *sopranoSequence = [[MNBaseSequence alloc] initWithTimeSigEnum:4
                                                      timeSigDenom:4
                                                        keySigCode:*sigCode
                                                              mode:*mode
                                                              clef:kTrebleClef];
    
    
    *altoSequence = [[MNBaseSequence alloc] initWithTimeSigEnum:4
                                                   timeSigDenom:4
                                                     keySigCode:*sigCode
                                                           mode:*mode
                                                           clef:kTrebleClef];
    
    *tenorSequence = [[MNBaseSequence alloc] initWithTimeSigEnum:4
                                                    timeSigDenom:4
                                                      keySigCode:*sigCode
                                                            mode:*mode
                                                            clef:kTenor8Clef];
    
    *bassSequence = [[MNBaseSequence alloc] initWithTimeSigEnum:4
                                                   timeSigDenom:4
                                                     keySigCode:*sigCode
                                                           mode:*mode
                                                           clef:kBassClef];
    keySig = [*bassSequence keySignature];
    
    // now read in the MIDI file and find a phrase
    mySequence = [MNMusicSequence newSequenceFromMIDIFile:MIDIFilePath]; 
    
    // choose a random phrase
    sequenceDur = [mySequence duration];
    if (upbeat) sequenceDur -= 3.0;
    nPhrases = floor(sequenceDur / 8.0);
    goodPhrase = NO;
	sopranoTrack = [mySequence trackAtIndex:1];
	altoTrack = [mySequence trackAtIndex:2];
	tenorTrack = [mySequence trackAtIndex:3];
    bassTrack = [mySequence trackAtIndex:4];
    while (!goodPhrase) {
        chosenPhrase = random()%nPhrases;
        startTime = chosenPhrase * 8;
        if (upbeat) startTime += 3.0;
        noteFound = [bassTrack getPitch:&bassPitch1
                    chromaticAlteration:&bassAlt1
                               duration:&dur1
                                 atTime:startTime+7
                           keySignature:keySig
                            eventOffset:2];
        if (!noteFound) NSLog (@"couldn't find bass note 1");
        noteFound = [bassTrack getPitch:&bassPitch2
                    chromaticAlteration:&bassAlt2
                               duration:&dur2
                                 atTime:startTime+7
                           keySignature:keySig
                            eventOffset:1];
        if (!noteFound) NSLog (@"couldn't find bass note 2");
        bassDegree1 = [keySig getDegree:bassPitch1];
        bassDegree2 = [keySig getDegree:bassPitch2];
		
		
        noteFound = [sopranoTrack getPitch:&p11
                    chromaticAlteration:&a11
                               duration:&d11
                                 atTime:startTime+7-dur2
                           keySignature:keySig
                            eventOffset:1];
		noteFound = [sopranoTrack getPitch:&p12
					   chromaticAlteration:&a12
								  duration:&d12
									atTime:startTime+7
							  keySignature:keySig
							   eventOffset:1];
		noteFound = [altoTrack getPitch:&p21
					   chromaticAlteration:&a21
								  duration:&d21
									atTime:startTime+7-dur2
							  keySignature:keySig
							   eventOffset:1];
		noteFound = [altoTrack getPitch:&p22
					   chromaticAlteration:&a22
								  duration:&d22
									atTime:startTime+7
							  keySignature:keySig
							   eventOffset:1];
		noteFound = [tenorTrack getPitch:&p31
					   chromaticAlteration:&a31
								  duration:&d31
									atTime:startTime+7-dur2
							  keySignature:keySig
							   eventOffset:1];
		noteFound = [tenorTrack getPitch:&p32
					   chromaticAlteration:&a32
								  duration:&d32
									atTime:startTime+7
							  keySignature:keySig
							   eventOffset:1];
        goodPhrase = (d12 == dur2 && d22 == dur2 && d32 == dur2);
		
		sopD1 = [keySig getDegree:p11];
		sopD2 = [keySig getDegree:p12];
		altD1 = [keySig getDegree:p21];
		altD2 = [keySig getDegree:p22];
		tenD1 = [keySig getDegree:p31];
		tenD2 = [keySig getDegree:p32];
		
        // find modulation
        //MAJOR KEY:
		if (goodPhrase) {
			goodPhrase = NO;
        if (*mode == kMajorMode) {
            switch (bassDegree2) {
                case 0:
                    if (bassDegree1==4 || bassDegree1==7 || bassDegree1==1) {
                        *cadence = kPerfectCadenceChorale;
                        *modulation = kTonic;
                        goodPhrase = YES;
                    }
                    break;
                    
                case 1:
					if (bassDegree1 == 2) {
						// is this perfect in supertonic or imperfect in dominant
						// difference is that chord one should have raised leading note in st (#0)
						if ((sopD1 == 0 && a11 ==1) || (altD1 == 0 && a21 == 1) || (tenD1 == 0 && a31 == 1)) {
							*cadence = kPerfectCadenceChorale;
							*modulation = kSuperTonic;
							goodPhrase = YES;
						} else {
							*cadence = kImperfectCadenceChorale;
							*modulation = kDominant;
							goodPhrase = YES;
						}
					}
                    if (bassDegree1 == 4) {
                        *cadence = kImperfectCadenceChorale;
                        *modulation = kDominant;
                        goodPhrase = YES;
                    }
                    
                    if ((bassDegree1 == 0 && bassAlt1 == 1) || bassDegree1 == 5) {
                        *cadence = kPerfectCadenceChorale;
                        *modulation = kSuperTonic;
                        goodPhrase = YES;
                    }
                    break;
                    
                case 2:
                    if (bassDegree1 == 3 || bassDegree1 == 5) {
                        *cadence = kImperfectCadenceChorale;
                        *modulation = kRelativeMinor;
                        goodPhrase = YES;
                    }
                    break;
                    
                case 3:
                    if (bassDegree1==0 || bassDegree1==2 || bassDegree1==4) {
                        *cadence = kPerfectCadenceChorale;
                        *modulation = kSubdominant;
                        goodPhrase = YES;
                    }
                    break;
                    
                case 4:
					if (bassAlt2 == 0) {
						if (bassDegree1 == 0 || (bassDegree1 == 3 && bassAlt1 == 0)) {
							*cadence = kImperfectCadenceChorale;
							*modulation = kTonic;
							goodPhrase = YES;
						}
						if (bassDegree1 == 1 || (bassDegree1 == 3 && bassAlt1 == 1) || bassDegree1 == 5) {
							*cadence = kPerfectCadenceChorale;
							*modulation = kDominant;
							goodPhrase = YES;
						}
					}
					if (bassAlt2 ==1) {
						if (bassDegree1 == 5) {
							*cadence = kImperfectCadenceChorale;
							*modulation = kRelativeMinor;
							goodPhrase = YES;
						}
					}
                    break;
                    
                case 5:
                    if (bassDegree1 == 2 || (bassDegree1 == 4 && bassAlt1 == 1)) {
                        *cadence = kPerfectCadenceChorale;
                        *modulation = kRelativeMinor;
                        goodPhrase = YES;
                    }
                    break;
                    
            } // end switch
            
        } else {
            
            //MINOR KEY:
            
            switch (bassDegree2) {
                case 0:
                    if (bassDegree1 == 4 || bassDegree1 == 7 || bassDegree1 == 1) {
						if ((sopD2 == 2 && a12 == 1) || (altD2 == 2 && a22 == 1) || (tenD2 == 2 && a32 == 1)) {
							*cadence = kPerfectCadenceTierceChorale;
						} else {
							*cadence = kPerfectCadenceChorale;
						}
                        *modulation = kTonic;
                        goodPhrase = YES;
                    }
                    break;
                case 1:
                    if (bassDegree1 ==2 || bassDegree1 == 4) {
                        *cadence = kImperfectCadenceChorale;
                        *modulation = kDominantMinor;
                        goodPhrase = YES;
                    }
                    if (bassDegree1 ==5 || (bassDegree1 == 0 && bassAlt1 == 1)) {
                        *cadence = kPerfectCadenceChorale;
                        *modulation = kSuperTonic;
                        goodPhrase = YES;
                    }
                    break;
                case 2:
                    if ((bassDegree1==6 && bassAlt1==-1) || (bassDegree1==1)) {
                        *cadence = kPerfectCadenceChorale;
                        *modulation = kRelativeMajor;
                        goodPhrase = YES;
                    }
                    break;
                case 3:
                    if ((bassDegree1 == 2 && bassAlt1==1) || bassDegree1 == 0) {
                        *cadence = kPerfectCadenceChorale;
                        *modulation = kSubdominant;
                        goodPhrase = YES;
                    }
                    break;
                case 4:
                    if (bassDegree1 == 0 || (bassDegree1 == 5 && bassAlt1 == 0) ) {
                        *cadence = kImperfectCadenceChorale;
                        *modulation = kTonic;
                        goodPhrase = YES;
                    }
                    if (bassDegree1 == 1 || (bassDegree1 == 5 && bassAlt1 == 1) ) {
                        *cadence = kPerfectCadenceChorale;
                        *modulation = kDominantMinor;
                        goodPhrase = YES;
                    }
					if (bassDegree1 == 3) {
						if ((sopD2 == 6 && a12 == -1) || (altD2 == 6 && a22 == -1) || (tenD2 == 6 && a32 == -1)) {
							*cadence = kPerfectCadenceChorale;
							*modulation = kDominantMinor;
							goodPhrase = YES;
						} else {
							*cadence = kImperfectCadenceChorale;
							*modulation = kTonic;
							goodPhrase = YES;
						}
					}
                    break;
                case 5:
                    break;
                case 6:
                    if (bassAlt2 == -1 && (bassDegree1 == 3 || (bassDegree1 == 5 && bassAlt1 == 1))) {
                        *cadence = kPerfectCadenceChorale;
                        *modulation = kFlattenedLeadingNote;
                        goodPhrase = YES;
                    }
                    break;
                case 7:
                    break;
            } // end switch
        } // end minor mode
        
        // a lot more tonic perfects, so reduce the likelihood:
        if (goodPhrase && *cadence == kPerfectCadenceChorale && *modulation == kTonic) {
            if (random()%10 >= 3) {
                goodPhrase = NO;
            }
        }
		}
    } // end while good phrase
    
    // PHRASE FOUND
    
    // copy phrase to sequences
    if (tonicTriad) {
        [*sopranoSequence addTriadOnDegree:0
                                 triadType:kDiatonicTriad
                                 inversion:kRootPosition
                                   seventh:0
                                  duration:3];
        [*altoSequence addRestWithDuration:3];
        [*tenorSequence addRestWithDuration:3];
        [*bassSequence addNoteWithPitch:-7
					chromaticAlteration:0
							   duration:3];
    
		[*sopranoSequence addRestWithDuration:1];
		[*altoSequence addRestWithDuration:1];
		[*tenorSequence addRestWithDuration:1];
		[*bassSequence addRestWithDuration:1];
    }
	
    if (upbeat) {
		[*sopranoSequence newBarWithTimeSignatureEnum:1
												denom:4];
		
		[*altoSequence newBarWithTimeSignatureEnum:1
												denom:4];
		
		[*tenorSequence newBarWithTimeSignatureEnum:1
												denom:4];
		
		[*bassSequence newBarWithTimeSignatureEnum:1
												denom:4];
		
		//
		
		[*sopranoSequence newBarWithTimeSignatureEnum:4
												denom:4];
		
		[*altoSequence newBarWithTimeSignatureEnum:4
											 denom:4];
		
		[*tenorSequence newBarWithTimeSignatureEnum:4
											  denom:4];
		
		[*bassSequence newBarWithTimeSignatureEnum:4
											 denom:4];
		
    }
    
    theTrack = [mySequence trackAtIndex:1];
    [theTrack convertMIDIToBaseSequence:*sopranoSequence
                              startTime:startTime
                               duration:8];
    
    theTrack = [mySequence trackAtIndex:2];
    [theTrack convertMIDIToBaseSequence:*altoSequence
                              startTime:startTime
                               duration:8];
    
    theTrack = [mySequence trackAtIndex:3];
    [theTrack convertMIDIToBaseSequence:*tenorSequence
                              startTime:startTime
                               duration:8];
    
    theTrack = [mySequence trackAtIndex:4];
    [theTrack convertMIDIToBaseSequence:*bassSequence
                              startTime:startTime
                               duration:8];
    
    if (upbeat) {
		b = [[*sopranoSequence lastBar] duration];
		if (b < 4) {
			note = [*sopranoSequence lastNote];
			d = [note duration];
			[note setDuration:d+4-b];
		}
        b = [[*altoSequence lastBar] duration];
		if (b < 4) {
			note = [*altoSequence lastNote];
			d = [note duration];
			[note setDuration:d+4-b];
		}
		b = [[*tenorSequence lastBar] duration];
		if (b < 4) {
			note = [*tenorSequence lastNote];
			d = [note duration];
			[note setDuration:d+4-b];
		}
		b = [[*bassSequence lastBar] duration];
		if (b < 4) {
			note = [*bassSequence lastNote];
			d = [note duration];
			[note setDuration:d+4-b];
		}
    }
}

// NSDictionary -> "duple", "triple"
// NSDictionary -> "1","2","3", etc
// NSMutableArray -> NSMutableArrays
// NSMutableArray -> 0.25 etc.
+ (NSMutableArray *)getRhythmArrayForMetre:(int)metre
                                     grade:(int)grade
{
    NSMutableArray	*array1;
    NSDictionary	*rhythmDict=nil;
    NSString		*gradeKey;
    int			n,i;
    
    switch (metre) {
        case kDupleMetre:
            rhythmDict = [gRhythmsDict objectForKey:@"duple"];
            break;
        case kTripleMetre:
            rhythmDict = [gRhythmsDict objectForKey:@"triple"];
            break;
        default:
            rhythmDict = nil;
            break;
    }
    gradeKey = [NSString stringWithFormat:@"%i",grade];
    array1 = [rhythmDict objectForKey:gradeKey];
    n = [array1 count];
    i = random()%n;
    return [array1 objectAtIndex:i];
}
@end
