//
//  SummaryViewController.h
//  EarConditioner iOS
//
//  Created by Maurizio Frances on 21/01/14.
//  Copyright (c) 2014 Michael Norris. All rights reserved.
//

@protocol PracticeSummaryVC <NSObject>

-(void) setToQuestion:(int)Number;
-(void) retryAllWithNewMelody;
-(void) retryAllWithSameMelody;
@end

#import <UIKit/UIKit.h>
#import "PracticeViewController.h"


@interface PracticeSummaryViewController : UIViewController

@property id <PracticeSummaryVC> delegate;
@property UIViewController *QVC;




@property NSMutableArray *scoreSheet;
@property NSMutableArray *attemptSheet;

@property int totalScore, totalAttempts;

@property (weak, nonatomic) IBOutlet UILabel *Q1Lbl;
@property (weak, nonatomic) IBOutlet UILabel *Q2Lbl;
@property (weak, nonatomic) IBOutlet UILabel *Q3Part1Lbl;
@property (weak, nonatomic) IBOutlet UILabel *Q3Part2Lbl;
@property (weak, nonatomic) IBOutlet UILabel *Q4Lbl;

@property (weak, nonatomic) IBOutlet UIButton *Q1RetryBtn;
@property (weak, nonatomic) IBOutlet UIButton *Q2RetryBtn;
@property (weak, nonatomic) IBOutlet UIButton *Q3RetryBtn;
@property (weak, nonatomic) IBOutlet UIButton *Q4RetryBtn;

@property (weak, nonatomic) IBOutlet UIImageView *Q1Answer;
@property (weak, nonatomic) IBOutlet UIImageView *Q2Answer;
@property (weak, nonatomic) IBOutlet UIImageView *Q3_1Answer;
@property (weak, nonatomic) IBOutlet UIImageView *Q3_2Answer;
@property (weak, nonatomic) IBOutlet UIImageView *Q4Answer;

@property (weak, nonatomic) IBOutlet UILabel *Q1Score;
@property (weak, nonatomic) IBOutlet UILabel *Q2Score;
@property (weak, nonatomic) IBOutlet UILabel *Q3_1Score;
@property (weak, nonatomic) IBOutlet UILabel *Q3_2Score;
@property (weak, nonatomic) IBOutlet UILabel *Q4Score;

@property (weak, nonatomic) IBOutlet UILabel *Q1Total;
@property (weak, nonatomic) IBOutlet UILabel *Q2Total;
@property (weak, nonatomic) IBOutlet UILabel *Q3_1Total;
@property (weak, nonatomic) IBOutlet UILabel *Q3_2Total;
@property (weak, nonatomic) IBOutlet UILabel *Q4Total;



@property (weak, nonatomic) IBOutlet UILabel *scoreLbl;

-(void) displayScoresLbl;
-(void) displayScores;

- (IBAction)clickRetryQuestion:(id)sender;
- (IBAction)clickQuitTest:(id)sender;


@end
