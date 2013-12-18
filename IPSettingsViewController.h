//
//  IPSettingsViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IPPasswordViewController;
@class IPMultiLoginViewController;
@class IPFacebookLinkViewController;


@interface IPSettingsViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate> {
    UITextField *activeField;
}

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *autorefreshLabel;
@property (weak, nonatomic) IBOutlet UILabel *facebookLabel;
@property (weak, nonatomic) IBOutlet UISwitch *autorefreshSwitch;
@property (weak, nonatomic) IBOutlet UIButton *passwordButton;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *userText;
@property (weak, nonatomic) IBOutlet UIButton *facebookLink;

@property (strong, nonatomic) IPPasswordViewController *passwordViewController;
@property (strong, nonatomic) IPMultiLoginViewController *multiLoginViewController;
@property (strong, nonatomic) IPFacebookLinkViewController *facebookLinkViewController;

- (IBAction)logoutUser:(UIButton *)sender;
- (IBAction)updateUser:(UIButton *)sender;
- (IBAction)callPassword:(id)sender;
- (IBAction)linkFacebook:(id)sender;
- (void)getAccount:(NSString *)username;
- (IBAction)dismissKeyboard:(id)sender;

@end
