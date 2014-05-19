//
//  IPAddFriendsViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@class AddUsers;
@class IPFacebookLinkViewController;
@class IPPickUsernamesViewController;

@interface IPAddFriendsViewController : UIViewController <UIAlertViewDelegate, FBFriendPickerDelegate>


@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *usernameButton;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (strong, nonatomic) IPFacebookLinkViewController *facebookLinkViewController;
@property (strong, nonatomic) IPPickUsernamesViewController *usernamePickerController;
@property (nonatomic) NSInteger poolID;
@property (strong, nonatomic) AddUsers *addUsers;
@property (nonatomic) BOOL addFacebookPressed;

- (IBAction)addUsernamePressed:(id)sender;
- (IBAction)addFacebookFriends:(id)sender;
- (void)showSuccess:(NSNotification *)notification;


@end
