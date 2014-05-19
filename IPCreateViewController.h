//
//  IPCreateViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IPAddFriendsViewController;

@interface IPCreateViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate> {
    UITextField *activeField;
}

@property (weak, nonatomic) IBOutlet UITextField *poolName;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (strong, nonatomic) IPAddFriendsViewController *addFriendsViewController;
@property (nonatomic) NSString *submitPoolName;

- (IBAction)createPool:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;


@end
