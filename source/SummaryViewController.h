//
//  SummaryViewController.h
//  EarConditioner iOS
//
//  Created by Maurizio Frances on 21/01/14.
//  Copyright (c) 2014 Michael Norris. All rights reserved.
//

@protocol SummaryVC <NSObject>

-(void) setToQuestion:(int)Number;
-(void) retryAllWithNewMelody;
-(void) retryAllWithSameMelody;
@end

#import <UIKit/UIKit.h>
#import "QuizViewController.h"


@interface SummaryViewController : UIViewController

@property id <SummaryVC> delegate;
@property UIViewController *QVC;




@property NSMutableArray *scoreSheet;
@property int totalScore;

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
@property (weak, nonatomic) IBOutlet UIImageView *Q3Answer;
@property (weak, nonatomic) IBOutlet UIImageView *Q4Answer;

@property (weak, nonatomic) IBOutlet UILabel *scoreLbl;

-(void) displayScoresLbl;
-(void) displayScores;
-(void) displayRetryButtons;

- (IBAction)clickRetryQuestion:(id)sender;
- (IBAction)clickRetryAll:(id)sender;
- (IBAction)clickNextTest:(id)sender;
- (IBAction)clickQuitTest:(id)sender;


@end
