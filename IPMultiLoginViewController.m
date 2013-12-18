//
//  IPMultiLoginViewController.h
//  Inplayrs
//
//  Created by David Beesley on 02/10/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPAppDelegate.h"
#import "IPRegisterViewController.h"
#import "IPLoginViewController.h"
#import "IPMultiLoginViewController.h"
#import "IPInfoViewController.h"
#import "RestKit.h"
#import "Flurry.h"
#import "TSMessage.h"
#import "Error.h"
#import "Account.h"
#import "MF_Base64Additions.h"


@interface IPMultiLoginViewController () <FBLoginViewDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;

@end

@implementation IPMultiLoginViewController

@synthesize loggedInUser = _loggedInUser;
@synthesize registerViewController, registerButton, termsButton, termsLabel, infoViewController, loginButton, loginViewController, loginLabel, fbID, fbUsername, fbName, fbEmail, loginView;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Sign In";
    
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
    self.registerButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:14.0];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        self.registerButton.titleEdgeInsets = titleInsets;
    }
    self.termsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    self.termsButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    self.loginButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    self.loginLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    
    registerViewController = nil;
    infoViewController = nil;
    loginViewController = nil;
    loginView.readPermissions = @[@"email"];
}

- (void)viewDidUnload {
    self.loggedInUser = nil;
    [super viewDidUnload];
}

#pragma mark - FBLoginViewDelegate

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    // here we use helper properties of FBGraphUser to dot-through to first_name and
    // id properties of the json response from the server; alternatively we could use
    // NSDictionary methods such as objectForKey to get values from the my json object
    //self.labelFirstName.text = [NSString stringWithFormat:@"Hello %@!", user.first_name];
    // setting the profileID property of the FBProfilePictureView instance
    // causes the control to fetch and display the profile picture for the user
    /*
    NSLog(@"FBLoginView first name=%@", user.first_name);
    NSLog(@"FBLoginView last name=%@", user.last_name);
    NSLog(@"FBLoginView id=%@", user.id);
    NSLog(@"FBLoginView name=%@", user.name);
    NSLog(@"FBLoginView username=%@", user.username);
     */
    self.fbID = user.id;
    self.fbUsername = user.username;
    self.fbName = [user.name stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.fbEmail = [user objectForKey:@"email"];
    self.loggedInUser = user;
    
    IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ((!appDelegate.loggedin) && (FBSession.activeSession.state == FBSessionStateOpen)) {
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        NSString *path = [NSString stringWithFormat:@"user/account?fbID=%@", self.fbID];
        [objectManager getObjectsAtPath:path parameters:nil success:
            ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                Account *account = [result firstObject];
                if (account.username) {
                    appDelegate.user = account.username;
                    appDelegate.username = [appDelegate.user stringByAppendingFormat:@":%@", self.fbID];
                    appDelegate.username = [appDelegate.username base64String];
                    appDelegate.username = [@"Basic " stringByAppendingString:appDelegate.username];
                    [self getGames];
                } else {
                    [self registerUser];
                }
            } failure:^(RKObjectRequestOperation *operation, NSError *error){
                [FBSession.activeSession close];
                NSArray *errorMessages = [[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey];
                Error *myerror = [errorMessages objectAtIndex:0];
                if (!myerror.message)
                    myerror.message = @"Please try again or register via email!";
                NSString *errorString = [NSString stringWithFormat:@"%d", (int)myerror.code];
                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"LOGINFB",
                                         @"type", @"Fail", @"result", errorString, @"error", nil];
                [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:myerror.message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }];
    }
}


- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    // see https://developers.facebook.com/docs/reference/api/errors/ for general guidance on error handling for Facebook API
    // our policy here is to let the login view handle errors, but to log the results
    NSString *alertMessage, *alertTitle;
    if (error.fberrorShouldNotifyUser) {
        // If the SDK has a message for the user, surface it. This conveniently
        // handles cases like password change or iOS6 app slider state.
        alertTitle = @"Facebook Error";
        alertMessage = error.fberrorUserMessage;
    } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
        // It is important to handle session closures since they can happen
        // outside of the app. You can inspect the error for more context
        // but this sample generically notifies the user.
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
    } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
        // The user has cancelled a login. You can inspect the error
        // for more context. For this sample, we will simply ignore it.
        NSLog(@"user cancelled login");
    } else {
        // For simplicity, this sample treats other errors blindly.
        alertTitle  = @"Unknown Error";
        alertMessage = @"Error. Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}


- (void)getGames
{
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
         [prefs setObject:self.fbID forKey:@"password"];
         [prefs setObject:self.fbID forKey:@"fbID"];
         [prefs setObject:@"facebook" forKey:@"loginmethod"];
         [Flurry setUserID:appDelegate.user];
         NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"LOGINFB",
                                     @"type", @"Success", @"result", nil];
         [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
         [TSMessage showNotificationInViewController:self
                                               title:@"Login Successful"
                                            subtitle:@"You are now logged in."
                                               image:nil
                                                type:TSMessageNotificationTypeSuccess
                                            duration:TSMessageNotificationDurationAutomatic
                                            callback:nil
                                         buttonTitle:nil
                                      buttonCallback:nil
                                          atPosition:TSMessageNotificationPositionTop
                                 canBeDismisedByUser:YES];
         NSString *path;
         if ([prefs boolForKey:@"pushNotification"] == YES)
             path = [NSString stringWithFormat:@"user/account/update?pushActive=1&deviceID=%@", [prefs objectForKey:@"deviceID"]];
         else
             path = [NSString stringWithFormat:@"user/account/update?pushActive=0"];
         [objectManager postObject:nil path:path parameters:nil success:nil failure:nil];
         [self.navigationController popToRootViewControllerAnimated:YES];
     } failure:^(RKObjectRequestOperation *operation, NSError *error){
         [FBSession.activeSession close];
         NSArray *errorMessages = [[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey];
         Error *myerror = [errorMessages objectAtIndex:0];
         if (!myerror.message)
             myerror.message = @"Please try again or Login via Inplayrs!";
         if (myerror.code == 1)
             myerror.message = @"This facebook ID is already linked, please login via Inplayrs";
         NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"LOGINFB",
                                     @"type", @"Fail", @"result", nil];
         [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
         if (!appDelegate.loggedin)
             [[objectManager HTTPClient] setDefaultHeader:@"Authorization" value:@"Basic Z3Vlc3QxOnB3Ng=="];
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login failed" message:myerror.message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alert show];
     }];
    
}

- (void)registerUser {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSTimeZone *localTime = [NSTimeZone systemTimeZone];
    NSString *timezone = [localTime abbreviation];
    NSString *path = [NSString stringWithFormat:@"user/register?fbID=%@&password=%@&timezone=%@&fbFullName=%@", self.fbID, self.fbID, timezone, self.fbName];
    if (self.fbUsername)
        path = [path stringByAppendingFormat:@"&fbUsername=%@", self.fbUsername];
    if (self.fbEmail)
        path = [path stringByAppendingFormat:@"&fbEmail=%@", self.fbEmail];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs boolForKey:@"pushNotification"] == YES)
        path = [path stringByAppendingFormat:@"&pushActive=1&deviceID=%@", [prefs objectForKey:@"deviceID"]];
    else
        path = [path stringByAppendingString:@"&pushActive=0"];
    
    [objectManager postObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        Account *account = [result firstObject];
        if (account.username) {
            IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.user = account.username;
            appDelegate.username = [account.username stringByAppendingFormat:@":%@", self.fbID];
            appDelegate.username = [appDelegate.username base64String];
            appDelegate.username = [@"Basic " stringByAppendingString:appDelegate.username];
            appDelegate.loggedin = YES;
            appDelegate.refreshLobby = YES;
            [objectManager.HTTPClient setDefaultHeader:@"Authorization" value:appDelegate.username];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:appDelegate.username forKey:@"username"];
            [prefs setObject:appDelegate.user forKey:@"user"];
            [prefs setObject:self.fbID forKey:@"password"];
            [prefs setObject:self.fbID forKey:@"fbID"];
            [prefs setObject:@"facebook" forKey:@"loginmethod"];
            [Flurry setUserID:appDelegate.user];
        
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"REGISTERFB",
                                    @"type", @"Success", @"result", nil];
            [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
            [TSMessage showNotificationInViewController:self
                                              title:@"Congratulations"
                                           subtitle:@"You are now registered for INPLAYRS!"
                                              image:nil
                                               type:TSMessageNotificationTypeSuccess
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:nil
                                         atPosition:TSMessageNotificationPositionTop
                                canBeDismisedByUser:YES];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [FBSession.activeSession close];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"REGISTERFB",
            @"type", @"Fail", @"result", @"No username", @"error", nil];
            [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Please try again or register via email!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        [FBSession.activeSession close];
        NSArray *errorMessages = [[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey];
        Error *myerror = [errorMessages objectAtIndex:0];
        if (!myerror.message)
            myerror.message = @"Please try again or register via email!";
        NSString *errorString = [NSString stringWithFormat:@"%d", (int)myerror.code];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"REGISTERFB",
                                    @"type", @"Fail", @"result", errorString, @"error", nil];
        [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:myerror.message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}


- (void) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)registerPressed:(id)sender {
    if (!self.registerViewController) {
        self.registerViewController = [[IPRegisterViewController alloc] initWithNibName:@"IPRegisterViewController" bundle:nil];
    }
    if (self.registerViewController)
        [self.navigationController pushViewController:self.registerViewController animated:YES];
}


- (IBAction)termsPressed:(id)sender {
    if (!self.infoViewController) {
        self.infoViewController = [[IPInfoViewController alloc] initWithNibName:@"IPInfoViewController" bundle:nil];
    }
    if (self.infoViewController)
        [self.navigationController pushViewController:self.infoViewController animated:YES];
}


- (IBAction)loginPressed:(id)sender {
    if (!self.loginViewController) {
        self.loginViewController = [[IPLoginViewController alloc] initWithNibName:@"IPLoginViewController" bundle:nil];
    }
    if (self.loginViewController)
        [self.navigationController pushViewController:self.loginViewController animated:YES];
}


@end
