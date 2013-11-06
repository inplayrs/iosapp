//
//  GCHelper.m
//  Inplayrs
//
//  Created by David Beesley on 02/10/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//


#import "GCHelper.h"


@implementation GCHelper

@synthesize gameCenterAvailable;

#pragma mark Initialization

static GCHelper *sharedHelper = nil;
+ (GCHelper *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[GCHelper alloc] init];
    }
    return sharedHelper;
}

/*
- (BOOL)isGameCenterAvailable {
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    NSLog(@"GameCenter is available...");
    
    return (gcClass);
}

- (id)init {
    if ((self = [super init])) {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc =
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}

- (void)authenticationChanged {
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
        NSLog(@" Changed Game center avaliabe.");
        userAuthenticated = TRUE;

        
        
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
        NSLog(@" Game center not avaliabe");
        userAuthenticated = FALSE;

        
    }
    
}
 */

#pragma mark User functions

- (void) authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil)
        {
            NSLog (@"user not logged in to GC");
        }
        else if ([GKLocalPlayer localPlayer].isAuthenticated)
        {
            NSLog(@"gamecenter authentication process succeeded");
            //david_ip1 daviddavidD1 test user account
            NSLog(@"User alias: %@",[[GKLocalPlayer localPlayer] alias]);
            NSLog(@"User id: %@",[[GKLocalPlayer localPlayer] playerID]);
        }
        else
        {
            NSLog(@"user not authenicated");
        }
    };
}


- (void)authenticateLocalUser{
    
    if (!gameCenterAvailable) return;
    NSLog(@"Attempting to authenticating local user via gamecenter...");
    if ([GKLocalPlayer localPlayer].isAuthenticated == NO) {
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        [localPlayer setAuthenticateHandler:(^(UIViewController* viewcontroller, NSError *error) {
            if ([GKLocalPlayer localPlayer].isAuthenticated) {
                    // Do this each time the app starts to check the authenticate user
                    // david_ip2 daviddavidD1 david_ip2@gmail.com = test user account

                    NSLog(@"gamecenter authentication process succeeded");
                    //david_ip1 daviddavidD1 test user account
                    NSLog(@"User alias: %@",[[GKLocalPlayer localPlayer]alias]);
                    NSLog(@"User id: %@",[[GKLocalPlayer localPlayer]playerID]);
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    [prefs setObject:@"gamecenter" forKey:@"loginmethod"];
                }
            else if (![GKLocalPlayer localPlayer].isAuthenticated)
                {
                    // GameCenter is not avaliable enable facebook/email login
                    NSLog(@"User is not signed into GameCenter");

                }
        })];
    } else {
        NSLog(@"Game center not avaliabe on this device");
        // GameCenter is not avaliable enable facebook/email login



    }
}

@end
