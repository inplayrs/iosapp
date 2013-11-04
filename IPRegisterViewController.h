//
//  IPRegisterViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IPInfoViewController;

@interface IPRegisterViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate> {
    UITextField *activeField;
    // BOOL keyboardShown;
    // BOOL viewMoved;
}


@property (weak, nonatomic) IBOutlet UITextField *registerUsernameField;
@property (weak, nonatomic) IBOutlet UITextField *registerPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *registerEmailField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (strong, nonatomic) IPInfoViewController *infoViewController;

- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)registerUser:(id)sender;

@end
