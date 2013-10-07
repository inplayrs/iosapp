//
//  IPPasswordViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPPasswordViewController.h"
#import "MF_Base64Additions.h"
#import "IPAppDelegate.h"
#import "RestKit.h"
#import "Flurry.h"
#import "Error.h"


@interface IPPasswordViewController ()

@end

@implementation IPPasswordViewController

@synthesize oldPassword, updatePassword, updatePassword2, passwordButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Password";
    
    UIImage *backButtonNormal = [UIImage imageNamed:@"back-button.png"];
    UIImage *backButtonHighlighted = [UIImage imageNamed:@"back-button-hit-state.png"];
    CGRect frameimg = CGRectMake(0, 0, backButtonNormal.size.width, backButtonNormal.size.height);
    UIButton *backButton = [[UIButton alloc] initWithFrame:frameimg];
    [backButton setBackgroundImage:backButtonNormal forState:UIControlStateNormal];
    [backButton setBackgroundImage:backButtonHighlighted forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem =[[UIBarButtonItem alloc] initWithCustomView:backButton];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -10;
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, barButtonItem, nil]];
    } else {
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }
    
    UIImage *image = [UIImage imageNamed:@"login-button-normal.png"];
    UIImage *image2 = [UIImage imageNamed:@"login-button-hit.png"];
    UIImage *image3 = [UIImage imageNamed:@"grey-button.png"];
    [self.passwordButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.passwordButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
    [self.passwordButton setBackgroundImage:image3 forState:UIControlStateDisabled];
    self.passwordButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        self.passwordButton.titleEdgeInsets = titleInsets;
    }
}


- (void) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) {
        if (textField.tag == 1) {
            textField.text = nil;
            textField.placeholder = @"Enter Current Password";
        } else if (textField.tag == 2) {
            textField.text = nil;
            textField.placeholder = @"Enter New Password";
        } else if (textField.tag == 3) {
            textField.text = nil;
            textField.placeholder = @"Re-Enter New Password";
        }
    }
    [textField resignFirstResponder];
    activeField = nil;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (BOOL) validatePassword: (NSString *) candidate {
    NSString *passwordRegex = @"[A-Z0-9a-z_-]{5,15}";
    NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordRegex];
    
    return [passwordTest evaluateWithObject:candidate];
}

- (IBAction)changePassword:(id)sender {
    if (([self.oldPassword.text isEqualToString:@""])  || (!self.oldPassword.text)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Current Password" message:@"Please enter your current password!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (([self.updatePassword.text isEqualToString:@""])  || (!self.updatePassword.text)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter New Password" message:@"Please enter your new password!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (([self.updatePassword2.text isEqualToString:@""])  || (!self.updatePassword2.text)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Re-Enter New Password" message:@"Please re-enter your new password!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ((![self validatePassword:updatePassword.text]) || (![self validatePassword:updatePassword2.text])) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Password" message:@"Please enter a password between 5 and 15 characters composed of letters and numbers only!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if ([self.oldPassword.text isEqualToString:self.updatePassword.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Same Password" message:@"Your new password is the same as the current password!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (![self.updatePassword.text isEqualToString:self.updatePassword2.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Do Not Match" message:@"Your new passwords do not match!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self.view endEditing:YES];
    self.passwordButton.enabled = NO;
    RKObjectManager *objectManager = [RKObjectManager sharedManager];

    NSString *path = [NSString stringWithFormat:@"user/account/update?password=%@", self.updatePassword.text];

    [objectManager postObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.username = [appDelegate.user stringByAppendingFormat:@":%@", self.updatePassword.text];
        appDelegate.username = [appDelegate.username base64String];
        appDelegate.username = [@"Basic " stringByAppendingString:appDelegate.username];
        appDelegate.loggedin = YES;
        [objectManager.HTTPClient setDefaultHeader:@"Authorization" value:appDelegate.username];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:appDelegate.username forKey:@"username"];

        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"PASSWORD",
                                    @"type", @"Success", @"result", nil];
        [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your password has been changed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        self.oldPassword.placeholder = @"Enter Current Password";
        self.updatePassword.placeholder = @"Enter New Password";
        self.updatePassword2.placeholder = @"Re-Enter New Password";
        self.oldPassword.text = nil;
        self.updatePassword.text = nil;
        self.updatePassword2.text = nil;
        self.passwordButton.enabled = YES;
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"PASSWORD",
                                    @"type", @"Fail", @"result", nil];
        [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
        NSArray *errorMessages = [[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey];
        Error *myerror = [errorMessages objectAtIndex:0];
        if (!myerror.message)
            myerror.message = @"Please try again later!";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Failed" message:myerror.message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        self.oldPassword.placeholder = @"Enter Current Password";
        self.updatePassword.placeholder = @"Enter New Password";
        self.updatePassword2.placeholder = @"Re-Enter New Password";
        self.oldPassword.text = nil;
        self.updatePassword.text = nil;
        self.updatePassword2.text = nil;
        self.passwordButton.enabled = YES;
    }];
}

- (IBAction)dismissKeyboard:(id)sender {
    [activeField resignFirstResponder];
}
@end
