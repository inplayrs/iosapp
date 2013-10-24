//
//  IPLoginFBViewController.h
//  Inplayrs
//
//  Created by David Beesley on 02/10/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>


@class IPLoginFBViewController;  // facebook friend picker
@class IPRegisterViewController;


@interface IPLoginFBViewController : UIViewController


@property (strong, nonatomic) IBOutlet UIButton *buttonLoginLogout;
@property (strong, nonatomic) IBOutlet UITextView *textNoteOrLink;
@property (strong, nonatomic) IPRegisterViewController *EmailRegViewController;  // reg with email button
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;
@property (weak, nonatomic) IBOutlet UILabel *FBNameLable;



- (IBAction)buttonClickHandler:(UIButton *)sender;
- (IBAction)LogInWithEmailButton:(UIButton *)sender;

- (void)updateView;

@end
