//
//  IPMultiLoginViewController.h
//  Inplayrs
//
//  Created by David Beesley on 02/10/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@class IPRegisterViewController;
@class IPInfoViewController;

@interface IPMultiLoginViewController : UIViewController

@property (strong, nonatomic) IPRegisterViewController *registerViewController;
@property (strong, nonatomic) IPInfoViewController *infoViewController;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
- (IBAction)registerPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *termsLabel;
@property (weak, nonatomic) IBOutlet UIButton *termsButton;
- (IBAction)termsPressed:(id)sender;

@end

