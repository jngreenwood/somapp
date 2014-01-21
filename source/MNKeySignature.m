////  MNKeySignature.m//  NotationTest////  Created by Michael Norris on Wed Apr 30 2003.//  Copyright (c) 2009 New Zealand School of Music. All rights reserved.//// ** NB: ALL DIATONIC PITCHES ARE ZERO-BASED (0-7) ** //#import "MNKeySignature.h"#define isMajorMode(m) (baseModeType[m]==kMajMode)#define kMajMode	0#define kMinMode	1#define kNil	99#define kMaxNumScaleTones 8// MODE INFORMATION ARRAYS// These arrays detail information specific to individual scales/modesstatic NSArray *modeNameArray=nil;int baseModeType[kNumModes] = {kMajMode,		// major - 0kMinMode,		// harmonic minor - 1kMinMode,		// natural minor - 2kMajMode,		// Ionian - 3kMinMode,		// Dorian - 4kMinMode,		// Phrygian - 5kMajMode,		// Lydian - 6kMajMode,		// Mixolydian -7 kMinMode,		// Aeolian - 8kMinMode,		// Locrian - 9kMajMode,		// Acoustic - 10kMajMode,		// Mix flat 6 - 11kMinMode,		// Aeolian fl 5 - 12kMinMode,		// Mel Min Asc - 13kMajMode,		// Lyd Aug - 14kMajMode,		// octatonic - 15kMajMode,		// wholetone -16kMajMode,		// harmonic major - 17kMinMode,		// Dorian fl 5 - 18kMinMode,		// mel min asc raised 4 - 19kMinMode,		// Harmonic minor - 20kMinMode,		// Locrian raised 6th - 21kMinMode,		// Dorian raised 4thkMajMode		// Hexatonic};// modebits array is a list of pitch class integers that specifies the chromatic construction of the modeint modebits[kNumModes][8] ={{0,2,4,5,7,9,11,kNil},		// major - 0{0,2,3,5,7,8,11,kNil},		// harmonic minor - 1{0,2,3,5,7,8,10,kNil},		// natural minor - 2{0,2,4,5,7,9,11,kNil},		// Ionian - 3{0,2,3,5,7,9,10,kNil},		// Dorian - 4{0,1,3,5,7,8,10,kNil},		// Phrygian - 5{0,2,4,6,7,9,11,kNil},		// Lydian - 6{0,2,4,5,7,9,10,kNil},		// Mixolydian - 7{0,2,3,5,7,8,10,kNil},		// Aeolian - 8{0,1,3,5,6,8,10,kNil},		// Locrian - 9{0,2,4,6,7,9,10,kNil},		// Acoustic - 10{0,2,4,5,7,8,10,kNil},		// Mixolydian flat 6 - 11{0,2,3,5,6,8,10,kNil},		// Aeolian flat 5 - 12{0,2,3,5,7,9,11,kNil},		// Melodic minor ascending - 13{0,2,4,6,8,9,11,kNil},		// Lydian augmented{0,1,3,4,6,7,9,10},			// Octatonic{0,2,4,6,8,10,kNil,kNil},	// Whole-tone{0,2,4,5,7,8,11,kNil},		// Harmonic major{0,2,3,5,6,9,10,kNil},		// Dorian flat 5{0,2,3,6,7,9,11,kNil},		// Melodic minor ascending raised 4{0,2,3,5,7,8,11,kNil},		// Harmonic minor{0,1,3,5,6,9,10,kNil},		// Locrian raised 6{0,2,3,6,7,9,10,kNil},		// Dorian raised 4{0,1,4,5,8,9,kNil,kNil}		// Hexatonic};// converts a pitch class into a degree - used in conjunction with altArray to give a diatonic degree and alteration from a chromatic pitchint degreeArray[kNumModes][12] ={{0,0,1,2,2,3,3,4,4,5,6,6}, // major - 0{0,1,1,2,2,3,3,4,5,5,6,6},	// harmonic minor - 1{0,1,1,2,2,3,3,4,5,5,6,6},	// natural minor - 2{0,0,1,2,2,3,3,4,5,5,6,6},	// Ionian - 3{0,1,1,2,2,3,3,4,5,5,6,6},	// Dorian - 4{0,1,1,2,2,3,3,4,5,5,6,6},	// Phrygian - 5{0,0,1,2,2,3,3,4,5,5,6,6},	// Lydian - 6{0,0,1,2,2,3,3,4,5,5,6,6},	// Mixolydian - 7{0,1,1,2,2,3,3,4,5,5,6,6},	// Aeolian - 8{0,1,1,2,2,3,4,4,5,5,6,6},	// Locrian - 9{0,0,1,2,2,3,3,4,4,5,6,6},	// Acoustic - 10{0,0,1,2,2,3,3,4,5,5,6,6},	// Mixolydian Flat 6 - 11{0,1,1,2,2,3,4,4,5,5,6,6},	// Aeolian Flat 5 - 12{0,1,1,2,2,3,3,4,5,5,6,6},	// Melodic minor ascending - 13{0,1,1,2,2,3,3,4,4,5,6,6},	// Lydian Augmented{0,1,2,2,3,4,4,5,6,6,7,7},	// Octatonic{0,0,1,1,2,3,3,4,4,5,5,5},	// Whole-tone{0,0,1,2,2,3,3,4,5,5,6,6},	// Harmonic major{0,1,1,2,2,3,3,4,5,5,6,6},	// Dorian Flat Five{0,1,1,2,2,3,3,4,5,5,6,6},	// Melodic minor ascending raised 4{0,1,1,2,2,3,3,4,5,5,6,6},	// Harmonic minor{0,1,1,2,2,3,4,4,5,5,6,6},	// Locrian raised 6{0,1,1,2,2,3,3,4,5,5,6,6},	// Dorian raised 4{0,1,1,2,2,3,3,4,4,5,5,5},	// Hexatonic};// given a chromatic pitch class 0-12, and a degree from degreeArray,// this array returns the chromatic alterationint altArray[kNumModes][12] ={{0,kRaised,0,kLowered,0,0,kRaised,0,kRaised,0,kLowered,0},		// major{0,kLowered,0,0,kRaised,0,kRaised,0,0,kRaised,kLowered,0},		// harmonic minor{0,kLowered,0,0,kRaised,0,kRaised,0,0,kRaised,0,kRaised},		// natural minor{0,kRaised,0,kLowered,0,0,kRaised,0,kLowered,0,kLowered,0},		// Ionian{0,kLowered,0,0,kRaised,0,kRaised,0,kLowered,0,0,kRaised},		// Dorian{0,0,kRaised,0,kRaised,0,kRaised,0,0,kRaised,0,kRaised},		// Phrygian{0,kRaised,0,kLowered,0,kLowered,0,0,kLowered,0,kLowered,0},	// Lydian{0,kRaised,0,kLowered,0,0,kRaised,0,kLowered,0,0,kRaised},		// Mixolydian{0,kLowered,0,0,kRaised,0,kRaised,0,0,kRaised,0,kRaised},		// Aeolian{0,0,kRaised,0,kRaised,0,0,kRaised,0,kRaised,0,kRaised},		// Locrian{0,kRaised,0,kLowered,0,kLowered,0,0,kRaised,0,0,kRaised},		// Acoustic{0,kRaised,0,kLowered,0,0,kRaised,0,0,kRaised,0,kRaised},		// Mixolydian Flat 6{0,kLowered,0,0,kRaised,0,0,kRaised,0,kRaised,0,kRaised},		// Aeolian Flat 5{0,kLowered,0,0,kRaised,0,kLowered,0,kLowered,0,kLowered,0},	// Melodic Minor Ascending{0,kRaised,0,kLowered,0,kLowered,0,kLowered,0,0,kLowered,0},	// Lydian Augmented{0,0,kLowered,0,0,kLowered,0,0,kLowered,0,0,kLowered},			// Octatonic{0,kRaised,0,kRaised,0,kLowered,0,kLowered,0,kLowered,0,kRaised}, // Whole-tone{0,kRaised,0,kLowered,0,0,kRaised,0,0,kRaised,kLowered,0},		// Harmonic major{0,kLowered,0,0,kRaised,0,0,kRaised,kLowered,0,0,kRaised},		// Dorian flat 5{0,kLowered,0,0,kRaised,kLowered,0,0,kLowered,0,kLowered,0},	// Melodic Minor Ascending raised 4{0,kLowered,0,0,kRaised,0,kRaised,0,0,kRaised,kLowered,0},		// Harmonic minor{0,0,kRaised,0,kRaised,0,0,kRaised,kLowered,0,0,kRaised},		// Locrian raised 6{0,kLowered,0,0,kRaised,kLowered,0,0,kLowered,0,0,kRaised},		// Dorian raised 4{0,0,kRaised,kLowered,0,0,kRaised,kLowered,0,0,kRaised,kDoubleRaised}	// Hexatonic};// the following is used to suggest possible common alterations for a scaleint	bestChromAltForDegreeArray[kNumModes][7] ={{0,0,-1,1,0,-1,-1}, 	// major{0,-1,0,1,0,1,-1},		// harmonic minor{0,-1,0,1,0,1,1},		// natural minor{0,0,-1,1,0,-1,-1},		// ionian{0,0,0,1,0,-1,1},		// dorian{0,1,0,1,0,1,1},		// phrygian{0,0,-1,-1,0,-1,-1},	// lydian{0,0,-1,1,0,-1,1},		// mixolydian{0,-1,0,1,0,1,1},		// aeolian{0,1,1,0,1,0,1},		// locrian{0,1,-1,1,0,1,-1},		// 2nd byzantine mode{0,0,0,-1,0,-1,1},		// Lydian Dominant mode{0,0,0,-1,-1,0,-1}		// Lydian augmented};int	desperateChromAltForDegreeArray[kNumModes][7] = {{1,-1,-1,1,1,-1,-1},	// major{1,-1,1,1,-1,1,-1},		// harmonic minor{1,-1,1,1,-1,1,1},		// natural minor{1,-1,-1,1,1,-1,-1},	// ionian{1,-1,1,1,-1,-1,1},		// dorian{1,1,1,1,-1,1,1},		// phrygian{1,-1,-1,-1,1,-1,-1},	// lydian{1,-1,-1,1,1,-1,1},		// mixolydian{1,-1,1,1,-1,1,-1},		// aeolian{1,1,1,1,1,1,1},		// locrian{1,1,-1,1,-1,1,-1},		// 2nd byzantine mode{1,-1,-1,-1,1,-1,1},	// lydian dominant{1,-1,-1,-1,-1,-1,-1}	// Lydian augmented};//extern	int	*gClefOffsets;@implementation MNKeySignature+ (MNKeySignature *)keySignatureWithBasePitch:(int)bp mode:(int)m {    return [[MNKeySignature alloc] initWithBasePitch:bp mode:m];}- (void)initModeNames {	if (modeNameArray == nil) {		modeNameArray	= @[@"major",						   @"minor",						   @"minor",						   @"Ionian",						   @"Dorian",						   @"Phrygian",						   @"Lydian",						   @"Mixolydian",						   @"Aeolian",						   @"Locrian",						   @"Acoustic",						   @"Mixolydian flat 6",						   @"Aeolian flat 5",						   @"Melodic minor ascending",						   @"Lydian augmented",						   @"Octatonic",						   @"Whole-tone",						   @"Harmonic major",						   @"Dorian flat 5",						   @"Melodic minor ascending raised 4",						   @"Harmonic minor",						   @"Locrian raised 6",						   @"Dorian raised 4",						   @"Hexatonic"];	}}	- (id)init {	self = [super init];    if (self) {		display = YES;		[self initModeNames];			}	return self;}- (id)initWithBasePitch:(int)s mode:(int)m {    self = [super init];    if (self) {        [self setMode:m];        [self setBasePitch:s];        display = YES;        basePitchOffsetFromB = [self basePitchOffsetFromMiddleB];		[self initModeNames];    }    return self;}- (id)initWithSigCode:(int)i mode:(int)m {    self = [super init];    if (self) {        [self setMode:m];        [self setSigCode:i];        display = YES;        basePitchOffsetFromB = [self basePitchOffsetFromMiddleB];		[self initModeNames];    }    return self;}- (int)pitchFromChromaticPitch:(int)i {    int octave = getChromaticOctave(i);    int degree = getChromaticDegree(i);      return (degreeArray[mode][degree])+(octave*[self numScaleTones]);}- (int)altFromChromaticPitch:(int)i {    int degree = getChromaticDegree(i);    return (altArray[mode][degree]);}- (int)actualAccidentalForPitch:(int)p							alt:(int)a {	int keySigAlt,nonKeySigAlt,actualAcc;	keySigAlt = [self KSAltForPitch:p];	nonKeySigAlt = [self nonKSAltForPitch:p];    actualAcc = keySigAlt+nonKeySigAlt+a;	return actualAcc;}- (int)chromaticPitchFromPitch:(int)i {	int chromPitch;    int octave = [self getOctave:i];    int degree = [self getDegree:i];		if (degree < 0 || degree > 6) {		NSLog(@"urgh");	}        chromPitch = (modebits[mode][degree])+(12*octave);	if (chromPitch == kNil) {		NSLog(@"chromPitch note found");	}	return chromPitch;}- (int)chromaticPitchFromPitch:(int)palt:(int)a {	return [self chromaticPitchFromPitch:p]+a;}/*- (void)addObjectsToDisplayList:(NSMutableArray *)displayList system:(MNSystem*)system {    int			start=0, offset, mod=0, add, i;    int 		accidentalGlyph;    NSPoint		p;    float		glyphOffset = 0.0;    MNGlyphElement	*g;    NSRect		systemRect = [system systemRect];    if (display == YES) {        add = 7;        if (sigCode != 0) {            if (sigCode>0) {                // SHARPS                accidentalGlyph = kSharpGlyph;                offset = -3;                glyphOffset = kSharpGlyphYOffset;                switch ([system clef]) {                    case kTrebleClef:					case kTenor8Clef:                        // starts on upper F#                        // wraps around when reaching G                        start = 4; mod = -2;                        break;                    case kAltoClef:                        start = 3; mod = -3;                        break;                    case kTenorClef:                        start = 5; mod = -2;                        break;                    case kBassClef:                        start = 2; mod = -4;                        break;                    default:                        ;                }            } else {                // FLATS                accidentalGlyph = kFlatGlyph;                offset = 3;                glyphOffset = kFlatGlyphYOffset;                switch ([system clef]) {                    case kTrebleClef:					case kTenor8Clef:                        start = 0; mod = 4;                        break;                    case kAltoClef:                        start = -1; mod = 3;                        break;                    case kTenorClef:                        start = 1; mod = 4;                        break;                    case kBassClef:                        start = -2; mod = 2;                        break;                    default:                        ;                }            }            p.x = NSMinX(systemRect) + kKeySignatureXOffset;            for (i=0;i<abs(sigCode);i++) {                p.y = [system midStaffYCoord] + (start * kStaffLinesSpacing / 2) + glyphOffset;                g = [[MNGlyphElement alloc] initWithGlyph:accidentalGlyph atPoint:p withAttributes:nil];                [displayList addObject:g];                p.x += kKeySignatureSpacing;                start += offset;                if (mod<0) {                    if (start <= mod) {                        start += add;                    }                } else {                    if (start >= mod) {                        start -= add;                    }                }            }        }    }}*//*- (float)keySignatureWidth {	if (!display) return 0;	return abs(sigCode) * kAccGlyphWidth;}*/- (void)getCorrectAltForPitch:(int*)pitch			STOffsetFromTonic:(int*)alt{    int	degree,octave,numST;	// if both arguments are non-zero then	// pitch is the diatonic degree	// and alt holds the offset in semitones	octave = [self getOctave:*pitch];	degree = [self getDegree:*pitch];	if (degree < 0 || degree >= [self numScaleTones]) {		NSLog(@"diatonic degree was: %i",degree);	}	numST = [self semitonesFromDegree:0 toDegree:*pitch];	*alt = *alt-numST;	if (abs(*alt)>1000) {		NSLog(@"nonsense");	}}// MAJOR KEY ONLY- (void)chromaticIntervalFromPitch:(int)pitch1           fromChromaticAlteration:(int)alt1                      intervalCode:(int)chosenIntervalCode                           ascDesc:(int)ascDesc                          outPitch:(int*)pitch            outChromaticAlteration:(int*)alt{    int	startST,intST;    int	startDegree;    int	intervalType, intervalNumber;	    [MNCommonFunctions extractIntervalCode:chosenIntervalCode                 intervalType:&intervalType                 intervalName:&intervalNumber];    startDegree = [self getDegree:pitch1];    if (startDegree < 0 || startDegree > 6) {        NSLog(@"startDegree was: %i",startDegree);    }    startST = [self semitonesFromDegree:0 toDegree:startDegree]+[self getOctave:pitch1]*12;    startST += alt1;    intervalNumber *= ascDesc;    intST = [MNCommonFunctions semitonesFromIntervalCode:chosenIntervalCode]*ascDesc;    *pitch = pitch1+intervalNumber;    *alt = startST + intST;    [self getCorrectAltForPitch:pitch			  STOffsetFromTonic:alt];}/*- (int)pitchToNumLedgerLines:(int)pitch                        clef:(int)clef{    int n=0;    int pitchPosition = [self pitchPositionOnStaff:pitch clef:clef];    // pitch position is offset from centre staff line        if (pitchPosition < -5) {        n = (floor(abs(pitchPosition) - 4.0) / 2.0)*-1;    }    if (pitchPosition > 5) {        n = floor((pitchPosition - 4.0) / 2.0);    }    return n;}*/- (void)convertChromaticToDiatonicPitch:(int*)pitch alteration:(int*)alt {    // pitch is in semitones from base pitch (e.g. 0-11 is first octave from base pitch)    *alt = [self altFromChromaticPitch:*pitch];    *pitch = [self pitchFromChromaticPitch:*pitch];}- (int)semitonesFromDegree:(int)start toDegree:(int)end {    int startSTFromBP = 0;    int endSTFromBP = 0;    if (start!=0) {        startSTFromBP = [self chromaticPitchFromPitch:start];    }    if (end!=0) {        endSTFromBP = [self chromaticPitchFromPitch:end];    }    return (endSTFromBP - startSTFromBP);}// NB: only returns positive number- (int)semitonesFromIntervalCode:(int)chosenIntervalCode {    int pitch,alt;    if ([self getPitchAndAltFromStartDegree:0                               intervalCode:chosenIntervalCode                                    ascDesc:kAscending                                      pitch:&pitch                        chromaticAlteration:&alt]) {        return [self semitonesFromDegree:0 toDegree:pitch] + alt;    } else {        return 0;    }}// returns whether or not the interval makes sense (e.g. major fourth returns NO)- (BOOL)getPitchAndAltFromStartDegree:(int)start                         intervalCode:(int)code                              ascDesc:(int)ascDesc                                pitch:(int*)pitch                  chromaticAlteration:(int*)alt{    int intervalTypes[8] = {kPerf,kMaj,kMaj,kPerf,kPerf,kMaj,kMaj,kPerf};    // this matrix shows the alteration that needs to occur to map the normal    // intervalType to the required interval type    // each submatrix is for the required (i.e. first one is how to get major)    // insert 99 for those that are nonsensical (like a major fourth)    // order is maj,min,perf,aug,dim    int altMatrix[5][5] = {{0,+1,99,-1,+2},{-1,0,99,-2,+1},{99,99,0,-1,+1},{+1,+2,+1,0,+2},{-2,-1,-1,-2,0}};    int majorAscST,st,majorAsciType,end,stOffset;    int	intervalType,intervalName;    int majST[7] = {0,2,4,5,7,9,11};    [MNCommonFunctions extractIntervalCode:code                              intervalType:&intervalType                              intervalName:&intervalName];    // Let's say we want an augmented sixth    // First find out how many semitones a sixth has *IN THIS KEY SIGNATURE*    // For instance, in a minor key, a sixth up from tonic would have 8 sts    end = start + (intervalName * ascDesc);    st = [self semitonesFromDegree:start toDegree:end];    // next we calculate how big an augmented sixth would be in semitones.    // we do this by calculating the base interval in a major key ascending    // so a sixth would be 9 sts    majorAscST = majST[intervalName];    // now we calculate the alteration we would need to make to get the sixth    // *IN THIS KEY SIGNATURE* into a major key signature    // in our sample case, stOffset would now be 1    stOffset = majorAscST - abs(st);    // now we've done that, we now need to convert the major key interval into the    // required interval. For instance, converting that major sixth into an augmented    // the first thing to do is work out what the interval type of that major key int was    majorAsciType = intervalTypes[intervalName];    // now work out whether the req interval and the major key interval are different    if (majorAsciType != intervalType) {        // work out how far off we are from the required intervalType        if (altMatrix[intervalType-1][majorAsciType-1]==99) {            return NO;        } else {            // for an augmented sixth, we'd look up altMatrix[kAug-1][kMaj-1]            // ... = altMatrix[3][0]            // ... = +1            stOffset += altMatrix[intervalType-1][majorAsciType-1];        }    }    // if it's descending, we want to mirror image it.    if (ascDesc == kDescending) stOffset *= -1;    *pitch = end;    *alt = stOffset;    return YES;}- (int)intervalCodeFromStartDegree:(int)start                         endDegree:(int)end{    int intervalType,intervalName;    int st,normalST, normaliType;    int majorIntervals[] = {0,2,4,5,7,9,11,12};    int intervalTypes[] = {kPerf,kMaj,kMaj,kPerf,kPerf,kMaj,kMaj,kPerf};    // warning only accepts non-unison diatonic intervals <= 8ve    intervalName = (end>start)?(end-start):(start-end);    if (intervalName < 1 || intervalName > 8) return 0;    st = abs([self semitonesFromDegree:start toDegree:end]);    normalST = majorIntervals [intervalName];    normaliType = intervalTypes [intervalName];    intervalType = normaliType;    if (st!=normalST) {        switch (st-normalST) {            case -1:                switch (normaliType) {                    case kMaj:                        intervalType = kMin;                        break;                    case kPerf:                        intervalType = kDim;                        break;                }                break;            case -2:                intervalType = kDim;                break;            case +1:                intervalType = kAug;                break;        }    }    return [MNCommonFunctions intervalCodeFromIntervalType:intervalType                                              intervalName:intervalName];}- (int)MIDIPitchWithPitch:(int)pitch chromaticAlteration:(int)alt {    int STFromBP;    // work out semitones from base pitch    STFromBP = [self semitonesFromDegree:0 toDegree:pitch]+alt+basePitch+kMiddleCMIDI;    return STFromBP;}- (void)convertMIDINote:(int)MIDINote toPitch:(int*)pitch chromaticAlteration:(int*)alt {    // work out semitones from base pitch    *pitch = MIDINote - kMiddleCMIDI - basePitch;    [self convertChromaticToDiatonicPitch:pitch alteration:alt];}- (int)basePitchOffsetFromMiddleB {	// determines how far, in terms of lines and spaces, the base pitch is from the middle line of the treble staff	// So C major would be -6    int offset=0;    // we start by working out where we would be if we are in major mode with this key signature	if (sigCode > 0) {		offset = (sigCode * 4) %7;	}	if (sigCode < 0) {		offset = (abs(sigCode) * 3) % 7;	}	    if (!isMajorMode(mode)) {		offset -= 2;    }	while (offset < 0) { offset += 7; }	// offset should be a number from 0-6     return offset - 6;}/*- (int)getAccGlyphForAccidental:(int)acc{    int accGlyph=0;    switch (acc) {		case 0:			accGlyph = kNaturalGlyph;			break;		case 1:			accGlyph = kSharpGlyph;			break;		case 2:			accGlyph = kDoubleSharpGlyph;			break;		case 3:			accGlyph = kTripleSharpGlyph;			break;		case -1:			accGlyph = kFlatGlyph;			break;		case -2:			accGlyph = kDoubleFlatGlyph;			break;		case -3:			accGlyph = kTripleFlatGlyph;			break;	}				return accGlyph;}*/// returns any accidentals which are part of the mode, but not the key signature// returns 1 if it's raised or -1 if it's lowered- (int)nonKSAltForPitch:(int)pitch {    int p = [self getDegree:pitch];    switch (mode) {        case kHarmonicMinorMode:            // raised seventh in harmonic minor            return (p==6);            break;        case kDorianMode:            // raised sixth in Dorian            return (p==5);            break;        case kPhrygianMode:            // flat two in Phyrgian            return -(p==1);            break;        case kLydianMode:            // sharp four in Lydian            return (p==3);            break;        case kMixolydianMode:            // flat seven in Mixolydian            return -(p==6);            break;        case kLocrianMode:            // flat 2, flat 5            return -(p==1 || p==4);            break;		case kAcousticMode:            // sharp 4, flat 7			if (p==3) return 1;			if (p==6) return -1;            break;		case kMixolydianFlatSixMode:			// flat 6, flat 7			return -(p==5 || p==6);            break;		case kAeolianFlatFiveMode:			// flat 5            return -(p==4);            break;		case kMelodicMinorAscendingMode:			// raised 6th & 7th			return (p==5 || p==6);            break;		case kLydianAugmentedMode:			// raised 4, 5			return (p==3 || p==4);            break;		case kOctatonicMode:			if (p == 1 || p==2 || p==4) return 1;			if (p==7) return -1;            break;		case kWholeToneMode:			// sharp 4, 5, 6			return (p>2);            break;		case kHarmonicMajorMode:			// flat 6			return -(p==5);            break;		case kDorianFlatFiveMode:			// flat 5, raised 6			if (p==4) return -1;			if (p==5) return 1;            break;		case kMelodicMinorAscendingRaisedFourthMode:			// raised 4, raised 6th, raised 7			return (p==3 || p==5 || p==6);            break;		case kHarmonicMinor2Mode:			// raised 7			return (p==6);            break;		case kLocrianRaisedSixMode:			// flat 2, flat 5, raised 6			if (p==1 || p==4) return -1;			if (p==5) return 1;            break;		case kDorianRaisedFourMode:			// sharp 4, sharp 6			return (p==3 || p==5);            break;		case kHexatonicMode:			if (p==1) return 1;			if (p==4) return -1;			break;    }    return 0;}// this routine works out what the accidental in the key signature for this note is- (int)KSAltForPitch:(int)pitch {    int firstAccSharp=0,firstAccFlat=0;    int adjPitch,order,currAcc = kNaturalFlag;    // each mode type has a different offset from the first accidental    // in major keys it's 6 for sharps and 3 for flats    // in minor keys it's 1 for sharps and 5 for flats    if (isMajorMode(mode)) {			firstAccSharp = -1; // this is negative for subtle reasons            firstAccFlat = 3;	} else {            firstAccSharp = 1;            firstAccFlat = 5;    }    // now work out the scale degree from 0-6    adjPitch = [self convertScaleDegreeToStaffOffset:[self getDegree:pitch]];    // now suss out whether this scale degree is raised or lowered    if (sigCode < 0) {        // flats        adjPitch -= firstAccFlat;        adjPitch = (((adjPitch+7)%7)*2);        order = (adjPitch>6)?(adjPitch-7):adjPitch;        if (order < abs(sigCode)) currAcc = kFlatFlag;    }    if (sigCode > 0) {        // sharps        // adjusted order is: 0/3/-1/2/5/1/4        adjPitch -= firstAccSharp;        adjPitch = (((adjPitch+3)%7)*2);        order = (adjPitch<8)?(6-adjPitch):(13-adjPitch);        if (order < sigCode) currAcc = kSharpFlag;    }    return currAcc;}// ACCESSORS- (int)numberOfAccidentals {    return abs(sigCode);}- (int)sigCode {    return sigCode;}- (void)setSigCode:(int)i {    sigCode = i;    if (isMajorMode(mode)) {		basePitch = (sigCode*7+48)%12;	} else {		basePitch = (sigCode*7+45)%12;	}    basePitchOffsetFromB = [self basePitchOffsetFromMiddleB];}- (void)setBasePitch:(int)b {    // ** THE BASEPITCH IVAR IS A NUMBER FROM 0 TO 11 ** //    // ** WHERE 0 IS MIDDLE C, THEN WORKING UP IN SEMITONES ** //	// ** SIGCODE INDICATES THE NUMBER OF ACCIDENTALS IN THE ** //	// ** KEY SIGNATURE, WHERE POSITIVE IS SHARPS, AND NEGATIVE ** //	// ** IS FLATS (e.g. -3 is 3 flats, so Eb major)		** //	if (numScaleTones == 0) {		// ideally we should always set the mode first before setting the base pitch		// but this is not an ideal world, so this is a sanity check		[self setNumScaleTones:[self calculateNumScaleTones]];	}    basePitch = b;    if (isMajorMode(mode)) {		sigCode = (6+7*b)%12-6;	} else {		sigCode = (3+7*b)%12-6;    }    basePitchOffsetFromB = [self basePitchOffsetFromMiddleB];}- (void)setMode:(int)m {    mode = m;    // refresh the sig code		[self setNumScaleTones:[self calculateNumScaleTones]];    [self setBasePitch:basePitch];}- (int)mode { return mode; }- (int)getDegree:(int)d {	if (d<0) {		return (numScaleTones - (-d % numScaleTones)) % numScaleTones;	} else {		return d%numScaleTones;	}}- (int)getOctave:(int)d {	return floor((float)d/numScaleTones);}/*- (int)convertYCoordToPitch:(float)y                   midStaff:(float)midStaff                       clef:(int)clef                 maxLedgers:(int)maxLedgers{    float offset;    int pitch, maxOffset;        offset = (y-midStaff);    offset /= (kStaffLinesSpacing/2);    offset = floor(offset);    // no more than one ledger line    if (maxLedgers == -1) {        maxOffset = 0;    } else {        maxOffset = 5 + (maxLedgers * 2);    }        if (offset > maxOffset) offset = maxOffset;    if (offset < -maxOffset) offset = -maxOffset;    pitch = offset - [self pitchPositionOnStaff:0 clef:clef];    return pitch;}*/- (int)pitchPositionFromB:(int)pitch {    return basePitchOffsetFromB + [self convertScaleDegreeToStaffOffset:pitch];}/*- (int)pitchPositionOnStaff:(int)pitch clef:(int)clef {    return basePitchOffsetFromB + [self convertScaleDegreeToStaffOffset:pitch] + gClefOffsets[clef];}*/- (int)convertScaleDegreeToStaffOffset:(int)p {	// used for scales that do not have 7 degrees, and have gaps in them	int deg = [self getDegree:p];	int oct = [self getOctave:p];	switch (mode) {		case kOctatonicMode:			if (deg == 0) return (oct*7)+deg;			return (oct*7)+deg-1;			break;		case kWholeToneMode:			return (oct*7)+deg;			break;		case kHexatonicMode:			if (deg>2) return (oct*7)+deg+1;			return p;			break;		default:			return p;			break;	}}- (void)setDisplay:(BOOL)b { display = b; }- (BOOL)display { return display; }- (NSString *)description {    NSArray *noteNames = @[@"C",@"C-sharp",@"D",@"E-flat",@"E",@"F",@"F-sharp",@"G",@"A-flat",@"A",@"B-flat",@"B"];    NSString	*noteStr;    noteStr = [noteNames objectAtIndex:basePitch];    noteStr = [noteStr stringByAppendingString:@" "];    noteStr = [noteStr stringByAppendingString:[self modeDescription]];    return noteStr;}- (NSString *)modeDescription {    return [modeNameArray objectAtIndex:mode];}- (int)pressingScale {	switch (mode) {		case kAcousticMode:		case kMixolydianFlatSixMode:		case kAeolianFlatFiveMode:		case kMelodicMinorAscendingMode:		case kLydianAugmentedMode:			return kAcousticPressingScale;			break;				case kOctatonicMode:			return kOctatonicPressingScale;			break;				case kWholeToneMode:			return kWholeTonePressingScale;			break;				case kHarmonicMajorMode:		case kDorianFlatFiveMode:		case kMelodicMinorAscendingRaisedFourthMode:			return kHarmonicMajorPressingScale;			break;				case kHarmonicMinor2Mode:		case kHarmonicMinorMode:		case kLocrianRaisedSixMode:		case kDorianRaisedFourMode:			return kHarmonicMinorPressingScale;			break;				default:			return kDiatonicPressingScale;			break;	}}- (int)bestChromaticAlterationForDegree:(int)p {        int x = [self getDegree:p];    return bestChromAltForDegreeArray[mode][x];}- (int)desperateChromaticAlterationForDegree:(int)p {	int x = [self getDegree:p];	return desperateChromAltForDegreeArray[mode][x];}- (int)numScaleTones {	return numScaleTones;}- (void)setNumScaleTones:(int)i {	numScaleTones = i;}- (int)calculateNumScaleTones {		int i;	for (i=0;i<kMaxNumScaleTones;i++) {		if (modebits[mode][i] == kNil) {			return i;		}	}	return kMaxNumScaleTones;}- (MNKeySignature *)copyWithZone:(NSZone *)zone {    MNKeySignature *copy;    copy = [[MNKeySignature alloc] initWithBasePitch:basePitch mode:mode];    return copy;}@end