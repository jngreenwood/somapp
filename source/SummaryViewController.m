//
//  SummaryViewController.m
//  EarConditioner iOS
//
//  Created by Maurizio Frances on 21/01/14.
//  Copyright (c) 2014 Michael Norris. All rights reserved.
//

#import "SummaryViewController.h"

@interface SummaryViewController ()

@end

@implementation SummaryViewController

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
	// Do any additional setup after loading the view.
    _delegate = _QVC;

    
    _totalScore = 0;
    
    [self displayScores];
    [self displayRetryButtons];
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) displayScoresLbl{
    NSString *tempScore = [[NSString alloc] initWithFormat:@"%i out of 4 correct",_totalScore];
    
    [_scoreLbl setText:tempScore];
    
}


//If any answers are incorrect the corresponding Retry is shown.
-(void) displayScores {
    NSString *tempScoreString;
    
    tempScoreString = [NSString stringWithFormat:@" %@ %@",[_Q1Lbl text],[_scoreSheet objectAtIndex:0]];
    [_Q1Lbl setText:tempScoreString];
    
    tempScoreString = [NSString stringWithFormat:@" %@ %@",[_Q2Lbl text],[_scoreSheet objectAtIndex:1]];
    [_Q2Lbl setText:tempScoreString];
    
    tempScoreString = [NSString stringWithFormat:@" %@ %@",[_Q3Part1Lbl text],[_scoreSheet objectAtIndex:2]];
    [_Q3Part1Lbl setText:tempScoreString];
    
    tempScoreString = [NSString stringWithFormat:@" %@ %@",[_Q3Part2Lbl text],[_scoreSheet objectAtIndex:3]];
    [_Q3Part2Lbl setText:tempScoreString];
    
    tempScoreString = [NSString stringWithFormat:@" %@ %@",[_Q4Lbl text],[_scoreSheet objectAtIndex:4]];
    [_Q4Lbl setText:tempScoreString];
    
    //Q1
    if([[_scoreSheet objectAtIndex:0] integerValue]==0)
    {
        [_Q1Answer setImage:[UIImage imageNamed:@"Asset-Summary_IncorrectAnswer.png"]];
    }
    
    else{
        _totalScore++;
    }
    
    //Q2
    if([[_scoreSheet objectAtIndex:1]integerValue]==0)
    {
        [_Q2Answer setImage:[UIImage imageNamed:@"Asset-Summary_IncorrectAnswer.png"]];
    }
    else{
        _totalScore++;
    }
    
    //Q3
    if([[_scoreSheet objectAtIndex:2]integerValue]==0)
    {
        if([[_scoreSheet objectAtIndex:3]integerValue]==0)
        {
            [_Q3Answer setImage:[UIImage imageNamed:@"Asset-Summary_q3-Incorrect.png"]];
        }
        
        else
        {
            [_Q3Answer setImage:[UIImage imageNamed:@"Asset-Summary_q3-HalfCorrect-2.png"]];
        }
        
    }
    
    else
    {
        if([[_scoreSheet objectAtIndex:3]integerValue]==0)
        {
            [_Q3Answer setImage:[UIImage imageNamed:@"Asset-Summary_q3-HalfCorrect-1.png"]];
        }
        
        else
        {
            _totalScore++;
        }
        
    }
    
    //Q4
    if([[_scoreSheet objectAtIndex:4]integerValue]==0)
    {
        [_Q4Answer setImage:[UIImage imageNamed:@"Asset-Summary_IncorrectAnswer.png"]];
        
    }
    
    else{
        _totalScore++;
    }
    
    [self displayScoresLbl];
    
}


-(void) displayRetryButtons {
    
    if([[_scoreSheet objectAtIndex:0] intValue]==0)
    {
        [_Q1RetryBtn setHidden:NO];
    }
    if([[_scoreSheet objectAtIndex:1] intValue]==0)
    {
        [_Q2RetryBtn setHidden:NO];

    }
    if(([[_scoreSheet objectAtIndex:2] intValue]==0)||([[_scoreSheet objectAtIndex:3] intValue]==0))
    {
        [_Q3RetryBtn setHidden:NO];

    }
    if([[_scoreSheet objectAtIndex:4] intValue]==0)
    {
        [_Q4RetryBtn setHidden:NO];

    }
}

- (IBAction)clickRetryQuestion:(id)sender {
    [_delegate setToQuestion:[sender tag]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickRetryAll:(id)sender {
    [_delegate retryAllWithSameMelody];
    [self.navigationController popViewControllerAnimated:YES];

}

- (IBAction)clickNextTest:(id)sender {
    [_delegate retryAllWithNewMelody];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickQuitTest:(id)sender {
    NSLog(@"push back");
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    
}
@end
