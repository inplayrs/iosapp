//
//  IPLoginViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPLoginViewController.h"
#import "MF_Base64Additions.h"
#import "IPAppDelegate.h"
#import "RestKit.h"
#import "Flurry.h"
#import "Error.h"


@interface IPLoginViewController ()

@end

@implementation IPLoginViewController

@synthesize loginButton, usernameField, passwordField;

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
    self.title = @"Login";

    UIImage *backButtonNormal = [UIImage imageNamed:@"back-button.png"];
    UIImage *backButtonHighlighted = [UIImage imageNamed:@"back-button-hit-state.png"];
    CGRect frameimg = CGRectMake(0, 0, backButtonNormal.size.width, backButtonNormal.size.height);
    UIButton *backButton = [[UIButton alloc] initWithFrame:frameimg];
    [backButton setBackgroundImage:backButtonNormal forState:UIControlStateNormal];
    [backButton setBackgroundImage:backButtonHighlighted forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem =[[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    UIImage *image = [UIImage imageNamed:@"login-button-normal.png"];
    UIImage *image2 = [UIImage imageNamed:@"login-button-hit.png"];
    UIImage *image3 = [UIImage imageNamed:@"grey-button.png"];
    [self.loginButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
    [self.loginButton setBackgroundImage:image3 forState:UIControlStateDisabled];
    self.loginButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        self.loginButton.titleEdgeInsets = titleInsets;
    }
    // keyboardShown = NO;
    // viewMoved = NO;
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
        if (textField.tag == 1)
            textField.text = @"Enter Username";
        else if (textField.tag == 2) {
            textField.text = nil;
            textField.placeholder = @"Enter Password";
        }
    }
    [textField resignFirstResponder];
    activeField = nil;
}


- (IBAction)loginUser:(UIButton *)sender {
    if ([self.usernameField.text isEqualToString:@""]  || [self.usernameField.text isEqualToString:@"Enter Username"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Username" message:@"Please enter a username to login!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (([self.passwordField.text isEqualToString:@""])  || (!self.passwordField.text)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Password" message:@"Please enter a password to login!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self.view endEditing:YES];
    IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.user = self.usernameField.text;
    appDelegate.username = [self.usernameField.text stringByAppendingFormat:@":%@", self.passwordField.text];
    appDelegate.username = [appDelegate.username base64String];
    appDelegate.username = [@"Basic " stringByAppendingString:appDelegate.username];

    [self getGames];

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)dismissKeyboard:(id)sender {
    [activeField resignFirstResponder];
}

- (void)getGames
{
    self.loginButton.enabled = NO;
    IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager.HTTPClient setDefaultHeader:@"Authorization" value:appDelegate.username];
    
    [objectManager getObjectsAtPath:@"competition/list" parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        appDelegate.loggedin = YES;
        appDelegate.refreshLobby = YES;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:appDelegate.username forKey:@"username"];
        [prefs setObject:appDelegate.user forKey:@"user"];
        [Flurry setUserID:appDelegate.user];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"LOGIN",
                                     @"type", @"Success", @"result", nil];
        [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Success" message:@"You are now logged in!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        self.loginButton.enabled = YES;
        self.usernameField.text = @"Enter Username";
        self.passwordField.placeholder = @"Enter Password";
        self.passwordField.text = nil;
        [self.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        self.loginButton.enabled = YES;
        self.passwordField.placeholder = @"Enter Password";
        self.passwordField.text = nil;
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"LOGIN",
                                    @"type", @"Fail", @"result", nil];
        [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
        if (!appDelegate.loggedin)
            [[objectManager HTTPClient] setDefaultHeader:@"Authorization" value:@"Basic Z3Vlc3QxOnB3Ng=="];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login failed" message:@"Please check your username and password and try again!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];

}


@end
