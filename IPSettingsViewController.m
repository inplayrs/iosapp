//
//  IPSettingsViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPSettingsViewController.h"
#import "MFSideMenu.h"
#import "MF_Base64Additions.h"
#import "IPAppDelegate.h"
#import "RestKit.h"
#import "Flurry.h"
#import "Account.h"
#import "Error.h"
#import "IPPasswordViewController.h"
#import "IPMultiLoginViewController.h"
#import "IPFacebookLinkViewController.h"
#import "TSMessage.h"
#import <FacebookSDK/FacebookSDK.h>


@interface IPSettingsViewController ()

@end

@implementation IPSettingsViewController

@synthesize logoutButton, updateButton, userLabel, emailLabel, autorefreshLabel, autorefreshSwitch, passwordButton, emailText, passwordViewController, multiLoginViewController, facebookLinkViewController, facebookLabel, facebookLink, userText;


- (void) dealloc {
    self.navigationController.sideMenu.menuStateEventBlock = nil;
}

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
    self.title = @"Settings";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"screen-football-b.png"]];
    // this isn't needed on the rootViewController of the navigation controller
    [self.navigationController.sideMenu setupSideMenuBarButtonItem];
    
    UIImage *image = [UIImage imageNamed:@"login-button-normal.png"];
    UIImage *image2 = [UIImage imageNamed:@"login-button-hit.png"];
    UIImage *image3 = [UIImage imageNamed:@"login-button-disabled.png"];
    [self.logoutButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.logoutButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
    [self.logoutButton setBackgroundImage:image3 forState:UIControlStateDisabled];
    self.logoutButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
    [self.updateButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.updateButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
    [self.updateButton setBackgroundImage:image3 forState:UIControlStateDisabled];
    self.updateButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
    [self.passwordButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.passwordButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
    [self.passwordButton setBackgroundImage:image3 forState:UIControlStateDisabled];
    self.passwordButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
    self.facebookLink.titleLabel.textColor = [UIColor blackColor];
    
    self.userLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    self.facebookLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    self.emailLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    self.autorefreshLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        self.logoutButton.titleEdgeInsets = titleInsets;
        self.updateButton.titleEdgeInsets = titleInsets;
        self.passwordButton.titleEdgeInsets = titleInsets;
    }
    
    passwordViewController = nil;
    multiLoginViewController = nil;
    facebookLinkViewController = nil;
}
         
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (appDelegate.loggedin) {
        [self.logoutButton setEnabled:YES];
        [self.logoutButton setTitle:@"LOGOUT" forState:UIControlStateNormal];
        [self.updateButton setEnabled:YES];
        if ([[prefs objectForKey:@"loginmethod"] isEqualToString:@"email"])
            [self.passwordButton setEnabled:YES];
        [self.userText setText:appDelegate.user];
        [self getAccount:appDelegate.user];
        [self.autorefreshSwitch setOn:[prefs boolForKey:@"autoRefresh"]];
        [self.autorefreshSwitch setEnabled:YES];
        [self.emailText setEnabled:YES];
        [self.userText setEnabled:YES];
        if ([prefs objectForKey:@"fbID"]) {
            self.facebookLink.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0];
            [self.facebookLink setTitle:@"Linked" forState:UIControlStateDisabled];
            [self.facebookLink setEnabled:NO];
        } else {
            self.facebookLink.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0];
            [self.facebookLink setTitle:@"Link..." forState:UIControlStateNormal];
            [self.facebookLink setEnabled:YES];
        }
    } else {
        [self.updateButton setEnabled:NO];
        [self.logoutButton setEnabled:YES];
        [self.logoutButton setTitle:@"SIGN IN" forState:UIControlStateNormal];
        [self.passwordButton setEnabled:NO];
        [self.autorefreshSwitch setEnabled:NO];
        [self.emailText setEnabled:NO];
        [self.userText setEnabled:NO];
        self.facebookLink.titleLabel.text = @"";
        self.facebookLink.enabled = NO;
        self.facebookLink.backgroundColor = [UIColor clearColor];
    }
}

- (void)getAccount:(NSString *)username
{
    [self.logoutButton setEnabled:NO];
    [self.updateButton setEnabled:NO];
    [self.passwordButton setEnabled:NO];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"user/account?username=%@", username];
    [objectManager getObjectsAtPath:path parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         Account *account = [result firstObject];
         if (account.email)
             [self.emailText setText:account.email];
         [self.logoutButton setEnabled:YES];
         [self.updateButton setEnabled:YES];
         if ([[prefs objectForKey:@"loginmethod"] isEqualToString:@"email"])
             [self.passwordButton setEnabled:YES];
     } failure:^(RKObjectRequestOperation *operation, NSError *error){
         [self.logoutButton setEnabled:YES];
         [self.updateButton setEnabled:YES];
         if ([[prefs objectForKey:@"loginmethod"] isEqualToString:@"email"])
             [self.passwordButton setEnabled:YES];
     }];
}

- (IBAction)dismissKeyboard:(id)sender {
    [activeField resignFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    activeField = nil;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

- (IBAction)logoutUser:(UIButton *)sender {
    
    if ([self.logoutButton.titleLabel.text isEqualToString:@"LOGOUT"]) {
        IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.username = @"Basic Z3Vlc3QxOnB3Ng==";
        appDelegate.loggedin = NO;
        appDelegate.user = nil;
        appDelegate.refreshLobby = YES;
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        [objectManager.HTTPClient setDefaultHeader:@"Authorization" value:appDelegate.username];
        [self.updateButton setEnabled:NO];
        [self.logoutButton setEnabled:YES];
        [self.logoutButton setTitle:@"SIGN IN" forState:UIControlStateNormal];
        [self.passwordButton setEnabled:NO];
        [self.autorefreshSwitch setEnabled:NO];
        [self.emailText setEnabled:NO];
        [self.userText setEnabled:NO];
        self.userText.text = @"";
        self.emailText.text = @"";
        [self.facebookLink setTitle:@"" forState:UIControlStateDisabled];
        [self.facebookLink setEnabled:NO];
        self.facebookLink.backgroundColor = [UIColor clearColor];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [FBSession.activeSession close];
        [prefs setObject:appDelegate.username forKey:@"username"];
        [prefs setObject:nil forKey:@"user"];
        [prefs setObject:nil forKey:@"password"];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"LOGOUT",
                                @"type", @"Success", @"result", nil];
        [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
        [TSMessage showNotificationInViewController:self
                                              title:@"Logout Successful"
                                           subtitle:@"You are now logged out."
                                              image:nil
                                               type:TSMessageNotificationTypeSuccess
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:nil
                                         atPosition:TSMessageNotificationPositionTop
                                canBeDismisedByUser:YES];
    } else {
        if (!self.multiLoginViewController) {
            self.multiLoginViewController = [[IPMultiLoginViewController alloc] initWithNibName:@"IPMultiLoginViewController" bundle:nil];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
            else
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        }
        if (self.multiLoginViewController)
            [self.navigationController pushViewController:self.multiLoginViewController animated:YES];
    }

}

- (IBAction)updateUser:(UIButton *)sender {
    if ((self.emailText.text) && (![self.emailText.text isEqualToString:@""])) {
        if (![self validateEmail:self.emailText.text]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"Please enter a valid email address!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    if (![self validateUsername:self.userText.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Username" message:@"Please enter a username between 5 and 15 characters composed of letters and numbers only!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [self.view endEditing:YES];
    [self.updateButton setEnabled:NO];
    [self.passwordButton setEnabled:NO];
    [self.logoutButton setEnabled:NO];
    NSTimeZone *localTime = [NSTimeZone systemTimeZone];
    NSString *timezone = [localTime abbreviation];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"user/account/update?timezone=%@", timezone];
    if ((self.emailText.text) && (![self.emailText.text isEqualToString:@""]))
        path = [path stringByAppendingFormat:@"&email=%@", self.emailText.text];
    if (![self.userText.text isEqualToString:appDelegate.user])
        path = [path stringByAppendingFormat:@"&username=%@", self.userText.text];
    [objectManager postObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [prefs setBool:self.autorefreshSwitch.on forKey:@"autoRefresh"];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"SAVE",
                                    @"type", @"Success", @"result", nil];
        [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
        [TSMessage showNotificationInViewController:self
                                              title:@"Save Successful"
                                           subtitle:@"Your settings have been saved."
                                              image:nil
                                               type:TSMessageNotificationTypeSuccess
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:nil
                                         atPosition:TSMessageNotificationPositionTop
                                canBeDismisedByUser:YES];
        
        [self.updateButton setEnabled:YES];
        if ([[prefs objectForKey:@"loginmethod"] isEqualToString:@"email"])
            [self.passwordButton setEnabled:YES];
        [self.logoutButton setEnabled:YES];
        if (![self.userText.text isEqualToString:appDelegate.user]) {
            appDelegate.user = self.userText.text;
            NSString *password = [prefs objectForKey:@"password"];
            appDelegate.username = [self.userText.text stringByAppendingFormat:@":%@", password];
            appDelegate.username = [appDelegate.username base64String];
            appDelegate.username = [@"Basic " stringByAppendingString:appDelegate.username];
            [prefs setObject:appDelegate.username forKey:@"username"];
            [prefs setObject:appDelegate.user forKey:@"user"];
            [objectManager.HTTPClient setDefaultHeader:@"Authorization" value:appDelegate.username];
            [Flurry setUserID:appDelegate.user];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        [self.updateButton setEnabled:YES];
        if ([[prefs objectForKey:@"loginmethod"] isEqualToString:@"email"])
            [self.passwordButton setEnabled:YES];
        [self.logoutButton setEnabled:YES];
        NSArray *errorMessages = [[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey];
        Error *myerror = [errorMessages objectAtIndex:0];
        if (!myerror.message)
            myerror.message = @"Please try again later!";
        NSString *errorString = [NSString stringWithFormat:@"%d", (int)myerror.code];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"SAVE",
                                    @"type", @"Fail", @"result", errorString, @"error", nil];
        [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Failed" message:myerror.message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    
}

- (IBAction)callPassword:(id)sender {
    if (!self.passwordViewController) {
        self.passwordViewController = [[IPPasswordViewController alloc] initWithNibName:@"IPPasswordViewController" bundle:nil];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        else
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    }
    if (self.passwordViewController)
        [self.navigationController pushViewController:self.passwordViewController animated:YES];
}

- (IBAction)linkFacebook:(id)sender {
    if (!self.facebookLinkViewController) {
        self.facebookLinkViewController = [[IPFacebookLinkViewController alloc] initWithNibName:@"IPFacebookLinkViewController" bundle:nil];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        else
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    }
    if (self.facebookLinkViewController)
        [self.navigationController pushViewController:self.facebookLinkViewController animated:YES];
}

- (BOOL) validateUsername: (NSString *) candidate {
    NSString *usernameRegex = @"[A-Z0-9a-z_-]{5,15}";
    NSPredicate *usernameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", usernameRegex];
    
    return [usernameTest evaluateWithObject:candidate];
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]{1,63}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}


@end
