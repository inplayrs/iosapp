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
#import "PoolPoints.h"
#import "CompetitionWinners.h"
#import "GameWinners.h"
#import "OverallWinners.h"
#import "FriendPool.h"
#import "PoolMember.h"
#import "Account.h"
#import "Stats.h"
#import "Error.h"
#import "AddUsers.h"
#import "Motd.h"
#import "PeriodOptions.h"
#import <FacebookSDK/FacebookSDK.h>



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
        [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"header-bar.png"] forBarMetrics:UIBarMetricsDefault];
        navigationController.navigationBar.translucent = NO;
        navigationController.navigationBar.barStyle = UIBarStyleDefault;
    } else {
        [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"header-bar-small.png"] forBarMetrics:UIBarMetricsDefault];
        [navigationController.navigationBar setTitleVerticalPositionAdjustment:5.0 forBarMetrics:UIBarMetricsDefault];
    }
    navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIColor blackColor], UITextAttributeTextColor,
                                                              [UIFont fontWithName:@"Avalon-Bold" size:18.0], UITextAttributeFont, [NSValue valueWithUIOffset:UIOffsetMake(0.0,0.0)],UITextAttributeTextShadowOffset, nil];
    navigationController.navigationBar.tintColor = [UIColor blackColor];
    
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
    navigationController.navigationItem.backBarButtonItem = barButtonItem;
     */
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    else
        navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    
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

    // [[GCHelper sharedInstance] authenticateLocalPlayer];
    // [[GCHelper sharedInstance] authenticateLocalUser];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [Flurry startSession:@"8C4BSDMV8CNX5KKZFWMG"];
    [self setupNavigationControllerApp];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
    (UIRemoteNotificationTypeAlert)];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        // [application setStatusBarStyle:UIStatusBarStyleDefault];
        self.window.clipsToBounds =YES;
        [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
        // [[UIToolbar appearance] setBarTintColor:[UIColor whiteColor]];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    } else {
        [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
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
     @"banner_image_url":   @"bannerImageURL",
     @"comp_id":        @"competitionID",
     @"inplay_type":    @"inplayType"
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
     @"h2h_fbID":               @"h2hFBID",
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
    
    RKObjectMapping *poolPointsMapping = [RKObjectMapping mappingForClass:[PoolPoints class]];
    [poolPointsMapping addAttributeMappingsFromDictionary:@{
     @"pool_rank":              @"poolRank",
     @"points":                 @"points",
     @"pool_size":              @"poolSize",
     @"pool_pot_size":          @"poolPotSize",
     @"pool_winnings":          @"poolWinnings",
     @"total_pool_winnings":    @"totalPoolWinnings"
     }];
    
    RKObjectMapping *selectionMapping = [RKObjectMapping mappingForClass:[Selection class]];
    [selectionMapping addAttributeMappingsFromDictionary:@{
     @"period_id":          @"periodID",
     @"selection":          @"selection",
     @"period_option_id":   @"periodOptionID",
     @"awarded_points":     @"awardedPoints",
     @"potential_points":   @"potentialPoints",
     @"cashed_out":         @"bank"
     }];
    
    [pointsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"periodSelections" toKeyPath:@"periodSelections" withMapping:selectionMapping]];
    
    RKObjectMapping *periodOptionsMapping = [RKObjectMapping mappingForClass:[PeriodOptions class]];
    [periodOptionsMapping addAttributeMappingsFromDictionary:@{
     @"po_id":      @"periodOptionID",
     @"name":       @"name",
     @"points":     @"points",
     @"result":     @"result"
     }];
    
    [periodMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"periodOptions" toKeyPath:@"periodOptions" withMapping:periodOptionsMapping]];
    
    RKObjectMapping *postSelectionMapping = [RKObjectMapping requestMapping];
    [postSelectionMapping addAttributeMappingsFromDictionary:@{
     @"periodID":       @"period_id",
     @"selection":      @"selection",
     @"periodOptionID": @"period_option_id"
     }];
    
    RKObjectMapping *postAddUsersMapping = [RKObjectMapping requestMapping];
    [postAddUsersMapping addAttributeMappingsFromDictionary:@{
     @"facebookIDs":    @"facebookIDs",
     @"usernames":      @"usernames"
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
    
    RKObjectMapping *gameWinnersMapping = [RKObjectMapping mappingForClass:[GameWinners class]];
    [gameWinnersMapping addAttributeMappingsFromDictionary:@{
     @"game_id":        @"gameID",
     @"game":           @"name",
     @"category_id":    @"category",
     @"gameEndDate":    @"endDate",
     @"comp_id":        @"competitionID",
     @"inplay_type":    @"inplayType",
     @"game_type":      @"type",
     @"state":          @"state",
     @"winners":        @"winners"
     }];
    
    RKObjectMapping *overallWinnersMapping = [RKObjectMapping mappingForClass:[OverallWinners class]];
    [overallWinnersMapping addAttributeMappingsFromDictionary:@{
     @"rank":           @"rank",
     @"username":       @"username",
     @"winnings":       @"winnings",
     @"fbID":           @"fbID"
     }];
    
    RKObjectMapping *friendPoolMapping = [RKObjectMapping mappingForClass:[FriendPool class]];
    [friendPoolMapping addAttributeMappingsFromDictionary:@{
     @"pool_id":        @"poolID",
     @"name":           @"name",
     @"num_players":    @"numPlayers"
     }];
    
    RKObjectMapping *poolMemberMapping = [RKObjectMapping mappingForClass:[PoolMember class]];
    [poolMemberMapping addAttributeMappingsFromDictionary:@{
     @"rank":           @"rank",
     @"username":       @"username",
     @"winnings":       @"winnings",
     @"facebook_id":    @"facebookID"
     }];
    
    RKObjectMapping *userAccountMapping = [RKObjectMapping mappingForClass:[Account class]];
    [userAccountMapping addAttributeMappingsFromDictionary:@{
     @"email":          @"email",
     @"username":       @"username"
     }];
    
    RKObjectMapping *userStatsMapping = [RKObjectMapping mappingForClass:[Stats class]];
    [userStatsMapping addAttributeMappingsFromDictionary:@{
     @"username":           @"username",
     @"total_winnings":     @"totalWinnings",
     @"total_rank":         @"totalRank",
     @"num_users_in_system":@"totalUsers",
     @"total_games_played": @"totalGames",
     @"total_pc_correct":   @"totalCorrect",
     @"total_user_rating":  @"userRating",
     @"global_winnings":    @"globalWinnings",
     @"fangroup_winnings":  @"fangroupWinnings",
     @"h2h_winnings":       @"h2hWinnings",
     @"global_games_won":   @"globalWon",
     @"fangroup_pools_won": @"fangroupWon",
     @"h2h_won":            @"h2hWon",
     }];

    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[Error class]];
    [errorMapping addAttributeMappingsFromDictionary:@{
     @"code":       @"code",
     @"message":    @"message"
     }];
    
    RKObjectMapping *userMotdMapping = [RKObjectMapping mappingForClass:[Motd class]];
    [userMotdMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"message"]];
    
    RKObjectMapping* responseMapping = [RKObjectMapping mappingForClass:[NSNull class]];
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError);
    NSIndexSet *successStatusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    // Register our mappings with the provider using a response descriptor
    RKResponseDescriptor *gameResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:gameMapping method:RKRequestMethodGET pathPattern:@"competition/games" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *periodResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:periodMapping method:RKRequestMethodGET pathPattern:@"game/periods" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *pointsResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:pointsMapping method:RKRequestMethodGET pathPattern:@"game/points" keyPath:nil statusCodes:nil];
    RKRequestDescriptor *postSelectionDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:postSelectionMapping objectClass:[Selection class] rootKeyPath:nil method:RKRequestMethodPOST];
    RKRequestDescriptor *postAddUsersDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:postAddUsersMapping objectClass:[AddUsers class] rootKeyPath:nil method:RKRequestMethodPOST];
    RKResponseDescriptor *fanResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fanMapping method:RKRequestMethodGET pathPattern:@"user/fangroups" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *competitionResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:competitionMapping method:RKRequestMethodGET pathPattern:@"competition/list" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *fangroupResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fangroupMapping method:RKRequestMethodGET pathPattern:@"competition/fangroups" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *gameLeaderboardResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:gameLeaderboardMapping method:RKRequestMethodGET pathPattern:@"game/leaderboard" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *competitionLeaderboardResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:competitionLeaderboardMapping method:RKRequestMethodGET pathPattern:@"competition/leaderboard" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *competitionPointsResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:competitionPointsMapping method:RKRequestMethodGET pathPattern:@"competition/points" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *poolPointsResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:poolPointsMapping method:RKRequestMethodGET pathPattern:@"pool/points" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *competitionWinnersResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:competitionWinnersMapping method:RKRequestMethodGET pathPattern:@"competition/winners" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *gameWinnersResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:gameWinnersMapping method:RKRequestMethodGET pathPattern:@"game/winners" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *overallWinnersResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:overallWinnersMapping method:RKRequestMethodGET pathPattern:@"user/leaderboard" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *friendPoolResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:friendPoolMapping method:RKRequestMethodGET pathPattern:@"pool/mypools" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *poolMemberResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:poolMemberMapping method:RKRequestMethodGET pathPattern:@"pool/members" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *userAccountResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userAccountMapping method:RKRequestMethodGET pathPattern:@"user/account" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *userAccountUpdateResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userAccountMapping method:RKRequestMethodPOST pathPattern:@"user/account/update" keyPath:nil statusCodes:successStatusCodes];
    RKResponseDescriptor *userStatsResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userStatsMapping method:RKRequestMethodGET pathPattern:@"user/stats" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *errorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodPOST pathPattern:nil keyPath:nil statusCodes:statusCodes];
    RKResponseDescriptor *registerDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userAccountMapping method:RKRequestMethodPOST pathPattern:@"user/register" keyPath:nil statusCodes:successStatusCodes];
    RKResponseDescriptor *createPoolResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:friendPoolMapping method:RKRequestMethodPOST pathPattern:@"pool/create" keyPath:nil statusCodes:successStatusCodes];
    RKResponseDescriptor *userMotdResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMotdMapping method:RKRequestMethodGET pathPattern:@"user/motd" keyPath:nil statusCodes:nil];
    RKResponseDescriptor *userListResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMotdMapping method:RKRequestMethodGET pathPattern:@"user/list" keyPath:nil statusCodes:nil];
    
    RKResponseDescriptor *responseSelectionDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodPOST pathPattern:@"game/selections" keyPath:nil statusCodes:successStatusCodes];
    RKResponseDescriptor *responseAddUsersDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodPOST pathPattern:@"pool/addusers" keyPath:nil statusCodes:successStatusCodes];
    RKResponseDescriptor *responsePoolLeaveDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodPOST pathPattern:@"pool/leave" keyPath:nil statusCodes:successStatusCodes];
    RKResponseDescriptor *responseBankDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodPOST pathPattern:@"game/period/bank" keyPath:nil statusCodes:successStatusCodes];
    
    [objectManager setRequestSerializationMIMEType:RKMIMETypeJSON];
    [objectManager addResponseDescriptor:gameResponseDescriptor];
    [objectManager addResponseDescriptor:periodResponseDescriptor];
    [objectManager addResponseDescriptor:pointsResponseDescriptor];
    [objectManager addRequestDescriptor:postSelectionDescriptor];
    [objectManager addRequestDescriptor:postAddUsersDescriptor];
    [objectManager addResponseDescriptor:fanResponseDescriptor];
    [objectManager addResponseDescriptor:competitionResponseDescriptor];
    [objectManager addResponseDescriptor:fangroupResponseDescriptor];
    [objectManager addResponseDescriptor:gameLeaderboardResponseDescriptor];
    [objectManager addResponseDescriptor:competitionLeaderboardResponseDescriptor];
    [objectManager addResponseDescriptor:competitionPointsResponseDescriptor];
    [objectManager addResponseDescriptor:poolPointsResponseDescriptor];
    [objectManager addResponseDescriptor:competitionWinnersResponseDescriptor];
    [objectManager addResponseDescriptor:gameWinnersResponseDescriptor];
    [objectManager addResponseDescriptor:overallWinnersResponseDescriptor];
    [objectManager addResponseDescriptor:friendPoolResponseDescriptor];
    [objectManager addResponseDescriptor:poolMemberResponseDescriptor];
    [objectManager addResponseDescriptor:userAccountResponseDescriptor];
    [objectManager addResponseDescriptor:userAccountUpdateResponseDescriptor];
    [objectManager addResponseDescriptor:userStatsResponseDescriptor];
    [objectManager addResponseDescriptor:errorDescriptor];
    [objectManager addResponseDescriptor:registerDescriptor];
    [objectManager addResponseDescriptor:createPoolResponseDescriptor];
    [objectManager addResponseDescriptor:userMotdResponseDescriptor];
    [objectManager addResponseDescriptor:userListResponseDescriptor];
    [objectManager addResponseDescriptor:responseSelectionDescriptor];
    [objectManager addResponseDescriptor:responseAddUsersDescriptor];
    [objectManager addResponseDescriptor:responsePoolLeaveDescriptor];
    [objectManager addResponseDescriptor:responseBankDescriptor];
    
    // Whenever a person opens the app, check for a cached session
    if ((FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) && (self.loggedin)) {
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          //[self sessionStateChanged:session state:state error:error];
                                      }];
    }
    
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



- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // if the app is going away, we close the session object
    // [FBSession.activeSession close];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Call the 'activateApp' method to log an app event for use in analytics and advertising reporting.
    [FBAppEvents activateApp];
    [FBAppEvents setFlushBehavior:FBAppEventsFlushBehaviorExplicitOnly];
    
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBAppCall handleDidBecomeActive];
}



@end
