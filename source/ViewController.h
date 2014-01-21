//
//  ViewController.h
//  testing
//
//  Created by Michael Norris on 10/01/14.
//  Copyright (c) 2014 Michael Norris. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MNBaseSequence;

@interface ViewController : UIViewController
-(IBAction)playRandomMelody:(id)sender;
-(IBAction)replayMelody:(id)sender;
-(IBAction)replayMelodyWithChange:(id)sender;
@property (nonatomic, strong) MNBaseSequence *questionBaseSequence;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property int dynamicProfile,oldMode1,oldMode2,oldEnum1,oldEnum2;
@end
