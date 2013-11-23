//
//  IPLoginViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>


@interface IPLoginViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, FBLoginViewDelegate> {
    UITextField *activeField;
    // BOOL keyboardShown;
    // BOOL viewMoved;
}

@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;

- (IBAction)loginUser:(UIButton *)sender;
- (IBAction)dismissKeyboard:(id)sender;

- (void)getGames;

@end
