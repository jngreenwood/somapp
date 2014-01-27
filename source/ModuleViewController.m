//
//  ModuleViewController.m
//  nzsom_mockup
//
//  Created by James Greenwood on 22/01/14.
//  Copyright (c) 2014 Fiero Interactive. All rights reserved.
//

#import "ModuleViewController.h"
#import "PracticeViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ModuleViewController ()

@end

@implementation ModuleViewController

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
    NSLog(@"hello this doge");
    self.view.backgroundColor = [UIColor colorWithRed:0.431 green:0.847 blue:0.165 alpha:1.0];
    
    UIColor * color = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.4f];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 650, self.view.bounds.size.width, 1)];
    lineView.backgroundColor = color;
    [self.view addSubview:lineView];
    

    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(playButtonClick:)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Practice Full Test" forState:UIControlStateNormal];
    [button setCenter:self.view.center];
    button.frame = CGRectMake(100.0, 680.0, 460.0, 57.0);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    int size = 18;
    button.titleLabel.font = [UIFont systemFontOfSize:size];
    
    CALayer * layer = [button layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:20.0]; //when radius is 0, the border is a rectangle
    [layer setBorderWidth:1.0];
    [layer setBorderColor:[color CGColor]];
    
    [self.view addSubview:button];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)playButtonClick: (id)sender{
    NSLog(@"Much PLay, wow, so intense");
    [self performSegueWithIdentifier:@"segueToFullQuiz" sender:self];
    
}

-(IBAction)moduleClick: (id)sender{
    _selectedQuestion = [sender tag];
    NSLog(@"Button clicked %i", [sender tag]);
    
    [self performSegueWithIdentifier:@"segueToPractice" sender:self];
    NSLog(@"Button clicked %i", [sender tag]);

    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"segue");

    
    PracticeViewController *PVC = [[segue.destinationViewController viewControllers] objectAtIndex: 0];
    
    NSLog(@"Button clicked %i", _selectedQuestion);
    [PVC setQuestionNumber:_selectedQuestion];
    
    
}


@end
