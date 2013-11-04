//
//  GCHelper.m
//  Inplayrs
//
//  Created by David Beesley on 02/10/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "GCHelper.h"
#import "RestKit.h"


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
        NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE;
        
        
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
        

    }
    
}
#pragma mark User functions


- (void)authenticateLocalUser{
    
    if (!gameCenterAvailable) return;
    NSLog(@"Authenticating local user via gamecenter...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        [localPlayer setAuthenticateHandler:(^(UIViewController* viewcontroller, NSError *error) {
            if(localPlayer.isAuthenticated)
            {
                //david_ip1 daviddavidD1 test user account
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                [prefs setObject:@"gamecenter" forKey:@"loginmethod"];
                NSLog(@"User alias: %@",[[GKLocalPlayer localPlayer]alias]);
                NSLog(@"User id: %@",[[GKLocalPlayer localPlayer]playerID]);
            }
            else
            {
                // not logged in
                NSLog(@"NOT LOGGED IN TO GAMECENTER");
            }
            
            
        })];
    } else {
        NSLog(@"Already authenticated for gamecenter");

    }
}

@end
