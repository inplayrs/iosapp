//
//  IPRegisterViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPRegisterViewController.h"
#import "MF_Base64Additions.h"
#import "IPAppDelegate.h"
#import "RestKit.h"
#import "Flurry.h"
#import "Error.h"
#import "IPInfoViewController.h"


@interface IPRegisterViewController ()

@end

@implementation IPRegisterViewController

@synthesize registerButton, registerUsernameField, registerPasswordField, registerEmailField, infoViewController;


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
    self.title = @"Register";
    
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
    [self.registerButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.registerButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
    [self.registerButton setBackgroundImage:image3 forState:UIControlStateDisabled];
    self.registerButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        self.registerButton.titleEdgeInsets = titleInsets;
    }
    // NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @1};
    // self.termsUnderlineLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Terms"
    //                                                         attributes:underlineAttribute];
    
    // keyboardShown = NO;
    // viewMoved = NO;
    
    infoViewController = nil;
    
}


- (void) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    if (keyboardShown)
            return;
    
    if ((activeField != self.usernameField) && (activeField != self.passwordField)) {
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        NSTimeInterval duration;
        [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
        CGRect frame = self.view.frame;
        frame.origin.y -= kbSize.height-10;
        frame.size.height += kbSize.height-10;
        [UIView beginAnimations:@"ResizeKeyboard" context:nil];
        [UIView setAnimationDuration:duration];
        self.view.frame = frame;
        [UIView commitAnimations];
        viewMoved = YES;
    }
    keyboardShown = YES;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if (viewMoved) {
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        NSTimeInterval duration;
        [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
        CGRect frame = self.view.frame;
        frame.origin.y += kbSize.height-10;
        frame.size.height -= kbSize.height-10;
        [UIView beginAnimations:@"ResizeKeyboard" context:nil];
        [UIView setAnimationDuration:duration];
        self.view.frame = frame;
        [UIView commitAnimations];
        viewMoved = NO;
    }
    keyboardShown = NO;
}
 */

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (([textField.text isEqualToString:@""]) || ([textField.text isEqualToString:@"Enter Password"])) {
        if (textField.tag == 1) {
            textField.text = @"Enter Username";
        } else if (textField.tag == 2) {
            textField.text = nil;
            textField.placeholder = @"Enter Password";
        } else if (textField.tag == 3) {
            textField.text = @"Enter Email";
        }
    }
    [textField resignFirstResponder];
    activeField = nil;
}


- (IBAction)registerUser:(id)sender {
    if ([self.registerUsernameField.text isEqualToString:@""]  || [self.registerUsernameField.text isEqualToString:@"Enter Username"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Username" message:@"Please enter a username to register!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (([self.registerPasswordField.text isEqualToString:@""])  || (!self.registerPasswordField.text)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Password" message:@"Please enter a password to register!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if ([self.registerEmailField.text isEqualToString:@""]  || [self.registerEmailField.text isEqualToString:@"Enter Email"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Email" message:@"Please enter your email to register!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (!([self.registerEmailField.text isEqualToString:@""]  || [self.registerEmailField.text isEqualToString:@"Enter Email"])) {
        if (![self validateEmail:registerEmailField.text]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"Please enter a valid email address!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    if (![self validateUsername:registerUsernameField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Username" message:@"Please enter a username between 5 and 15 characters composed of letters and numbers only!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (![self validatePassword:registerPasswordField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Password" message:@"Please enter a password between 5 and 15 characters composed of letters and numbers only!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [self.view endEditing:YES];
    self.registerButton.enabled = NO;
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSTimeZone *localTime = [NSTimeZone systemTimeZone];
    NSString *timezone = [localTime abbreviation];
    NSString *path = [NSString stringWithFormat:@"user/register?username=%@&password=%@&timezone=%@", self.registerUsernameField.text, self.registerPasswordField.text, timezone];
    if (!([self.registerEmailField.text isEqualToString:@""]  || [self.registerEmailField.text isEqualToString:@"Enter Email"]))
        path = [path stringByAppendingFormat:@"&email=%@", self.registerEmailField.text];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs boolForKey:@"pushNotification"] == YES)
        path = [path stringByAppendingFormat:@"&pushActive=1&deviceID=%@", [prefs objectForKey:@"deviceID"]];
    else
        path = [path stringByAppendingString:@"&pushActive=0"];
    [objectManager postObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.user = self.registerUsernameField.text;
        appDelegate.username = [self.registerUsernameField.text stringByAppendingFormat:@":%@", self.registerPasswordField.text];
        appDelegate.username = [appDelegate.username base64String];
        appDelegate.username = [@"Basic " stringByAppendingString:appDelegate.username];
        appDelegate.loggedin = YES;
        appDelegate.refreshLobby = YES;
        [objectManager.HTTPClient setDefaultHeader:@"Authorization" value:appDelegate.username];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:appDelegate.username forKey:@"username"];
        [prefs setObject:appDelegate.user forKey:@"user"];
        [prefs setObject:@"email" forKey:@"loginmethod"];
        [Flurry setUserID:appDelegate.user];
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"REGISTER",
                                    @"type", @"Success", @"result", nil];
        [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"You are now registered for INPLAYRS!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        self.registerUsernameField.text = @"Enter Username";
        self.registerPasswordField.placeholder = @"Enter Password";
        self.registerPasswordField.text = nil;
        self.registerEmailField.text = @"Enter Email";
        // [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        NSArray *errorMessages = [[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey];
        Error *myerror = [errorMessages objectAtIndex:0];
        if (!myerror.message)
            myerror.message = @"Please try again later!";
        NSString *errorString = [NSString stringWithFormat:@"%d", (int)myerror.code];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"REGISTER",
                                    @"type", @"Fail", @"result", errorString, @"error", nil];
        [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Failed" message:myerror.message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        self.registerPasswordField.placeholder = @"Enter Password";
        self.registerPasswordField.text = nil;
        self.registerButton.enabled = YES;
    }];
}


- (IBAction)dismissKeyboard:(id)sender {
    [activeField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}
 */

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]{1,63}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

- (BOOL) validateUsername: (NSString *) candidate {
    NSString *usernameRegex = @"[A-Z0-9a-z_-]{5,15}";
    NSPredicate *usernameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", usernameRegex];
    
    return [usernameTest evaluateWithObject:candidate];
}

- (BOOL) validatePassword: (NSString *) candidate {
    NSString *passwordRegex = @"[A-Z0-9a-z_-]{5,15}";
    NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordRegex];
    
    return [passwordTest evaluateWithObject:candidate];
}


@end
