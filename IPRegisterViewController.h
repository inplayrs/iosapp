//
//  IPRegisterViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IPLoginViewController;
@class IPInfoViewController;

@interface IPRegisterViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate> {
    UITextField *activeField;
    // BOOL keyboardShown;
    // BOOL viewMoved;
}


@property (weak, nonatomic) IBOutlet UILabel *termsLabel;
@property (weak, nonatomic) IBOutlet UILabel *termsUnderlineLabel;
@property (weak, nonatomic) IBOutlet UITextField *registerUsernameField;
@property (weak, nonatomic) IBOutlet UITextField *registerPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *registerEmailField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *termsButton;
@property (strong, nonatomic) IPLoginViewController *loginViewController;
@property (strong, nonatomic) IPInfoViewController *infoViewController;

- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)termsPressed:(id)sender;
- (IBAction)registerUser:(id)sender;

@end
