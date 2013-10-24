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
    NSLog(@"isGameCenterAvailable...");
    
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
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        [localPlayer setAuthenticateHandler:(^(UIViewController* viewcontroller, NSError *error) {
            if(localPlayer.isAuthenticated)
            {
                //david_ip1 daviddavidD1
                NSLog(@"User alias: %@",[[GKLocalPlayer localPlayer]alias]);
                NSLog(@"User id: %@",[[GKLocalPlayer localPlayer]playerID]);
                
                NSLog(@"User id: %@ %@",[[GKLocalPlayer localPlayer]playerID],[[GKLocalPlayer localPlayer]alias]);
                
                NSLog(@"user/register?username=%@&password=%@",[[GKLocalPlayer localPlayer]alias],[[GKLocalPlayer localPlayer]playerID]);
                
                // NSLog(@"user/register?username=%@&password=%@"[[GKLocalPlayer localPlayer]playerID],[[GKLocalPlayer localPlayer]alias]);
                //RKObjectManager *objectManager = [RKObjectManager sharedManager];
                //NSTimeZone *localTime = [NSTimeZone systemTimeZone];
                //NSString *timezone = [localTime abbreviation];
                //NSString *path = [NSString stringWithFormat:@"user/register?username=aaaaaaa&password=aaaaaatimezone=aaaaa"];
                //[objectManager postObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result)];
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
