//
//  IPFacebookLinkViewController.h
//  Inplayrs
//
//  Created by David Beesley on 02/10/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPFacebookLinkViewController.h"
#import "RestKit.h"
#import "Flurry.h"
#import "TSMessage.h"
#import "Error.h"
#import "IPAppDelegate.h"


@interface IPFacebookLinkViewController () <FBLoginViewDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;

@end

@implementation IPFacebookLinkViewController

@synthesize loggedInUser = _loggedInUser;
@synthesize fbID, fbUsername, fbName, fbEmail, loginLinkView;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Facebook";
    
    /*
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
     */
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    else
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
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
    
    
    // NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
    // if ((appDelegate.loggedin) && (![prefs objectForKey:@"fbID"]) && (FBSession.activeSession.state == FBSessionStateOpen)) {
    if ((appDelegate.loggedin) && (FBSession.activeSession.state == FBSessionStateOpen)) {
        // self.fbID = user.id;
        self.fbID = [user objectForKey:@"id"];
        self.fbUsername = user.username;
        self.fbName = [user.name stringByReplacingOccurrencesOfString:@" " withString:@""];
        self.fbEmail = [user objectForKey:@"email"];
        self.loggedInUser = user;
        [self linkFacebook];
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



- (void)linkFacebook {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"user/account/update?fbID=%@&fbFullName=%@", self.fbID, self.fbName];
    if (self.fbUsername)
        path = [path stringByAppendingFormat:@"&fbUsername=%@", self.fbUsername];
    if (self.fbEmail)
        path = [path stringByAppendingFormat:@"&fbEmail=%@", self.fbEmail];
    [objectManager postObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:self.fbID forKey:@"fbID"];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"LINKFB",
                                    @"type", @"Success", @"result", nil];
        [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
        [TSMessage showNotificationInViewController:self
                                              title:@"Success"
                                           subtitle:@"Your Facebook account is now linked!"
                                              image:nil
                                               type:TSMessageNotificationTypeSuccess
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:nil
                                         atPosition:TSMessageNotificationPositionTop
                                canBeDismisedByUser:YES];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        [FBSession.activeSession close];
        NSArray *errorMessages = [[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey];
        Error *myerror = [errorMessages objectAtIndex:0];
        if (!myerror.message)
            myerror.message = @"Cannot link Facebook at this time, try again later!";
        NSString *errorString = [NSString stringWithFormat:@"%d", (int)myerror.code];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"LINKFB",
                                    @"type", @"Fail", @"result", errorString, @"error", nil];
        [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Failed" message:myerror.message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}
 

- (void) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}




@end
