//
//  IPLoginFBViewController.m
//  Inplayrs
//
//  Created by David Beesley on 02/10/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPLoginFBViewController.h"
#import "IPRegisterViewController.h"
#import "IPAppDelegate.h"
#import "IPInfoViewController.h"


@interface IPLoginFBViewController ()
@end


@implementation IPLoginFBViewController
@synthesize textNoteOrLink, buttonLoginLogout, EmailRegViewController, loggedInUser, FBNameLable;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self updateView];

    IPAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (!appDelegate.session.isOpen) {
        // create a fresh session object
        appDelegate.session = [[FBSession alloc] init];

        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
        if (appDelegate.session.state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                             FBSessionState status,
                                                             NSError *error) {
                // we recurse here, in order to update buttons and labels
                [self updateView];
            }];
        }
    }
}

// main helper method to update the UI to reflect the current state of the session.
- (void)updateView {
    // get the app delegate, so that we can reference the session property
    IPAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (appDelegate.session.isOpen) {
        // valid account UI is shown whenever the session is open
        //[self.buttonLoginLogout setTitle:@"Log out" forState:UIControlStateNormal];
        //[self.textNoteOrLink setText:[NSString stringWithFormat:@"https://graph.facebook.com/me/friends?access_token=%@",
        //                         appDelegate.session.accessTokenData.accessToken]];
        [self.textNoteOrLink setText:@"Login Sucessful"];
        [self.buttonLoginLogout setTitle:@"Log out" forState:UIControlStateNormal];
        
        
        [buttonLoginLogout setImage:Nil forState:UIControlStateNormal];
        
        
        
        
       
        
    } else {
        // login-needed account UI is shown whenever the session is closed
        //[self.buttonLoginLogout setTitle:@"Log in" forState:UIControlStateNormal];
        [self.textNoteOrLink setText:@"Login with FaceBook to play with friends and share your achivements"];
        UIImage *image = [UIImage imageNamed:@"FaceBook_login.png"];
        [buttonLoginLogout setImage:image forState:UIControlStateNormal];

        
    }
}


// handler for button click, logs sessions in or out
- (IBAction)EmailButton:(id)sender {
}

- (IBAction)buttonClickHandler:(id)sender {
    // get the app delegate so that we can access the session property
    IPAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];

    // this button's job is to flip-flop the session from open to closed
    if (appDelegate.session.isOpen) {
        // if a user logs out explicitly, we delete any cached token information, and next
        // time they run the applicaiton they will be presented with log in UX again; most
        // users will simply close the app or switch away, without logging out; this will
        // cause the implicit cached-token login to occur on next launch of the application
        [appDelegate.session closeAndClearTokenInformation];

    } else {
        if (appDelegate.session.state != FBSessionStateCreated) {
            // Create a new, logged out session.
            appDelegate.session = [[FBSession alloc] init];
        }

        // if the session isn't open, let's open it now and present the login UX to the user
        [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                         FBSessionState status,
                                                         NSError *error) {
            // and here we make sure to update our UX according to the new session state
            [self updateView];
        }];
    }
}

#pragma mark Template generated code

- (void)viewDidUnload
{
    self.buttonLoginLogout = nil;
    self.textNoteOrLink = nil;

    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


- (IBAction)LogInWithEmailButton:(id)sender {
    if (!self.EmailRegViewController) {
        self.EmailRegViewController = [[IPRegisterViewController alloc] initWithNibName:@"IPRegisterViewController" bundle:nil];
    }
    if (self.EmailRegViewController)
        [self.navigationController pushViewController:self.EmailRegViewController animated:YES];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    // here we use helper properties of FBGraphUser to dot-through to first_name and
    // id properties of the json response from the server; alternatively we could use
    // NSDictionary methods such as objectForKey to get values from the my json object
    self.FBNameLable.text = [NSString stringWithFormat:@"Hello %@!", user.first_name];
    

    // setting the profileID property of the FBProfilePictureView instance
    // causes the control to fetch and display the profile picture for the user
    //  self.profilePic.profileID = user.id;
    //self.loggedInUser = user;
}



@end
