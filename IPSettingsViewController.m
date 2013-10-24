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
#import "IPLoginViewController.h"


@interface IPSettingsViewController ()

@end

@implementation IPSettingsViewController

@synthesize logoutButton, updateButton, userLabel, userNameLabel, emailLabel, autorefreshLabel, autorefreshSwitch, passwordButton, emailText, passwordViewController, loginViewController;


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
    
    // this isn't needed on the rootViewController of the navigation controller
    [self.navigationController.sideMenu setupSideMenuBarButtonItem];
    
    UIImage *image = [UIImage imageNamed:@"login-button-normal.png"];
    UIImage *image2 = [UIImage imageNamed:@"login-button-hit.png"];
    UIImage *image3 = [UIImage imageNamed:@"grey-button.png"];
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
    
    self.userLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    self.userNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    self.emailLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    self.emailLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    self.autorefreshLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        self.logoutButton.titleEdgeInsets = titleInsets;
        self.updateButton.titleEdgeInsets = titleInsets;
        self.passwordButton.titleEdgeInsets = titleInsets;
    }
    
    passwordViewController = nil;
    loginViewController = nil;
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
        [self.passwordButton setEnabled:YES];
        self.userNameLabel.text = appDelegate.user;
        if ((!self.emailText.text) || ([self.emailText.text isEqualToString:@""]))
            [self getAccount:appDelegate.user];
        [self.autorefreshSwitch setOn:[prefs boolForKey:@"autoRefresh"]];
        [self.autorefreshSwitch setEnabled:YES];
        [self.emailText setEnabled:YES];
    } else {
        [self.updateButton setEnabled:NO];
        [self.logoutButton setEnabled:YES];
        [self.logoutButton setTitle:@"LOGIN" forState:UIControlStateNormal];
        [self.passwordButton setEnabled:NO];
        [self.autorefreshSwitch setEnabled:NO];
        [self.emailText setEnabled:NO];
    }
}

- (void)getAccount:(NSString *)username
{
    [self.logoutButton setEnabled:NO];
    [self.updateButton setEnabled:NO];
    [self.passwordButton setEnabled:NO];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"user/account?username=%@", username];
    [objectManager getObjectsAtPath:path parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         Account *account = [result firstObject];
         self.emailText.text = account.email;
         [self.logoutButton setEnabled:YES];
         [self.updateButton setEnabled:YES];
         [self.passwordButton setEnabled:YES];
     } failure:^(RKObjectRequestOperation *operation, NSError *error){
         [self.logoutButton setEnabled:YES];
         [self.updateButton setEnabled:YES];
         [self.passwordButton setEnabled:YES];
     }];
}

- (IBAction)addFriends:(UIButton *)sender {
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
        [self.logoutButton setTitle:@"LOGIN" forState:UIControlStateNormal];
        [self.passwordButton setEnabled:NO];
        [self.autorefreshSwitch setEnabled:NO];
        [self.emailText setEnabled:NO];
        self.userNameLabel.text = @"";
        self.emailText.text = @"";
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:appDelegate.username forKey:@"username"];
        [prefs setObject:appDelegate.user forKey:@"user"];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"LOGOUT",
                                @"type", @"Success", @"result", nil];
        [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout Success" message:@"You are now logged out!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        if (!self.loginViewController) {
            self.loginViewController = [[IPLoginViewController alloc] initWithNibName:@"IPLoginViewController" bundle:nil];
        }
        if (self.loginViewController)
            [self.navigationController pushViewController:self.loginViewController animated:YES];
    }

}

- (IBAction)updateUser:(UIButton *)sender {
    if (![self validateEmail:self.emailText.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"Please enter a valid email address!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"user/account/update?timezone=%@&email=%@", timezone, self.emailText.text];
    
    [objectManager postObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [prefs setBool:self.autorefreshSwitch.on forKey:@"autoRefresh"];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"SAVE",
                                    @"type", @"Success", @"result", nil];
        [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save Successful" message:@"Your settings have been saved!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        [self.updateButton setEnabled:YES];
        [self.passwordButton setEnabled:YES];
        [self.logoutButton setEnabled:YES];
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        [self.updateButton setEnabled:YES];
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
    }
    if (self.passwordViewController)
        [self.navigationController pushViewController:self.passwordViewController animated:YES];
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]{1,63}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}
@end
