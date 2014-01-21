//
//  QuizViewController.m
//  EarConditioner iOS
//
//  Created by Maurizio Frances on 21/01/14.
//  Copyright (c) 2014 Michael Norris. All rights reserved.
//

#import "QuizViewController.h"
#import "MNBaseSequence.h"
#import "MNRandomSequenceGenerator.h"
#import "MNKeySignature.h"
#import "MNMusicSequence.h"
#import "MNSequenceNote.h"
#import "MNSequenceBar.h"

extern MNMusicSequence *gQuestionSequence,*gQuestion2Sequence;

@interface QuizViewController ()

@end

@implementation QuizViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    oldMode1 = oldMode2 = oldEnum1 = oldEnum2 = -1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)playRandomMelody:(id)sender {
    int keySigCode, startingDegree;
    NSString *dynamicProfileStr;
    
    
    // ** FIRST SET UP ALL THE RANDOM VARIABLES BASED ON THE TRINITY SPEC ** //
    
    // ** 1. Choose a time signature ** //
    // avoid a run of three of the same time sig
    BOOL tsIsGood = NO;
    while (!tsIsGood) {
        
        if (random()%2) {
            // duple tim
            _timeSigEnum = 2;
        } else {
            // triple time
            _timeSigEnum = 3;
        }
        tsIsGood = (_timeSigEnum != oldEnum1) || (_timeSigEnum != oldEnum2);
    }
    oldEnum2 = oldEnum1;
    oldEnum1 = _timeSigEnum;
    
    // ** 2. Choose major/minor mode ** //
    // avoid a run of three in the same mode
    BOOL modeIsGood = NO;
    while (!modeIsGood) {
        if (random()%2) {
            _mode = kMajorMode;
        } else {
            _mode = kHarmonicMinorMode;
        }
        modeIsGood = (_mode != oldMode1) || (_mode != oldMode2);
    }
    oldMode2 = oldMode1;
    oldMode1 = _mode;
    
    // ** 3. Choose a dynamic profile - there are eight possibilities (see MNBaseSequence.h) ** //
    dynamicProfile = random()%8+1;
    dynamicProfileStr = dynamicProfileStrArray[dynamicProfile];
    
    // ** 4. Choose a key signature up to three flats or sharps - i.e. a number between -3 and +3 ** //
    keySigCode = random()%7-3;
    
    // ** 5. Melody starts on either tonic or fifth, i.e. degree 0, 4 or -3 ** //
    int startingDegreeArray[3] = {0,4,-3};
    startingDegree = startingDegreeArray[random()%3];
    
    // ** NOW PLUG IN THESE VARIABLES INTO THE RANDOM SEQUENCE GENERATOR ** //
    
    questionBaseSequence = [MNRandomSequenceGenerator randomMelodyWithTimeSigEnum:_timeSigEnum
                                                                     timeSigDenom:4
                                                                     numberOfBars:8
                                                                  leapProbability:20
                                                                          maxLeap:2
                                                                   tieProbability:0
                                                                  restProbability:0
                                                                maxNumLedgerLines:0
                                                                             mode:_mode
                                                                       keySigCode:keySigCode
                                                                    chromaticness:0
                                                            minRhythmicDifficulty:2
                                                            maxRhythmicDifficulty:5
                                                                   startingOctave:0
                                                                             clef:kTrebleClef
                                                                            range:8
                                                                   startingDegree:startingDegree
                                                                      rhythmArray:nil];
    
    // ** Find melodic direction of generated melody : -1 = descends, 0 = same, 1 = ascends
    MNSequenceNote *firstNote = [questionBaseSequence firstNote];
    MNSequenceNote *lastNote = [questionBaseSequence lastNote];
    int firstPitch = [firstNote pitch];
    int lastPitch = [lastNote pitch];
    _melodyDirection = (lastPitch!=firstPitch)*(lastPitch<firstPitch?-1:1);
    
    // ** Convert the random melody object to a MIDI sequence for playback ** //
    [questionBaseSequence convertToMusicSequence:gQuestionSequence
                                  dynamicProfile:dynamicProfile];
    
    // ** And play back... ** //
    [gQuestionSequence play];
    
    // ** Spit out information about this random sequence to the UI ** //
    NSMutableString *melodyPitches = [NSMutableString stringWithString:@""];
    for (MNSequenceBar *bar in questionBaseSequence) {
        for (MNSequenceNote *note in bar) {
            [melodyPitches appendString:[NSString stringWithFormat:@"%i ",[note pitch]]];
        }
        [melodyPitches appendString:@"| "];
    }
    [textView setText:[NSString stringWithFormat:@"Melody info:\rTime signature: %@\rMode: %@\rDynamic Profile: %@\rLast note is %@ the first\r%@",_timeSigEnum==2?@"Duple":@"Triple",_mode==kMajorMode?@"Major":@"Minor",dynamicProfileStr,_melodyDirection==0?@"the same as":_melodyDirection==1?@"higher than":@"lower than",melodyPitches]];
    
    // ** Show the beat pattern graphic ** //
    if (_timeSigEnum == 2) {
        [imageView setImage:[UIImage imageNamed:@"beatpatternduple.png"]];
    } else {
        [imageView setImage:[UIImage imageNamed:@"beatpatterntriple.png"]];
        
    }
    
}

- (IBAction)replayMelody:(id)sender {
    if (questionBaseSequence != nil) {
        [gQuestionSequence play];
    }
}

- (IBAction)replayLast4Bars:(id)sender {
    if (questionBaseSequence != nil) {
        MNBaseSequence *lastFourBars = [questionBaseSequence copyWithRange:NSMakeRange(4,4)];
        [lastFourBars convertToMusicSequence:gQuestion2Sequence
                              dynamicProfile:dynamicProfile];
        
        // ** And play back... ** //
        [gQuestion2Sequence play];
    }
}

- (IBAction)replayMelodyWithChange:(id)sender {
    int isPitchChange;
    int barToChangeIndex;
    MNMusicSequence *questionWithChangeMusicSequence;
    
    // ** COPY ONLY THE LAST FOUR BARS ** //
    MNBaseSequence *questionWithChangeBaseSequence = [questionBaseSequence copyWithRange:NSMakeRange(4, 4)];
    // ** This routine makes a random change in either pitch or rhythm to the random melody ** //
    
    // ** First, choose whether to make a rhythm change (0) or a pitch change (1) ** //
    isPitchChange = random()%2;
    
    if (isPitchChange) {
        // let's make the change somewhere between bar 1–3
        barToChangeIndex = random()%3;
        MNSequenceBar *barToChange = [questionWithChangeBaseSequence barAtIndex:barToChangeIndex];
        
        // choose a random note in that bar
        int numNotes = [barToChange countNotes];
        int noteToChangeIndex = random()%numNotes;
        MNSequenceNote *noteToChange = [barToChange noteAtIndex:noteToChangeIndex];
        
        // get the notes around this note
        MNSequenceNote *prevNote = [noteToChange prevNote];
        MNSequenceNote *nextNote = [noteToChange nextNote];
        
        // get all the pitches
        int pitchToChange = [noteToChange pitch];
        int prevNotePitch = [prevNote pitch];
        int nextNotePitch = [nextNote pitch];
        
        // now change the pitch to a different note that's within two scale degrees either side
        // but doesn't create a unison
        BOOL pitchChangeIsGood = NO;
        int newPitch;
        while (!pitchChangeIsGood) {
            int pitchChange = (random()%2+1)*random()%2?-1:1;
            newPitch = pitchToChange + pitchChange;
            pitchChangeIsGood = (newPitch != prevNotePitch) && (newPitch != nextNotePitch);
        }
        
        // we've chosen a new pitch, so let's put it in
        [noteToChange setPitch:newPitch chromaticAlteration:0];
    } else {
        
        // let's make a rhythm change, somewhere between bars 1–3
        // must be a bar with more than one note in it
        int numNotes = 1;
        MNSequenceBar *barToChange;
        while (numNotes == 1) {
            
            barToChangeIndex = random()%3;
            barToChange = [questionWithChangeBaseSequence barAtIndex:barToChangeIndex];
            numNotes = [barToChange countNotes];
            
        }
        
        // get the rhythm array of the current bar
        NSArray *oldRhythmArray = [barToChange rhythmArray];
        
        // now let's choose a different rhythmic pattern with the same number of notes
        BOOL rhythmChangeIsGood = NO;
        NSArray *newRhythmArray;
        int metreType = [[questionWithChangeBaseSequence timeSignature] timeSigEnum] == 2?kDupleMetre:kTripleMetre;
        
        while (!rhythmChangeIsGood) {
            newRhythmArray = [MNRandomSequenceGenerator getRhythmArrayForMetre:metreType grade:random()%4+2];
            
            BOOL arrayIsDifferent = ![oldRhythmArray isEqualToArray:newRhythmArray];
            BOOL arraySameNumNotes = [newRhythmArray count] == [oldRhythmArray count];
            rhythmChangeIsGood = arrayIsDifferent && arraySameNumNotes;
        }
        
        // we now have a new rhythm array, so let's plug it in
        
        // first let's make a copy of the notes so we can refer to the pitches
        NSArray *oldNotes = [NSArray arrayWithArray:[barToChange notes]];
        [barToChange clear];
        
        for (int i=0;i<numNotes;i++) {
            int pitch = [[oldNotes objectAtIndex:i] pitch];
            float duration = [[newRhythmArray objectAtIndex:i] floatValue];
            [barToChange addNoteWithPitch:pitch chromaticAlteration:0 duration:duration];
        }
        
        
    }
    
    // we have a new sequence, so let's play it
    questionWithChangeMusicSequence = [[MNMusicSequence alloc] initWithTempo:kBaseTempo];
    
    [questionWithChangeBaseSequence convertToMusicSequence:questionWithChangeMusicSequence
                                            dynamicProfile:dynamicProfile];
    
    // ** And play back... ** //
    [questionWithChangeMusicSequence play];
    
    [textView setText:[NSString stringWithFormat:@"I changed the %@ in b.%i",isPitchChange?@"pitch":@"rhythm",barToChangeIndex+1]];
    
}
@synthesize textView,imageView,questionBaseSequence, dynamicProfile, oldMode1, oldMode2, oldEnum1, oldEnum2;

-(void) generateRandomMelody {
    
}

-(void) playMelody {
    
}

-(void) displayQuestion {
    
}

-(void) displayButtonGroup {
    
}

-(void) checkAnswerWith:(int)answer {
    
}

-(void) nextQuestion {
    
}

- (IBAction)clickAnswer1:(id)sender {
}

- (IBAction)clickAnswer2:(id)sender {
}

- (IBAction)clickCheckAnswer:(id)sender {
}

- (IBAction)clickSummaryPage:(id)sender {
}
@end
