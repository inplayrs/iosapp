//
//  IPPasswordViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IPPasswordViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate> {
    UITextField *activeField;
}


@property (weak, nonatomic) IBOutlet UITextField *oldPassword;
@property (weak, nonatomic) IBOutlet UITextField *updatePassword;
@property (weak, nonatomic) IBOutlet UITextField *updatePassword2;
@property (weak, nonatomic) IBOutlet UIButton *passwordButton;

- (IBAction)changePassword:(id)sender;


@end
