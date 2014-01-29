//
//  SummaryViewController.m
//  EarConditioner iOS
//
//  Created by Maurizio Frances on 21/01/14.
//  Copyright (c) 2014 Michael Norris. All rights reserved.
//

#import "PracticeSummaryViewController.h"

@interface PracticeSummaryViewController ()

@end

@implementation PracticeSummaryViewController

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
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) displayScoresLbl{
    NSString *tempScore = [[NSString alloc] initWithFormat:@"%i out of %i correct",_totalScore,_totalAttempts];
    
    [_scoreLbl setText:tempScore];
    
}


//If any answers are incorrect the corresponding Retry is shown.
-(void) displayScores {
    NSString *tempScoreString;
    
    tempScoreString = [NSString stringWithFormat:@" %@ %@ out of %@",[_Q1Lbl text],[_scoreSheet objectAtIndex:0], [_attemptSheet objectAtIndex:0]];
    [_Q1Lbl setText:tempScoreString];
    
    tempScoreString = [NSString stringWithFormat:@" %@ %@ out of %@",[_Q2Lbl text],[_scoreSheet objectAtIndex:1], [_attemptSheet objectAtIndex:1]];
    [_Q2Lbl setText:tempScoreString];
    
    tempScoreString = [NSString stringWithFormat:@" %@ %@ out of %@",[_Q3Part1Lbl text],[_scoreSheet objectAtIndex:2], [_attemptSheet objectAtIndex:2]];
    [_Q3Part1Lbl setText:tempScoreString];
    
    tempScoreString = [NSString stringWithFormat:@" %@ %@ out of %@",[_Q3Part2Lbl text],[_scoreSheet objectAtIndex:3], [_attemptSheet objectAtIndex:3]];
    [_Q3Part2Lbl setText:tempScoreString];
    
    tempScoreString = [NSString stringWithFormat:@" %@ %@ out of %@",[_Q4Lbl text],[_scoreSheet objectAtIndex:4], [_attemptSheet objectAtIndex:4]];
    [_Q4Lbl setText:tempScoreString];
    
    //Q1
        _totalScore = _totalScore + [[_scoreSheet objectAtIndex:0] integerValue];
        _totalAttempts = _totalAttempts + [[_attemptSheet objectAtIndex:0] integerValue];

    
    //Q2
        _totalScore = _totalScore + [[_scoreSheet objectAtIndex:1] integerValue];
        _totalAttempts = _totalAttempts + [[_attemptSheet objectAtIndex:1] integerValue];

    
    //Q3
        _totalScore = _totalScore + [[_scoreSheet objectAtIndex:2] integerValue];
        _totalScore = _totalScore + [[_scoreSheet objectAtIndex:3] integerValue];
    
    _totalAttempts = _totalAttempts + [[_attemptSheet objectAtIndex:2] integerValue];
    _totalAttempts = _totalAttempts + [[_attemptSheet objectAtIndex:3] integerValue];

    
    //Q4
        _totalScore = _totalScore + [[_scoreSheet objectAtIndex:4] integerValue];
    
    _totalAttempts = _totalAttempts + [[_attemptSheet objectAtIndex:4] integerValue];

    
    
    [self displayScoresLbl];
    
}



- (IBAction)clickRetryQuestion:(id)sender {
    [_delegate setToQuestion:[sender tag]];
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)clickQuitTest:(id)sender {
    NSLog(@"push back");
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    
}
@end
