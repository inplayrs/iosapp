//
//  IPAddFriendsViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPAddFriendsViewController.h"
#import "IPFacebookLinkViewController.h"
#import "RestKit.h"
#import "Flurry.h"
#import "Error.h"
#import "TSMessage.h"
#import "FriendProtocols.h"
#import "AddUsers.h"
#import "IPPickUsernamesViewController.h"


@interface IPAddFriendsViewController ()

@end

@implementation IPAddFriendsViewController

@synthesize facebookButton, usernameButton, friendPickerController, facebookLinkViewController, poolID, addFacebookPressed, usernamePickerController;

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
    self.title = @"Add Friends";
    facebookLinkViewController = nil;
    usernamePickerController = nil;
    self.addUsers = [[AddUsers alloc] init];
    addFacebookPressed = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSuccess:)
                                                 name:@"ShowSuccess"
                                               object:nil];
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
    
    UIImage *image = [UIImage imageNamed:@"login-button-normal.png"];
    UIImage *image2 = [UIImage imageNamed:@"login-button-hit.png"];
    UIImage *image3 = [UIImage imageNamed:@"login-button-disabled.png"];
    [self.facebookButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.facebookButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
    [self.facebookButton setBackgroundImage:image3 forState:UIControlStateDisabled];
    self.facebookButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
    [self.usernameButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.usernameButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
    [self.usernameButton setBackgroundImage:image3 forState:UIControlStateDisabled];
    self.usernameButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        self.facebookButton.titleEdgeInsets = titleInsets;
        self.usernameButton.titleEdgeInsets = titleInsets;
    }
    
    // Create a cache descriptor based on the default friend picker data fetch settings
    // FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
    FBCacheDescriptor  *cacheDescriptor = [FBFriendPickerViewController
                                                 cacheDescriptorWithUserID:nil
                                                 fieldsForRequest:[NSSet setWithObjects:@"devices", nil]];
    // Pre-fetch and cache friend data
    [cacheDescriptor prefetchAndCacheForSession:FBSession.activeSession];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (([prefs objectForKey:@"fbID"]) && (FBSession.activeSession.state == FBSessionStateOpen) && addFacebookPressed)
    {
        addFacebookPressed = NO;
        [self addFacebookFriends:self];
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


- (IBAction)addUsernamePressed:(id)sender {
    if (!self.usernamePickerController) {
        self.usernamePickerController = [[IPPickUsernamesViewController alloc] init];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        else
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    }
    self.usernamePickerController.poolID = self.poolID;
    [self.navigationController pushViewController:self.usernamePickerController animated:YES];
}


- (IBAction)addFacebookFriends:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (([prefs objectForKey:@"fbID"]) && (FBSession.activeSession.state == FBSessionStateOpen)) {
        if (friendPickerController == nil) {
            friendPickerController = [[FBFriendPickerViewController alloc] init];
            friendPickerController.title = @"Pick Friends";
            friendPickerController.delegate = self;
            friendPickerController.fieldsForRequest = [NSSet setWithObjects:@"devices", @"installed", nil];
        }
        [friendPickerController loadData];
        [friendPickerController clearSelection];
        [self.addUsers.facebookIDs removeAllObjects];
        [self presentViewController:friendPickerController
                       animated:YES
                     completion:nil];
    } else {
        if (!self.facebookLinkViewController) {
            self.facebookLinkViewController = [[IPFacebookLinkViewController alloc] initWithNibName:@"IPFacebookLinkViewController" bundle:nil];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
            else
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        }
        if (self.facebookLinkViewController) {
            addFacebookPressed = YES;
            [self.navigationController pushViewController:self.facebookLinkViewController animated:YES];
        }
    }

}


- (void)facebookViewControllerDoneWasPressed:(id)sender
{
    FBFriendPickerViewController *fpc = (FBFriendPickerViewController *)sender;
    for (id<FBGraphUserExtraFields> user in fpc.selection) {
        NSLog(@"Friend selected: %@", user.name);
        // BOOL installed = [user objectForKey:@"installed"];
        // [self.addUsers.facebookIDs addObject:user.id];
        [self.addUsers.facebookIDs addObject:[user objectForKey:@"id"]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([self.addUsers.facebookIDs count] > 0) {
    [self sendRequest];
    /*
    self.facebookButton.enabled = NO;
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"pool/addusers?pool_id=%d", self.poolID];
    [objectManager postObject:self.addUsers path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"AddFBFriends",
                                    @"type", @"Success", @"result", nil];
        [Flurry logEvent:@"FRIEND" withParameters:dictionary];
        [TSMessage showNotificationInViewController:self
                                              title:@"Add Successful"
                                           subtitle:@"You have added friends to this pool. Inplayrs users will be added immediately, others will be invited to join."
                                              image:nil
                                               type:TSMessageNotificationTypeSuccess
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:nil
                                         atPosition:TSMessageNotificationPositionTop
                                canBeDismisedByUser:YES];
        self.facebookButton.enabled = YES;
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        self.facebookButton.enabled = YES;
        NSArray *errorMessages = [[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey];
        Error *myerror = [errorMessages objectAtIndex:0];
        if (!myerror.message)
            myerror.message = @"Please try again later!";
        NSString *errorString = [NSString stringWithFormat:@"%d", (int)myerror.code];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"AddFBFriends",
                                    @"type", @"Fail", @"result", errorString, @"error", nil];
        [Flurry logEvent:@"FRIEND" withParameters:dictionary];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Alert" message:myerror.message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
     */
    }
}

- (void)sendRequest {
    // Display the requests dialog
    NSString *facebookIDs = [self.addUsers.facebookIDs objectAtIndex:0];
    if ([self.addUsers.facebookIDs count] > 1) {
        for (int i=1; i < [self.addUsers.facebookIDs count]; i++)
            facebookIDs = [facebookIDs stringByAppendingFormat:@",%@", [self.addUsers.facebookIDs objectAtIndex:i]];
    }
    
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:facebookIDs, @"to", nil];
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:@"You've been invited to join a friend pool on Inplayrs."
     title:nil
     parameters:params
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or sending the request.
             NSLog(@"Error sending request.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled request.");
             } else {
                 // Handle the send request callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"request"]) {
                     // User clicked the Cancel button
                     NSLog(@"User canceled request.");
                 } else {
                     // User clicked the Send button
                     NSString *requestID = [urlParams valueForKey:@"request"];
                     NSLog(@"Request ID: %@", requestID);
                     self.facebookButton.enabled = NO;
                     RKObjectManager *objectManager = [RKObjectManager sharedManager];
                     NSString *path = [NSString stringWithFormat:@"pool/addusers?pool_id=%d", self.poolID];
                     [objectManager postObject:self.addUsers path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                         NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"AddFBFriends",
                                                     @"type", @"Success", @"result", nil];
                         [Flurry logEvent:@"FRIEND" withParameters:dictionary];
                         [TSMessage showNotificationInViewController:self
                                                               title:@"Add Successful"
                                                            subtitle:@"You have added friends to this pool. Inplayrs users will be added immediately, others will be invited to join."
                                                               image:nil
                                                                type:TSMessageNotificationTypeSuccess
                                                            duration:TSMessageNotificationDurationAutomatic
                                                            callback:nil
                                                         buttonTitle:nil
                                                      buttonCallback:nil
                                                          atPosition:TSMessageNotificationPositionTop
                                                 canBeDismisedByUser:YES];
                         self.facebookButton.enabled = YES;
                         [self.navigationController popViewControllerAnimated:YES];
                     } failure:^(RKObjectRequestOperation *operation, NSError *error){
                         self.facebookButton.enabled = YES;
                         NSArray *errorMessages = [[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey];
                         Error *myerror = [errorMessages objectAtIndex:0];
                         if (!myerror.message)
                             myerror.message = @"Please try again later!";
                         NSString *errorString = [NSString stringWithFormat:@"%d", (int)myerror.code];
                         NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"AddFBFriends",
                                                     @"type", @"Fail", @"result", errorString, @"error", nil];
                         [Flurry logEvent:@"FRIEND" withParameters:dictionary];
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Alert" message:myerror.message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert show];
                     }];
                 }
             }
         }
     }];
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (void)facebookViewControllerCancelWasPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id<FBGraphUserExtraFields>)user
{
    NSArray *deviceData = user.devices;
    // Loop through list of devices for the friend
    for (NSDictionary *deviceObject in deviceData) {
        // Check if there is a device match
        if (([@"iOS" isEqualToString:deviceObject[@"os"]]) && ([@"iPhone" isEqualToString:deviceObject[@"hardware"]])) {
            // Friend is an iOS user, include them in the display
            return YES;
        }
    }
    // Friend is not an iOS user, do not include them
    return NO;
}

- (void) showSuccess:(NSNotification *)notification {
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    [TSMessage showNotificationInViewController:self
                                          title:@"Add Successful"
                                       subtitle:@"Your friends have been added to this pool."
                                          image:nil
                                           type:TSMessageNotificationTypeSuccess
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionTop
                            canBeDismisedByUser:YES];
}

@end
