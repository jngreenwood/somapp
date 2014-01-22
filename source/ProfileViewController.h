//
//  ProfileViewController.h
//  nzsom_mockup
//
//  Created by James Greenwood on 22/01/14.
//  Copyright (c) 2014 Fiero Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
@interface ProfileViewController : UIViewController

@property BOOL newMedia;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIButton *gearButton;

@end
