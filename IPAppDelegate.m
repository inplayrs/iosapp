//
//  IPAppDelegate.m
//

#import <RestKit/RestKit.h>
#import "IPAppDelegate.h"
#import "MFSideMenu.h"
#import "IPLobbyViewController.h"
#import "SideMenuViewController.h"
#import "Flurry.h"
#import "Game.h"
#import "Period.h"
#import "Points.h"
#import "Selection.h"
#import "Fan.h"
#import "Fangroup.h"
#import "Competition.h"
#import "Leaderboard.h"
#import "CompetitionPoints.h"
#import "CompetitionWinners.h"
#import "Account.h"
#import "Error.h"
#import "GCHelper.h"



@implementation IPAppDelegate

@synthesize window = _window;
@synthesize username, user, loggedin, refreshLobby;

- (IPLobbyViewController *)lobbyController {
    return [[IPLobbyViewController alloc] initWithNibName:@"IPLobbyViewController" bundle:nil];
}

- (UINavigationController *)navigationController {
    return [[UINavigationController alloc]
            initWithRootViewController:[self lobbyController]];
}

- (MFSideMenu *)sideMenu {
    SideMenuViewController *sideMenuController = [[SideMenuViewController alloc] init];
    UINavigationController *navigationController = [self navigationController];
    // navigationController.navigationBar.tintColor = [UIColor colorWithRed:249/255.0 green:242/255.0 blue:7/255.0 alpha:1.0];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        // navigationController.navigationBar.barTintColor = [UIColor colorWithRed:234/255.0 green:208/255.0 blue:23/255.0 alpha:1.0];
        [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"nav-bar.png"] forBarMetrics:UIBarMetricsDefault];
        navigationController.navigationBar.translucent = NO;
    } else {
        [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"nav-bar.png"] forBarMetrics:UIBarMetricsDefault];
        [navigationController.navigationBar setTitleVerticalPositionAdjustment:5.0 forBarMetrics:UIBarMetricsDefault];
    }
    navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIColor blackColor], UITextAttributeTextColor,
                                                              [UIFont fontWithName:@"Avalon-Bold" size:18.0], UITextAttributeFont, [NSValue valueWithUIOffset:UIOffsetMake(0.0,0.0)],UITextAttributeTextShadowOffset, nil];
    
    MFSideMenuOptions options = MFSideMenuOptionMenuButtonEnabled|MFSideMenuOptionBackButtonEnabled
                                                                 |MFSideMenuOptionShadowEnabled;
    // MFSideMenuPanMode panMode = MFSideMenuPanModeNavigationBar|MFSideMenuPanModeNavigationController;
    MFSideMenuPanMode panMode = MFSideMenuPanModeNavigationBar;
    
    MFSideMenu *sideMenu = [MFSideMenu menuWithNavigationController:navigationController
                                                 sideMenuController:sideMenuController
                                                           location:MFSideMenuLocationLeft
                                                            options:options
                                                            panMode:panMode];
    
    sideMenuController.sideMenu = sideMenu;
    UIImage *backButtonNormal = [UIImage imageNamed:@"back-button.png"];
    UIImage *backButtonHighlighted = [UIImage imageNamed:@"back-button-hit-state.png"];
    CGRect frameimg = CGRectMake(0, 0, backButtonNormal.size.width, backButtonNormal.size.height);
    UIButton *backButton = [[UIButton alloc] initWithFrame:frameimg];
    [backButton setBackgroundImage:backButtonNormal forState:UIControlStateNormal];
    [backButton setBackgroundImage:backButtonHighlighted forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem =[[UIBarButtonItem alloc] initWithCustomView:backButton];
    navigationController.navigationItem.backBarButtonItem = barButtonItem;
    
    return sideMenu;
}

- (void) setupNavigationControllerApp {
    self.window.rootViewController = [self sideMenu].navigationController;
    [self.window makeKeyAndVisible];
}

/*
- (void) setupTabBarControllerApp {
    NSMutableArray *controllers = [NSMutableArray new];
    [controllers addObject:[self sideMenu].navigationController];
    [controllers addObject:[self sideMenu].navigationController];
    [controllers addObject:[self sideMenu].navigationController];
    [controllers addObject:[self sideMenu].navigationController];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [tabBarController setViewControllers:controllers];
    
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
}
 */


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ///////////////////////
    // GAME CENTER LOGIN //
    ///////////////////////
    [[GCHelper sharedInstance] authenticateLocalUser];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [Flurry startSession:@"8C4BSDMV8CNX5KKZFWMG"];
    [self setupNavigationControllerApp];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
    (UIRemoteNotificationTypeAlert)];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
        self.window.clipsToBounds =YES;
        // self.window.frame =  CGRectMake(0,20,self.window.frame.size.width,self.window.frame.size.height-20);
        // self.window.bounds = CGRectMake(0, 20, self.window.frame.size.width, self.window.frame.size.height);
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *savedUsername = [prefs objectForKey:@"username"];
    NSString *savedUser = [prefs objectForKey:@"user"];
    if ((savedUsername) && (savedUser)) {
        self.username = savedUsername;
        self.user = savedUser;
        self.loggedin = YES;
        [Flurry setUserID:self.user];
    } else {
        self.username = @"Basic Z3Vlc3QxOnB3Ng==";
        self.user = @"";
        self.loggedin = NO;
    }
    if ([prefs objectForKey:@"autoRefresh"] == nil)
        [prefs setBool:YES forKey:@"autoRefresh"];
    if ([prefs objectForKey:@"pushNotification"] == nil)
        [prefs setBool:NO forKey:@"pushNotification"];
    // self.refreshLobby = NO;
    
    //[self setupTabBarControllerApp];
    
    // RKLogConfigureByName("RestKit", RKLogLevelWarning);
    // RKLogConfigureByName("RestKit/Network*", RKLogLevelTrace);
    // RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    RKLogConfigureByName("*", RKLogLevelOff);
    
    //let AFNetworking manage the activity indicator
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // Initialize HTTPClient
    NSURL *baseURL = [NSURL URLWithString:@"https://api.inplayrs.com/"];
    // NSURL *baseURL = [NSURL URLWithString:@"https://api-dev.inplayrs.com/"];
    // NSURL *baseURL = [NSURL URLWithString:@"http://79.125.20.234:8080/com.inplayrs.rest"];
    
    // AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    AFHTTPClient* client = [AFHTTPClient clientWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    [client setDefaultHeader:@"Authorization" value:self.username];
    [client setDefaultHeader:@"Content-Type" value:@"application/json"];
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    
    // Initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // Setup object mappings
    RKObjectMapping *gameMapping = [RKObjectMapping mappingForClass:[Game class]];
    [gameMapping addAttributeMappingsFromDictionary:@{
     @"game_id":        @"gameID",
     @"name":           @"name",
     @"category_id":    @"category",
     @"game_type":      @"type",
     @"start_date":     @"startDate",
     @"state":          @"state",
     @"entered":        @"entered",
     @"banner_position":    @"bannerPosition",
     @"banner_image_url":   @"bannerImageURL"
     }];
    
    RKObjectMapping *periodMapping = [RKObjectMapping mappingForClass:[Period class]];
    [periodMapping addAttributeMappingsFromDictionary:@{
     @"period_id":     @"periodID",
     @"name":          @"name",
     @"elapsed_time":  @"elapsedTime",
     @"start_date":    @"startDate",
     @"state":         @"state",
     @"game_state":    @"gameState",
     @"score":         @"score",
     @"result":        @"result",
     @"points0":       @"points0",
     @"points1":       @"points1",
     @"points2":       @"points2"
     }];
    
    RKObjectMapping *pointsMapping = [RKObjectMapping mappingForClass:[Points class]];
    [pointsMapping addAttributeMappingsFromDictionary:@{
     @"global_pot_size":        @"globalPot",
     @"fangroup_pot_size":      @"fangroupPot",
     @"points":                 @"globalPoints",
     @"global_rank":            @"globalRank",
     @"fangroup_name":          @"fangroupName",
     @"fangroup_rank":          @"fangroupRank",
     @"h2h_user":               @"h2hUser",
     @"h2h_pot_size":           @"h2hPot",
     @"h2h_points":             @"h2hPoints",
     @"user_in_fangroup_rank":  @"userinfangroupRank",
     @"total_winnings":         @"winnings",
     @"global_winnings":        @"globalWinnings",
     @"fangroup_winnings":      @"fangroupWinnings",
     @"h2h_winnings":           @"h2hWinnings",
     @"global_pool_size":       @"globalPoolSize",
     @"num_fangroups_entered":  @"numFangroups",
     @"fangroup_pool_size":     @"fangroupPoolSize",
     @"late_entry":             @"lateEntry"
     }];
    
    RKObjectMapping *competitionPointsMapping = [RKObjectMapping mappingForClass:[CompetitionPoints class]];
    [competitionPointsMapping addAttributeMappingsFromDictionary:@{
     @"global_rank":            @"globalRank",
     @"global_winnings":        @"globalWinnings",
     @"fangroup_name":          @"fangroupName",
     @"fangroup_rank":          @"fangroupRank",
     @"fangroup_winnings":      @"fangroupWinnings",
     @"user_in_fangroup_rank":  @"userinfangroupRank",
     @"global_pool_size":       @"globalPoolSize",
     @"num_fangroups_entered":  @"numFangroups",
     @"fangroup_pool_size":     @"fangroupPoolSize",
     @"total_global_winnings":  @"totalGlobalWinnings",
     @"total_fangroup_winnings":@"totalFangroupWinnings",
     @"total_userinfangroup_winnings":   @"totalUserinfangroupWinnings"
     }];
    
    RKObjectMapping *selectionMapping = [RKObjectMapping mappingForClass:[Selection class]];
    [selectionMapping addAttributeMappingsFromDictionary:@{
     @"period_id":          @"periodID",
     @"selection":          @"selection",
     @"awarded_points":     @"awardedPoints",
     @"potential_points":   @"potentialPoints",
     @"cashed_out":         @"bank"
     }];
    
    [pointsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"periodSelections" toKeyPath:@"periodSelections" withMapping:selectionMapping]];
    
    RKObjectMapping *postSelectionMapping = [RKObjectMapping requestMapping];
    [postSelectionMapping addAttributeMappingsFromDictionary:@{
     @"periodID":     @"period_id",
     @"selection":    @"selection"
     }];
   
    RKObjectMapping *fanMapping = [RKObjectMapping mappingForClass:[Fan class]];
    [fanMapping addAttributeMappingsFromDictionary:@{
     @"competition_name":   @"competitionName",
     @"fangroup_name":      @"fangroupName",
     @"fangroup_id":        @"fangroupID",
     @"category_id":        @"category"
     }];
    
    RKObjectMapping *competitionMapping = [RKObjectMapping mappingForClass:[Competition class]];
    [competitionMapping addAttributeMappingsFromDictionary:@{
     @"comp_id":        @"competitionID",
     @"name":           @"name",
     @"category_id":    @"category",
     @"state":          @"state",
     @"entered":        @"entered",
     @"start_date":     @"startDate"
     }];
    
    RKObjectMapping *fangroupMapping = [RKObjectMapping mappingForClass:[Fangroup class]];
    [fangroupMapping addAttributeMappingsFromDictionary:@{
     @"fangroup_id":   @"fangroupID",
     @"name":          @"name"
     }];
    
    RKObjectMapping *gameLeaderboardMapping = [RKObjectMapping mappingForClass:[Leaderboard class]];
    [gameLeaderboardMapping addAttributeMappingsFromDictionary:@{
     @"rank":               @"rank",
     @"name":               @"name",
     @"points":             @"points",
     @"potential_winnings": @"winnings"
     }];
   
    RKObjectMapping *competitionLeaderboardMapping = [RKObjectMapping mappingForClass:[Leaderboard class]];
    [competitionLeaderboardMapping addAttributeMappingsFromDictionary:@{
     @"rank":           @"rank",
     @"name":           @"name",
     @"games_played":   @"points",
     @"winnings":       @"winnings"
     }];
    
    RKObjectMapping *competitionWinnersMapping = [RKObjectMapping mappingForClass:[CompetitionWinners class]];
    [competitionWinnersMapping addAttributeMappingsFromDictionary:@{
     @"comp_id":        @"competitionID",
     @"competition":    @"name",
     @"category_id":    @"category",
     @"compEndDate":    @"endDate",
     @"winners":        @"winners"
     }];
    
    RKObjectMapping *userAccountMapping = [RKObjectMapping mappingForClass:[Account class]];
    [userAccountMapping addAttributeMappingsFromDictionary:@{
     @"email":          @"email",
     }];
    
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[Error class]];
    [errorMapping addAttributeMappingsFromDictionary:@{
     @"code":       @"code",
     @"message":    @"message"
     }];
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError);
    NSIndexSet *successStatusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    // Register our mappings with the provider using a response descriptor
    RKResponseDescriptor *gameResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:gameMapping method:RKRequestMethodGET pathPattern:@"competition/games" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *periodResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:periodMapping method:RKRequestMethodGET pathPattern:@"game/periods" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *pointsResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:pointsMapping method:RKRequestMethodGET pathPattern:@"game/points" keyPath:nil statusCodes:nil];
    RKRequestDescriptor *postSelectionDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:postSelectionMapping objectClass:[Selection class] rootKeyPath:nil method:RKRequestMethodPOST];
    RKResponseDescriptor *fanResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fanMapping method:RKRequestMethodGET pathPattern:@"user/fangroups" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *competitionResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:competitionMapping method:RKRequestMethodGET pathPattern:@"competition/list" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *fangroupResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fangroupMapping method:RKRequestMethodGET pathPattern:@"competition/fangroups" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *gameLeaderboardResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:gameLeaderboardMapping method:RKRequestMethodGET pathPattern:@"game/leaderboard" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *competitionLeaderboardResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:competitionLeaderboardMapping method:RKRequestMethodGET pathPattern:@"competition/leaderboard" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *competitionPointsResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:competitionPointsMapping method:RKRequestMethodGET pathPattern:@"competition/points" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *competitionWinnersResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:competitionWinnersMapping method:RKRequestMethodGET pathPattern:@"competition/winners" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *userAccountResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userAccountMapping method:RKRequestMethodGET pathPattern:@"user/account" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *errorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodGET pathPattern:nil keyPath:nil statusCodes:statusCodes];
    RKResponseDescriptor *registerDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userAccountMapping method:RKRequestMethodGET pathPattern:@"user/register" keyPath:nil statusCodes:successStatusCodes];
    
    [objectManager setRequestSerializationMIMEType:RKMIMETypeJSON];
    [objectManager addResponseDescriptor:gameResponseDescriptor];
    [objectManager addResponseDescriptor:periodResponseDescriptor];
    [objectManager addResponseDescriptor:pointsResponseDescriptor];
    [objectManager addRequestDescriptor:postSelectionDescriptor];
    [objectManager addResponseDescriptor:fanResponseDescriptor];
    [objectManager addResponseDescriptor:competitionResponseDescriptor];
    [objectManager addResponseDescriptor:fangroupResponseDescriptor];
    [objectManager addResponseDescriptor:gameLeaderboardResponseDescriptor];
    [objectManager addResponseDescriptor:competitionLeaderboardResponseDescriptor];
    [objectManager addResponseDescriptor:competitionPointsResponseDescriptor];
    [objectManager addResponseDescriptor:competitionWinnersResponseDescriptor];
    [objectManager addResponseDescriptor:userAccountResponseDescriptor];
    [objectManager addResponseDescriptor:errorDescriptor];
    [objectManager addResponseDescriptor:registerDescriptor];
    
    // check if push notification setting changed and if so notify server
    if (self.loggedin) {
        if (([prefs boolForKey:@"pushNotification"] == YES) && ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone)) {
            RKObjectManager *objectManager = [RKObjectManager sharedManager];
            NSString *path = [NSString stringWithFormat:@"user/account/update?pushActive=0"];
            [objectManager postObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"PUSH",
                                            @"type", @"Off", @"result", nil];
                [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
                [prefs setBool:NO forKey:@"pushNotification"];
            } failure:nil];
        } else if (([prefs boolForKey:@"pushNotification"] == NO) && ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] != UIRemoteNotificationTypeNone)) {
            RKObjectManager *objectManager = [RKObjectManager sharedManager];
            NSString *path = [NSString stringWithFormat:@"user/account/update?pushActive=1&deviceID=%@", [prefs objectForKey:@"deviceID"]];
            [objectManager postObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"PUSH",
                                            @"type", @"On", @"result", nil];
                [Flurry logEvent:@"ACCOUNT" withParameters:dictionary];
                [prefs setBool:YES forKey:@"pushNotification"];
            } failure:nil];
        }
    }
        
    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSString *newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:newToken forKey:@"deviceID"];
    if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone)
        [prefs setBool:NO forKey:@"pushNotification"];
    else
        [prefs setBool:YES forKey:@"pushNotification"];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    self.refreshLobby = YES;
}


@end
