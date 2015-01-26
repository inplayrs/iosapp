//
//  IPNewInfoViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IPSettingsViewController;
@class IPInfoViewController;


@interface IPNewInfoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *rateAppButton;
@property (weak, nonatomic) IBOutlet UIButton *emailFriendsButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;


@property (strong, nonatomic) IPSettingsViewController *settingsViewController;
@property (strong, nonatomic) IPInfoViewController *infoViewController;

- (IBAction)rateApp:(UIButton *)sender;
- (IBAction)emailFriends:(UIButton *)sender;
- (IBAction)launchSettings:(UIButton *)sender;
- (IBAction)launchInfo:(UIButton *)sender;


@end
