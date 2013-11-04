//
//  IPMultiLoginViewController.h
//  Inplayrs
//
//  Created by David Beesley on 02/10/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

// #import "IPAppDelegate.h"
#import "IPRegisterViewController.h"
#import "IPMultiLoginViewController.h"
#import "IPInfoViewController.h"


@interface IPMultiLoginViewController () <FBLoginViewDelegate>
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;

@end

@implementation IPMultiLoginViewController

@synthesize loggedInUser = _loggedInUser;
@synthesize registerViewController, registerButton, termsButton, termsLabel, infoViewController;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Register";

    // Create Login View so that the app will be granted "status_update" permission.
    /*
    FBLoginView *loginview = [[FBLoginView alloc] init];

    loginview.frame = CGRectOffset(loginview.frame, 5, 5);
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        loginview.frame = CGRectOffset(loginview.frame, 5, 25);
    }
    loginview.delegate = self;

    [self.view addSubview:loginview];

    [loginview sizeToFit];
     */
    
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
    
    registerViewController = nil;
    infoViewController = nil;

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

    NSLog(@"FBLoginView encountered an error=%@", user.first_name);
    
    self.loggedInUser = user;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"facebook" forKey:@"loginmethod"];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    // see https://developers.facebook.com/docs/reference/api/errors/ for general guidance on error handling for Facebook API
    // our policy here is to let the login view handle errors, but to log the results
    NSLog(@"FBLoginView encountered an error=%@", error);
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
@end
