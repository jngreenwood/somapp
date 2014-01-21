//
//  QuizViewController.h
//  EarConditioner iOS
//
//  Created by Maurizio Frances on 21/01/14.
//  Copyright (c) 2014 Michael Norris. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MNBaseSequence;

@interface QuizViewController : UIViewController

-(IBAction)playRandomMelody:(id)sender;
-(IBAction)replayMelody:(id)sender;
-(IBAction)replayMelodyWithChange:(id)sender;


@property (nonatomic, strong) MNBaseSequence *questionBaseSequence;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property int dynamicProfile,oldMode1,oldMode2,oldEnum1,oldEnum2;

//NEW CODE

@property int timeSigEnum, mode, melodyDirection, questionNumber, answer;
@property NSMutableArray *scoreSheet;

@property (weak, nonatomic) IBOutlet UILabel *questionLbl;
@property (weak, nonatomic) IBOutlet UIImageView *quizProgressImg;

@property (weak, nonatomic) IBOutlet UIView *buttonGroup1;
@property (weak, nonatomic) IBOutlet UIView *buttonGroup2;
@property (weak, nonatomic) IBOutlet UIView *buttonGroup3;
@property (weak, nonatomic) IBOutlet UIView *buttonGroup4;

-(void) generateRandomMelody;
-(void) playMelody;
-(void) displayQuestion;
-(void) displayButtonGroup;
-(void) checkAnswerWith:(int)answer;
-(void) nextQuestion;

- (IBAction)clickAnswer1:(id)sender;
- (IBAction)clickAnswer2:(id)sender;

- (IBAction)clickCheckAnswer:(id)sender;
- (IBAction)clickSummaryPage:(id)sender;


@end
