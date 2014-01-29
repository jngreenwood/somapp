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
    
    NSLog(@"Scores: %@ %@ %@ %@ %@",[_scoreSheet objectAtIndex:0],[_scoreSheet objectAtIndex:1],[_scoreSheet objectAtIndex:2],[_scoreSheet objectAtIndex:3],[_scoreSheet objectAtIndex:4]);
    
    NSLog(@"Attempt: %@ %@ %@ %@ %@",[_attemptSheet objectAtIndex:0],[_attemptSheet objectAtIndex:1],[_attemptSheet objectAtIndex:2],[_attemptSheet objectAtIndex:3],[_attemptSheet objectAtIndex:4]);
    
    
    _totalScore = 0;
    
    [self displayScores];
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) displayScoresLbl{
    [_Q1Score setText:[NSString stringWithFormat:@" %@",[_scoreSheet objectAtIndex:0]]];
    [_Q2Score setText:[NSString stringWithFormat:@" %@",[_scoreSheet objectAtIndex:1]]];
    [_Q3_1Score setText:[NSString stringWithFormat:@" %@",[_scoreSheet objectAtIndex:2]]];
    [_Q3_2Score setText:[NSString stringWithFormat:@" %@",[_scoreSheet objectAtIndex:3]]];
    [_Q4Score setText:[NSString stringWithFormat:@" %@",[_scoreSheet objectAtIndex:4]]];
    
    [_Q1Total setText:[NSString stringWithFormat:@"/ %@",[_attemptSheet objectAtIndex:0]]];
    [_Q2Total setText:[NSString stringWithFormat:@"/ %@",[_attemptSheet objectAtIndex:1]]];
    [_Q3_1Total setText:[NSString stringWithFormat:@"/ %@",[_attemptSheet objectAtIndex:2]]];
    [_Q3_2Total setText:[NSString stringWithFormat:@"/ %@",[_attemptSheet objectAtIndex:3]]];
    [_Q4Total setText:[NSString stringWithFormat:@"/ %@",[_attemptSheet objectAtIndex:4]]];



    
    NSString *tempScore = [[NSString alloc] initWithFormat:@"%i out of %i correct",_totalScore,_totalAttempts];
    [_scoreLbl setText:tempScore];
    
}


//If any answers are incorrect the corresponding Retry is shown.
-(void) displayScores {
    
    float tempPercent;
    
 
    //Q1
        _totalScore = _totalScore + [[_scoreSheet objectAtIndex:0] integerValue];
        _totalAttempts = _totalAttempts + [[_attemptSheet objectAtIndex:0] integerValue];
    
    
    if([[_attemptSheet objectAtIndex:0] integerValue]==0){
        [_Q1Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_AnswerNA.png"]];
    }
    
    else{
        tempPercent = ([[_scoreSheet objectAtIndex:0] floatValue]/[[_attemptSheet objectAtIndex:0] floatValue]);
    
    if(tempPercent>0.9){
        [_Q1Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_Answer100.png"]];
    }
    else if(tempPercent>0.7){
        [_Q1Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_Answer90.png"]];
    }
    else if(tempPercent>0.49){
        [_Q1Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_Answer70.png"]];
    }
    else{
        [_Q1Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_Answer50.png"]];
    }

    }
    
    //Q2
        _totalScore = _totalScore + [[_scoreSheet objectAtIndex:1] integerValue];
        _totalAttempts = _totalAttempts + [[_attemptSheet objectAtIndex:1] integerValue];
    
    if([[_attemptSheet objectAtIndex:1] integerValue]==0){
        [_Q2Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_AnswerNA.png"]];
    }
    
    else{
        tempPercent = ([[_scoreSheet objectAtIndex:0] floatValue]/[[_attemptSheet objectAtIndex:0] floatValue]);
        
    if(tempPercent>0.9){
        [_Q2Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_Answer100.png"]];
    }
    else if(tempPercent>0.7){
        [_Q2Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_Answer90.png"]];
    }
    else if(tempPercent>0.49){
        [_Q2Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_Answer70.png"]];
    }
    else{
        [_Q2Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_Answer50.png"]];
    }
        
    }

    
    //Q3_1
        _totalScore = _totalScore + [[_scoreSheet objectAtIndex:2] integerValue];
        _totalAttempts = _totalAttempts + [[_attemptSheet objectAtIndex:2] integerValue];
    
    if([[_attemptSheet objectAtIndex:2] integerValue]==0){
        [_Q3_1Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_AnswerNA.png"]];
    }
    
    else{
        tempPercent = ([[_scoreSheet objectAtIndex:0] floatValue]/[[_attemptSheet objectAtIndex:0] floatValue]);
        
    if(tempPercent>0.9){
        [_Q3_1Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_Answer100.png"]];
    }
    else if(tempPercent>0.7){
        [_Q3_1Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_Answer90.png"]];
    }
    else if(tempPercent>0.49){
        [_Q3_1Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_Answer70.png"]];
    }
    else{
        [_Q3_1Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_Answer50.png"]];
    }
        
    }

    
    //Q3_2
        _totalScore = _totalScore + [[_scoreSheet objectAtIndex:3] integerValue];
        _totalAttempts = _totalAttempts + [[_attemptSheet objectAtIndex:3] integerValue];
    
    if([[_attemptSheet objectAtIndex:3] integerValue]==0){
        [_Q3_2Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_AnswerNA.png"]];
    }
    
    else{
        tempPercent = ([[_scoreSheet objectAtIndex:0] floatValue]/[[_attemptSheet objectAtIndex:0] floatValue]);
        
    if(tempPercent>0.9){
        [_Q3_2Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_Answer100.png"]];
    }
    else if(tempPercent>0.7){
        [_Q3_2Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_Answer90.png"]];
    }
    else if(tempPercent>0.49){
        [_Q3_2Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_Answer70.png"]];
    }
    else{
        [_Q3_2Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_Answer50.png"]];
    }

    }
    
    //Q4
        _totalScore = _totalScore + [[_scoreSheet objectAtIndex:4] integerValue];
        _totalAttempts = _totalAttempts + [[_attemptSheet objectAtIndex:4] integerValue];
    
    if([[_attemptSheet objectAtIndex:4] integerValue]==0){
        [_Q4Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_AnswerNA.png"]];
    }
    
    else{
        tempPercent = ([[_scoreSheet objectAtIndex:0] floatValue]/[[_attemptSheet objectAtIndex:0] floatValue]);
        
    if(tempPercent>0.9){
        [_Q4Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_Answer100.png"]];
    }
    else if(tempPercent>0.7){
        [_Q4Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_Answer90.png"]];
    }
    else if(tempPercent>0.49){
        [_Q4Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_Answer70.png"]];
    }
    else{
        [_Q4Answer setImage:[UIImage imageNamed:@"Asset-PracticeSummary_Answer50.png"]];
    }
        
    }

    
    
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
