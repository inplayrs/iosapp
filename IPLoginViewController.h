//
//  IPLoginViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IPLoginViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate> {
    UITextField *activeField;
    // BOOL keyboardShown;
    // BOOL viewMoved;
}

@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;

- (IBAction)loginUser:(UIButton *)sender;
- (IBAction)dismissKeyboard:(id)sender;

- (void)getGames;

@end
