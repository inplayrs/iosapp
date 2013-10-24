//
//  IPSettingsViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IPPasswordViewController;
@class IPLoginViewController;
@class FPViewController;  // facebook friend picker


@interface IPSettingsViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate> {
    UITextField *activeField;
}

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *autorefreshLabel;
@property (weak, nonatomic) IBOutlet UISwitch *autorefreshSwitch;
@property (weak, nonatomic) IBOutlet UIButton *passwordButton;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (strong, nonatomic) IPPasswordViewController *passwordViewController;
@property (strong, nonatomic) IPLoginViewController *loginViewController;
@property (strong, nonatomic) FPViewController *FaceBookViewController;  // Facebook friend picker

- (IBAction)logoutUser:(UIButton *)sender;
- (IBAction)updateUser:(UIButton *)sender;
- (IBAction)callPassword:(id)sender;
- (void)getAccount:(NSString *)username;
- (IBAction)ConntectToFaceBook:(id)sender; // Facebook friend picker


@end





