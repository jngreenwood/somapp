//
//  SummaryViewController.h
//  EarConditioner iOS
//
//  Created by Maurizio Frances on 21/01/14.
//  Copyright (c) 2014 Michael Norris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SummaryViewController : UIViewController

@property NSMutableArray *scoreSheet;

@property (weak, nonatomic) IBOutlet UILabel *Q1Lbl;
@property (weak, nonatomic) IBOutlet UILabel *Q2Lbl;
@property (weak, nonatomic) IBOutlet UILabel *Q3Part1Lbl;
@property (weak, nonatomic) IBOutlet UILabel *Q3Part2Lbl;
@property (weak, nonatomic) IBOutlet UILabel *Q4Lbl;

@property (weak, nonatomic) IBOutlet UIButton *Q1RetryBtn;
@property (weak, nonatomic) IBOutlet UIButton *Q2RetryBtn;
@property (weak, nonatomic) IBOutlet UIButton *Q3RetryBtn;
@property (weak, nonatomic) IBOutlet UIButton *Q4RetryBtn;

-(void) displayScores;
-(void) displayRetryButtons;

- (IBAction)clickRetryQuestion:(id)sender;
- (IBAction)clickRetryAll:(id)sender;
- (IBAction)clickNextTest:(id)sender;


@end
