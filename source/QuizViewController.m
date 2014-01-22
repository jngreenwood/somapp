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
#import "SummaryViewController.h"


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
    _questionNumber = 1;
    _answer1 = 99;
    _answer2 = 99;
    
    _scoreSheet = [[NSMutableArray alloc] initWithObjects:@-1,@-1,@-1,@-1,@-1, nil];
    
    
    [self generateRandomMelody];
    [self displayQuestion];
    [self displayButtonGroup];
    [self playMelody];

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
    int barToChangeIndex;
    MNMusicSequence *questionWithChangeMusicSequence;
    
    // ** COPY ONLY THE LAST FOUR BARS ** //
    MNBaseSequence *questionWithChangeBaseSequence = [questionBaseSequence copyWithRange:NSMakeRange(4, 4)];
    // ** This routine makes a random change in either pitch or rhythm to the random melody ** //
    
    // ** First, choose whether to make a rhythm change (0) or a pitch change (1) ** //
    _isPitchChange = random()%2;
    
    if (_isPitchChange) {
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
    
    [textView setText:[NSString stringWithFormat:@"I changed the %@ in b.%i",_isPitchChange?@"pitch":@"rhythm",barToChangeIndex+1]];
    
}


-(void) generateRandomMelody {
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
}

-(void) playMelody {
    if (questionBaseSequence != nil) {
        [gQuestionSequence play];
    }}

-(void) displayQuestion {
    switch (_questionNumber) {
        case 1:
            [_questionLbl setText:@"A melody is played twice with the pulse indicated before the second playing. You are to beat time during the second playing."];
            
            
            [_checkAnswerBtn setEnabled:NO];
            
            
            break;
            
        case 2:
            [_questionLbl setText:@"After this playing you are to describe the last note as higher, lower, or the same as the fist note."];

            
            [_checkAnswerBtn setEnabled:NO];
            
            break;
            
        case 3:
            [_questionLbl setText:@"After this playing you are to describe the melody as Major or Minor, and describe the dynamics"];

            
            [_checkAnswerBtn setEnabled:NO];
            
            
            break;
            
        case 4:
            [_questionLbl setText:@"Half of the melody will be played again, and then repeated with one change to either the pitch or the rhythm. You are to describe the change as Pitch or Rhythm."];
            
            [_checkAnswerBtn setEnabled:NO];

            break;
            
        default:
            break;
    }
//    NSString *title = [NSString stringWithFormat:@"Question %i",_questionNumber];
//    self.title = title;
    
}

-(void) displayButtonGroup {
    [_buttonGroup1 setHidden:YES];
    [_buttonGroup2 setHidden:YES];
    [_buttonGroup3 setHidden:YES];
    [_buttonGroup4 setHidden:YES];
    
    switch (_questionNumber) {
        case 1:
            [_buttonGroup1 setHidden:NO];
            break;
            
        case 2:
            [_buttonGroup2 setHidden:NO];
            break;
            
        case 3:
            [_buttonGroup3 setHidden:NO];
            break;
            
        case 4:
            [_buttonGroup4 setHidden:NO];
            break;
    }
    
}

-(void) checkAnswerWith:(int)answer1 And:(int)answer2{

    int tempScore;
    
    //Which question is being asked.
    switch (_questionNumber) {
        case 1:
            //If the answer was correct
            if(answer1==_timeSigEnum)
            {
                tempScore = 1;
            }
            
            //If it was incorrect
            else
            {
                tempScore = 0;
            }

            [_scoreSheet replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:tempScore]];
            
            break;
            
        case 2:
            
            //If the answer was correct
            if(answer1==_melodyDirection)
            {
                tempScore = 1;
            }
            
            //If it was incorrect
            else
            {
                tempScore = 0;
            }
            
            [_scoreSheet replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:tempScore]];
            
            break;
            
        case 3:
            
            //QUESTION 3 PART 1
            if(answer1==_mode)
            {
                tempScore = 1;
            }
            
            //If it was incorrect
            else
            {
                tempScore = 0;
            }
            [_scoreSheet replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:tempScore]];
            
            //QUESTION 3 PART 2

            if(answer2==dynamicProfile)
            {
                //       [_answerTextView setText:@"CORRECT!"];
                tempScore = 1;
                
            }
            
            //If it was incorrect
            else
            {
                tempScore = 0;
                
            }
            [_scoreSheet replaceObjectAtIndex:3 withObject:[NSNumber numberWithInt:tempScore]];
            
            
            break;
            
        case 4:
            
            if(answer1==_isPitchChange)
            {
                tempScore = 1;
            }
            
            //If it was incorrect
            else
            {
                tempScore = 0;
            }
            [_scoreSheet replaceObjectAtIndex:4 withObject:[NSNumber numberWithInt:tempScore]];
            
            break;
            
        default:
            break;
    }
    
    [self nextQuestion];
}

-(void) nextQuestion {
    _questionNumber++;
    
    _answer1=99;
    _answer2=99;
    
    [self displayQuestion];
    [self displayButtonGroup];
}

-(void) deselectAllButtons{
    switch (_questionNumber) {
        case 1:
            for(UIButton *b in [self.buttonGroup1 subviews]) {
                [b setSelected:NO];
            }            break;
            
        case 2:
            for(UIButton *b in [self.buttonGroup2 subviews]) {
                [b setSelected:NO];
            }            break;
            
        case 3:
            for(UIButton *b in [self.buttonGroup3_part1 subviews]) {
                [b setSelected:NO];
            }            break;
            
        case 4:
            for(UIButton *b in [self.buttonGroup4 subviews]) {
                [b setSelected:NO];
            }            break;
    }
    
}


-(void) showSelectedButton:(id)sender
{
    [self deselectAllButtons];
    
    [sender setSelected:YES];
}

- (IBAction)clickAnswer1:(id)sender {
    [self showSelectedButton:sender];
    
    _answer1 = [sender tag];

    if(_questionNumber==4){
        [_checkAnswerBtn setHidden:YES];
        [_summaryBtn setHidden:NO];

    }
    
    //Question3 requires both answers to be entered
    else if(_questionNumber==3){
        if(_answer1!=99 && _answer2!=99){
            [_checkAnswerBtn setEnabled:YES];
        }
    }
    
    else{
        if(_answer1!=99){
            [_checkAnswerBtn setEnabled:YES];
        }
    }

}

- (IBAction)clickAnswer2:(id)sender {
    for(UIButton *b in [self.buttonGroup3_part2 subviews]) {
        [b setSelected:NO];
    }
    
    [sender setSelected:YES];
    _answer2 = [sender tag];
    
    if(_answer1!=99 && _answer2!=99){
        [_checkAnswerBtn setEnabled:YES];
    }

}

- (IBAction)clickCheckAnswer:(id)sender {
    [self checkAnswerWith:_answer1 And:_answer2];
}

- (IBAction)clickSummaryPage:(id)sender {
    [self checkAnswerWith:_answer1 And:_answer2];
    
    NSLog(@"summmmm");
    NSLog(@" %@ %@ %@ %@ %@ ", [_scoreSheet objectAtIndex:0],[_scoreSheet objectAtIndex:1], [_scoreSheet objectAtIndex:2],[_scoreSheet objectAtIndex:3],[_scoreSheet objectAtIndex:4]);

}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    SummaryViewController *SCV = [segue destinationViewController];
    
    
    
    [SCV setScoreSheet:_scoreSheet];
    //[SCV setQVC:self];
    
    NSLog(@" Length of Quiz array %i", [_scoreSheet count]);
    
}

@synthesize textView,imageView,questionBaseSequence, dynamicProfile, oldMode1, oldMode2, oldEnum1, oldEnum2;
@end
