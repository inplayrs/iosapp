//
//  IPMultiLoginViewController.h
//  Inplayrs
//
//  Created by David Beesley on 02/10/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPAppDelegate.h"
#import "IPRegisterViewController.h"
#import "IPMultiLoginViewController.h"


@interface IPMultiLoginViewController () <FBLoginViewDelegate>
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;

@end

@implementation IPMultiLoginViewController

@synthesize loggedInUser = _loggedInUser;


- (void)viewDidLoad {
    [super viewDidLoad];

    // Create Login View so that the app will be granted "status_update" permission.
    FBLoginView *loginview = [[FBLoginView alloc] init];

    loginview.frame = CGRectOffset(loginview.frame, 5, 5);
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        loginview.frame = CGRectOffset(loginview.frame, 5, 25);
    }
    loginview.delegate = self;

    [self.view addSubview:loginview];

    [loginview sizeToFit];
    

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
}


- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    // see https://developers.facebook.com/docs/reference/api/errors/ for general guidance on error handling for Facebook API
    // our policy here is to let the login view handle errors, but to log the results
    NSLog(@"FBLoginView encountered an error=%@", error);
}




@end
