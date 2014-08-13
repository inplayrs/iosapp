//
//  IPFantasyViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 22/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPFantasyViewController.h"
#import "GameDataController.h"
#import "IPFantasyItemCell.h"
#import "Game.h"
#import "Period.h"
#import "Selection.h"
#import "Points.h"
#import "PeriodOptions.h"
#import "RestKit.h"
#import "IPAppDelegate.h"
#import "IPLeaderboardViewController.h"
#import "IPMultiLoginViewController.h"
#import "IPTutorialViewController.h"
#import "IPCreateViewController.h"
#import "Flurry.h"
#import "Error.h"
#import "TSMessage.h"
#import "FriendPool.h"
#import "IPAddFriendsViewController.h"
#import "IPStatsViewController.h"

#define NOTSUBMITTED -1
#define SUBMITTED 0

#define FRIENDS 1
#define PLAYERS 2

enum State {
    INACTIVE=-2,
    PREPLAY=-1,
    TRANSITION=0,
    INPLAY=1,
    COMPLETED=2,
    SUSPENDED=3,
    NEVERINPLAY=4,
    ARCHIVED=5
};


@implementation IPFantasyViewController

@synthesize selectedRow, isLoaded, isUpdated, isLoading, pointsChanged, inplayIndicator, leaderboardViewController, multiLoginViewController, tutorialViewController, submitButton, username, friendButton, createViewController, globalLabel,  h2hLabel, friendLabel, global1, global2, h2h1, h2h2, friend1, friend2, friendPools, globalViewController, friendViewController, friendControllerList, selectedFriendPool, addFriendsViewController, globalButton, h2hButton, fromLeaderboard, statsViewController, selectedPeriodOption, periodOptionList, changeSelectionList;


- (void)getPeriods:(id)sender
{
 
    if (self.isLoading)
        return;
    self.isLoading = YES;
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"game/periods?game_id=%ld", (long)self.game.gameID];
    [objectManager getObjectsAtPath:path parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSArray* temp = [result array];
        NSDateFormatter *startingDateFormat = [[NSDateFormatter alloc] init];
        NSDateFormatter *endingDateFormat = [[NSDateFormatter alloc] init];
        [startingDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [endingDateFormat setDateFormat:@"MM-dd HH:mm"];
        [startingDateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [endingDateFormat setTimeZone:[NSTimeZone systemTimeZone]];
        BOOL found = NO;
        [periodOptionList removeAllObjects];
        // [self.dataController.periodList removeAllObjects];
        // [self.dataController.selectionList removeAllObjects];
        
        for (int i=0; i<temp.count; i++) {
            Period *period = [temp objectAtIndex:i];
            self.game.state = period.gameState;
            // data checking and formatting
            if (!period.name)
                period.name = @"";
            if (!period.elapsedTime)
                period.elapsedTime = @"";
            if (!period.score)
                period.score = @"";
            if (!period.points0)
                period.points0 = @"";
            if (!period.points1)
                period.points1 = @"";
            if (!period.points2)
                period.points2 = @"";
            if (!period.startDate) {
                period.startDate = @"";
            } else {
                NSDate *date = [startingDateFormat dateFromString:period.startDate];
                period.startDate = [endingDateFormat stringFromDate:date];
            }
            for (int i=0; i < [period.periodOptions count]; i++) {
                PeriodOptions *periodOptions = [period.periodOptions objectAtIndex:i];
                if (!periodOptions.name)
                    periodOptions.name = @"0";
                if (!periodOptions.points)
                    periodOptions.points = @"0";
                [periodOptionList setObject:periodOptions forKey:[NSString stringWithFormat: @"%ld",(long)periodOptions.periodOptionID]];
            }
            NSSortDescriptor *pointsSorter = [[NSSortDescriptor alloc] initWithKey:@"points" ascending:YES];
            NSSortDescriptor *nameSorter = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
            [period.periodOptions sortUsingDescriptors:[NSArray arrayWithObjects:pointsSorter, nameSorter, nil]];
            
            for (int j=0; j<[self.dataController.periodList count]; j++) {
                Period *existingPeriod = [self.dataController.periodList objectAtIndex:j];
                if (period.periodID == existingPeriod.periodID) {
                    found = YES;
                    [self.dataController.periodList replaceObjectAtIndex:j withObject:period];
                }
            }
            if (!found) {
                [self.dataController addGameWithPeriod:period];
                Selection *selection = [[Selection alloc] initWithPeriodID:period.periodID];
                [self.dataController addGameWithSelection:selection];
            }
            found = NO;
            /*
            [self.dataController addGameWithPeriod:period];
            Selection *selection = [[Selection alloc] initWithPeriodID:period.periodID];
            [self.dataController addGameWithSelection:selection];
             */
        }
         if (self.oldState != self.game.state) {
             IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
             appDelegate.refreshLobby = YES;
             self.oldState = self.game.state;
         }
        [self getPoints];
     } failure:^(RKObjectRequestOperation *operation, NSError *error){
         [self.refreshControl endRefreshing];
         self.isLoading = NO;
     }];

}


- (void)getPoints
{
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path;
    if (username)
        path = [NSString stringWithFormat:@"game/points?game_id=%ld&username=%@", (long)self.game.gameID, self.username];
    else
        path = [NSString stringWithFormat:@"game/points?game_id=%ld", (long)self.game.gameID];
    [objectManager getObjectsAtPath:path parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        
        Points *points = [result firstObject];
            // data checking and formatting
            if ((!points.globalPot) || ([points.globalPot isEqualToString:@"-1"]))
                points.globalPot = @"Pot: $-";
            else
                points.globalPot = [@"Pot: $" stringByAppendingString:points.globalPot];
            if ((!points.fangroupPot) || ([points.fangroupPot isEqualToString:@"-1"]))
                points.fangroupPot = @"Pot: $-";
            else
                points.fangroupPot = [@"Pot: $" stringByAppendingString:points.fangroupPot];
            if ((!points.h2hPot) || ([points.h2hPot isEqualToString:@"-1"]))
                points.h2hPot = @"Pot: $20";
            else
                points.h2hPot = [@"Pot: $" stringByAppendingString:points.h2hPot];
         
            if ((!points.winnings) || ([points.winnings isEqualToString:@"-1"]))
                points.winnings = @"-";
            else
                points.winnings = [@"$" stringByAppendingString:points.winnings];
            if (self.game.state == COMPLETED)
            {
                if ((points.globalWinnings) && (![points.globalWinnings isEqualToString:@"0"]))
                    points.globalPot = [NSString stringWithFormat: @"Won: $%@/%@", points.globalWinnings, points.globalPot];
                if ((points.fangroupWinnings) && (![points.fangroupWinnings isEqualToString:@"0"]))
                    points.fangroupPot = [NSString stringWithFormat: @"Won: $%@/%@", points.fangroupWinnings, points.fangroupPot];
                if ((points.h2hWinnings) && (![points.h2hWinnings isEqualToString:@"0"]))
                    points.h2hPot = [NSString stringWithFormat: @"Won: $%@/%@", points.h2hWinnings, points.h2hPot];
            }
            
            if ((!points.globalRank) || ([points.globalRank isEqualToString:@"2000000000"]) || ([points.globalRank isEqualToString:@"0"]))
                points.globalRank = @"#-";
            else
                points.globalRank = [@"#" stringByAppendingString:points.globalRank];
            if ((!points.fangroupRank) || ([points.fangroupRank isEqualToString:@"2000000000"]) || ([points.fangroupRank isEqualToString:@"0"]))
                points.fangroupRank = @"#-";
            else
                points.fangroupRank = [@"#" stringByAppendingString:points.fangroupRank];
            if ((!points.userinfangroupRank) || ([points.userinfangroupRank isEqualToString:@"2000000000"]) || ([points.userinfangroupRank isEqualToString:@"0"]))
                points.userinfangroupRank = @"#-";
            else
                points.userinfangroupRank = [@"#" stringByAppendingString:points.userinfangroupRank];
            
            if ((!points.globalPoints) || ([points.globalPoints isEqualToString:@"-1"]))
                points.globalPoints = @"0";
            if (!points.h2hUser)
                points.h2hUser = @"TBD";
            if (!points.fangroupName)
                points.fangroupName = @"-";
            if ((!points.h2hPoints) || ([points.h2hPoints isEqualToString:@"-1"]))
                points.h2hPoints = @"0";
         
            if (!points.globalPoolSize)
                points.globalPoolSize = @"-";
            if (!points.numFangroups)
                points.numFangroups = @"-";
            if (!points.fangroupPoolSize)
                points.fangroupPoolSize = @"-";
         
            if (![self.oldPoints isEqualToString:points.globalPoints])
                self.pointsChanged = YES;
            if ([points.periodSelections count] > 0) {
                self.dataController.userState = SUBMITTED;
                if ((self.isLoaded == NO) || (self.isUpdated == YES) || (self.pointsChanged == YES)) {
                    if (self.isUpdated == YES)
                        self.isUpdated = NO;
                    // [self.dataController.selectionList removeAllObjects];
                    for (int i=0; i < [points.periodSelections count]; i++) {
                        Selection *newSelection = [points.periodSelections objectAtIndex:i];
                        if (newSelection.periodOptionID > 0) {
                            PeriodOptions *periodOption = [periodOptionList objectForKey:[NSString stringWithFormat: @"%ld", (long)newSelection.periodOptionID]];
                            newSelection.periodName = periodOption.name;
                            newSelection.potentialPoints = periodOption.points;
                        }
                        if (!newSelection.awardedPoints)
                            newSelection.awardedPoints = @"0";
                        if (!newSelection.potentialPoints)
                            newSelection.potentialPoints = @"0";
                        for (int j=0; j<[self.dataController.selectionList count]; j++) {
                            Selection *existingSelection = [self.dataController.selectionList objectAtIndex:j];
                            if (newSelection.periodID == existingSelection.periodID) {
                                [self.dataController.selectionList replaceObjectAtIndex:j withObject:newSelection];
                            }
                        }
                        
                        // [self.dataController.selectionList addObject:newSelection];
                    }
                }
            } else {
                // NSLog (@"0 selections, set user sumbitted to false");
            }
        self.oldPoints = points.globalPoints;
        self.pointsChanged = NO;
        self.dataController.points = points;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd HH:mm"];
        NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                                 [formatter stringFromDate:[NSDate date]]];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]}];
        [self refresh:self];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        [self.refreshControl endRefreshing];
        self.isLoading = NO;
    }];
}

- (void)postSelections:(NSMutableArray *)postSelectionList
{
    self.isLoading = YES;
    [self.submitButton setEnabled:NO];

    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"game/selections?game_id=%ld", (long)self.game.gameID];
    [objectManager postObject:postSelectionList path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
            self.isUpdated = YES;
            self.isLoading = NO;
            // [self.submitButton setEnabled:YES];
            if (self.dataController.userState == NOTSUBMITTED) {
                self.dataController.userState = SUBMITTED;
                self.navigationItem.rightBarButtonItem = nil;
                [self getPeriods:self];
                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.game.name,
                                            @"gameName", @"Submit", @"result", nil];
                [Flurry logEvent:@"SUBMIT" withParameters:dictionary];
                [TSMessage showNotificationInViewController:self
                                                          title:@"Entry Successful"
                                                       subtitle:@"Your selections have been entered. Your entry has been submitted to all pools."
                                                          image:nil
                                                           type:TSMessageNotificationTypeSuccess
                                                       duration:TSMessageNotificationDurationAutomatic
                                                       callback:nil
                                                    buttonTitle:nil
                                                 buttonCallback:nil
                                                     atPosition:TSMessageNotificationPositionTop
                                            canBeDismisedByUser:YES];
                IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
                appDelegate.refreshLobby = YES;
            } else {
                [self getPeriods:self];
                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.game.name,
                                            @"gameName", @"Update", @"result", nil];
                [Flurry logEvent:@"SUBMIT" withParameters:dictionary];
                [TSMessage showNotificationInViewController:self
                                                      title:@"Player Updated"
                                                   subtitle:@"You have changed your player successfully."
                                                      image:nil
                                                       type:TSMessageNotificationTypeSuccess
                                                   duration:TSMessageNotificationDurationAutomatic
                                                   callback:nil
                                                buttonTitle:nil
                                             buttonCallback:nil
                                                 atPosition:TSMessageNotificationPositionTop
                                        canBeDismisedByUser:YES];
            }
    
        } failure:^(RKObjectRequestOperation *operation, NSError *error){
            self.isLoading = NO;
            [self.submitButton setEnabled:YES];
            NSArray *errorMessages = [[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey];
            Error *myerror = [errorMessages objectAtIndex:0];
            if (!myerror.message)
                myerror.message = @"Please try again later!";
                NSString *errorString = [NSString stringWithFormat:@"%d", (int)myerror.code];
                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.game.name,
                                        @"gameName", @"Fail", @"result", errorString, @"error", nil];
                [Flurry logEvent:@"SUBMIT" withParameters:dictionary];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Failed" message:myerror.message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
        }];

}


- (void)setGame:(Game *) newGame
{
    if (_game != newGame) {
        _game = newGame;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    Game *theGame = self.game;
    if (username)
        self.title = username;
    else if (theGame)
        self.title = theGame.name;
    [self.tableView setAlwaysBounceVertical:YES];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-only.png"]];
    
    [self.submitButton setEnabled:NO];
    self.dataController = [[GameDataController alloc] init];
    friendPools = [[NSMutableArray alloc] init];
    periodOptionList = [[NSMutableDictionary alloc] init];
    changeSelectionList = [[NSMutableArray alloc] init];
    leaderboardViewController = nil;
    multiLoginViewController = nil;
    tutorialViewController = nil;
    globalViewController = nil;
    friendViewController = nil;
    addFriendsViewController = nil;
    statsViewController = nil;
    selectedRow = 0;
    friendControllerList = [[NSMutableDictionary alloc] init];
    
    UINib *nib = [UINib nibWithNibName:@"IPFantasyItemCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"IPFantasyItemCell"];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh" attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]}];
    refresh.tintColor = [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addFriends:) name:@"AddFriends" object:nil];
}

- (void) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) tutorialPressed:(id)sender {
    if (!self.tutorialViewController) {
        self.tutorialViewController = [[IPTutorialViewController alloc] initWithNibName:@"IPTutorialViewController" bundle:nil];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        else
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    }
    if (self.tutorialViewController) {
        [self.navigationController pushViewController:self.tutorialViewController animated:YES];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Tutorial",
                                    @"click", nil];
        [Flurry logEvent:@"MENU" withParameters:dictionary];
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [timer invalidate];
    timer = nil;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isUpdated = NO;
    self.isLoaded = NO;
    self.isLoading = NO;
    self.oldPoints = @"0";
    self.pointsChanged = NO;
    self.oldState = self.game.state;
    if ([self.tableView respondsToSelector:@selector(setDelaysContentTouches:)]) {
        [self.tableView setDelaysContentTouches:NO];
    }
    
    NSString *stateString = [NSString stringWithFormat:@"%d", (int)self.game.state];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.game.name,
                                @"gameName", stateString, @"state", nil];
    [Flurry logEvent:@"GAME" withParameters:dictionary];
    [self getMyPools:self];
    [self getPeriods:self];

     NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (((self.game.state == INPLAY) || (self.game.state == TRANSITION)) && ([prefs boolForKey:@"autoRefresh"]))
        timer = [NSTimer scheduledTimerWithTimeInterval:30.00 target:self selector:@selector(getPeriods:) userInfo:nil repeats:YES];
    else if (((self.game.state == PREPLAY) || (self.game.state == SUSPENDED) || (self.game.state == NEVERINPLAY)) && ([prefs boolForKey:@"autoRefresh"]))
        timer = [NSTimer scheduledTimerWithTimeInterval:60.00 target:self selector:@selector(getPeriods:) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // custom code
    }
    return self;
}

- (UIView *)headerView
{
    if (!headerView) {
        [[NSBundle mainBundle] loadNibNamed:@"IPFantasyHeaderView" owner:self options:nil];
        
        self.global1.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        self.global2.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        self.h2h1.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        self.h2h2.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        self.friend1.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        self.friend2.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        
        self.globalLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:12.0];
        self.h2hLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:12.0];
        self.friendLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:12.0];
        UIImage *image = [UIImage imageNamed: @"green_dot.png"];
        UIImage *amberImage = [UIImage imageNamed:@"amber.png"];
        if (self.game.inplayType == 0)
            [self.inplayIndicator setImage:amberImage];
        else
            [self.inplayIndicator setImage:image];
        UIImage *friendImage = [UIImage imageNamed:@"create-button-game.png"];
        UIImage *friendImage2 = [UIImage imageNamed:@"create-button-game-hit-state.png"];
        [self.friendButton setBackgroundImage:friendImage forState:UIControlStateNormal];
        [self.friendButton setBackgroundImage:friendImage2 forState:UIControlStateHighlighted];
        [self.friendButton setBackgroundImage:friendImage2 forState:UIControlStateDisabled];
        self.friendButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:12.0];
        [self.friendButton setTitle:@"CREATE" forState:UIControlStateNormal];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, 0.0, -3.0, 0.0);
            self.friendButton.titleEdgeInsets = titleInsets;
        }
        UIImage *buttonImage = [UIImage imageNamed:@"game-header-button.png"];
        UIImage *buttonImage2 = [UIImage imageNamed:@"game-header-button-hit.png"];
        [self.globalButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self.globalButton setBackgroundImage:buttonImage2 forState:UIControlStateHighlighted];
        [self.h2hButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self.h2hButton setBackgroundImage:buttonImage2 forState:UIControlStateHighlighted];
        
    } else {
    
        if ((self.game.state == INPLAY) || (self.game.state == SUSPENDED)) {
            [self.inplayIndicator setHidden:NO];
        } else {
            [self.inplayIndicator setHidden:YES];
        }
    
        Points *points = self.dataController.points;
        self.global1.text = [points.globalPoints stringByAppendingString:@" points"];
        self.global2.text = [points.globalRank stringByAppendingFormat:@"/%@", points.globalPoolSize];
        if (!points.lateEntry) {
            self.h2h1.text = points.h2hUser;
            self.h2h2.text = [points.h2hPoints stringByAppendingString:@" points"];
        } else {
            self.h2h2.text = @"[Not Entered]";
            self.h2h1.text = @"";
        }
        /*
        if (!points.h2hUser) {
            self.h2h2.text = @"[Not Entered]";
            self.h2h1.text = @"";
        }
         */
        
        if ([friendPools count] == 1) {
            FriendPool *friendPool = [friendPools objectAtIndex:0];
            [self.friendButton setTitle:friendPool.name forState:UIControlStateNormal];
            [self.friendButton setEnabled:YES];
        } else if ([friendPools count] > 1) {
            [self.friendButton setTitle:@"VIEW" forState:UIControlStateNormal];
            [self.friendButton setEnabled:YES];
        } else if ((self.game.state > 0) && ([friendPools count] == 0)) {
            [self.friendButton setTitle:@"Not Entered" forState:UIControlStateDisabled];
            [self.friendButton setEnabled:NO];
        } else if ([friendPools count] == 0) {
            [self.friendButton setTitle:@"CREATE" forState:UIControlStateNormal];
            [self.friendButton setEnabled:YES];
        }
        
    }
 
    return headerView;
}

- (UIView *)footerView
{
    if (!footerView) {
        [[NSBundle mainBundle] loadNibNamed:@"IPFantasyFooterView" owner:self options:nil];

    
        UIImage *image = [UIImage imageNamed:@"submit-button.png"];
        UIImage *image2 = [UIImage imageNamed:@"submit-button-hit-state.png"];
        UIImage *image3 = [UIImage imageNamed:@"submit-button-disabled.png"];
        [self.submitButton setBackgroundImage:image forState:UIControlStateNormal];
        [self.submitButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
        [self.submitButton setBackgroundImage:image3 forState:UIControlStateDisabled];
        self.submitButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
            self.submitButton.titleEdgeInsets = titleInsets;
        }
    }
    
    switch (self.game.state) {
        case (INACTIVE):
        case (COMPLETED):
        case (ARCHIVED):
            if (([self.dataController.points.winnings isEqualToString:@"-"]) || (!self.dataController.points.winnings)) {
                [self.submitButton setTitle:@"COMPLETE" forState:UIControlStateNormal];
                [self.submitButton setTitle:@"COMPLETE" forState:UIControlStateDisabled];
            } else if ([self.dataController.points.winnings isEqualToString:@"$0"]) {
                [self.submitButton setTitle:@"NO WINNINGS!" forState:UIControlStateNormal];
                [self.submitButton setTitle:@"NO WINNINGS!" forState:UIControlStateDisabled];
            } else {
                NSString *winnings;
                if (self.username)
                    winnings = [self.username stringByAppendingFormat:@" WON %@", self.dataController.points.winnings];
                else
                    winnings = [@"YOU WON " stringByAppendingString:self.dataController.points.winnings];
                winnings = [winnings stringByAppendingString:@"!"];
                [self.submitButton setTitle:winnings forState:UIControlStateNormal];
                [self.submitButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                [self.submitButton setTitle:winnings forState:UIControlStateDisabled];
                [self.submitButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0] forState:UIControlStateDisabled];
            }
            [self.submitButton setEnabled:NO];
            break;
        case (NEVERINPLAY):
        case (INPLAY):
            [self.submitButton setTitle:@"INPLAY" forState:UIControlStateNormal];
            [self.submitButton setEnabled:NO];
            break;
        case (TRANSITION):
        case (PREPLAY):
            if (self.dataController.userState == NOTSUBMITTED) {
                [self.submitButton setTitle:@"SUBMIT" forState:UIControlStateNormal];
            } else {
                [self.submitButton setTitle:@"SUBMITTED" forState:UIControlStateNormal];
            }
            if (self.isLoaded) {
                BOOL allSelected = YES;
                for (int j=0; j<[self.dataController.selectionList count]; j++) {
                    Selection *selection = [self.dataController.selectionList objectAtIndex:j];
                    if (selection.periodOptionID == -1)
                        allSelected = NO;
                }
                if ((allSelected) && (self.dataController.userState == NOTSUBMITTED))
                    [self.submitButton setEnabled:YES];
                else
                    [self.submitButton setEnabled:NO];
            } else {
                [self.submitButton setEnabled:NO];
            }
            break;
        case (SUSPENDED):
        default:
            [self.submitButton setTitle:@"SUSPENDED" forState:UIControlStateNormal];
            [self.submitButton setTitle:@"SUSPENDED" forState:UIControlStateDisabled];
            [self.submitButton setEnabled:NO];
            break;
    }

    return footerView;
}


- (void)refresh:(id)sender {
    [self sortSelections];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
    self.isLoaded = YES;
    self.isLoading = NO;
    
    if (self.username)
        return;
    if (self.dataController.userState == SUBMITTED) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        if (!self.navigationItem.rightBarButtonItem) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tutorial" style:UIBarButtonItemStylePlain target:self action:@selector(tutorialPressed:)];
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0];
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0],UITextAttributeFont,nil];
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
        }
    }
    
}

- (void)sortSelections
{
    [self.dataController.periodList sortUsingSelector:@selector(compareWithPeriod:)];
    for (int i=0; i < [self.dataController.periodList count]; i++) {
        Period *period = [self.dataController objectInPeriodListAtIndex:i];    
        for (int j=0; j < [self.dataController.selectionList count]; j++) {
            Selection *selection = [self.dataController objectInSelectionListAtIndex:j];
            if (period.periodID == selection.periodID) {
                selection.row = i;
                break;
            }
        }
    }
    NSSortDescriptor *primary = [NSSortDescriptor sortDescriptorWithKey:@"row" ascending:YES];
    [self.dataController.selectionList sortUsingDescriptors:@[primary]];
}

- (IBAction)friendClicked:(id)sender {
    
    if ([friendPools count] > 1) {
        CGRect frame = CGRectMake(0, 0, 320, 44);
        UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:frame];
        pickerToolbar.barStyle = UIBarStyleBlack;
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target:self action:@selector(actionPickerCancel:)];
        [barItems addObject:cancelBtn];
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [barItems addObject:flexSpace];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(friendDone:)];
        [barItems addObject:doneButton];
        [pickerToolbar setItems:barItems animated:NO];
        [pickerToolbar setTintColor:[UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]];
        [cancelBtn setTintColor:[UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]];
        [doneButton setTintColor:[UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            [[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0] } forState:UIControlStateNormal];
        } else {
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil];
            [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
        }
        
        CGFloat windowHeight = self.view.superview.frame.size.height;
        myView = [[UIView alloc] initWithFrame:CGRectMake(0, windowHeight-260, 320, 260)];
        [myView setBackgroundColor:[UIColor lightGrayColor]];
        UIPickerView *myPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 320, 216)];
        myPicker.showsSelectionIndicator=YES;
        myPicker.dataSource = self;
        myPicker.delegate = self;
        myPicker.tag = FRIENDS;
        [myPicker selectRow:0 inComponent:0 animated:NO];
        [myView addSubview:pickerToolbar];
        [myView addSubview:myPicker];
        
        [self.view.superview addSubview:myView];
        [self.view.superview bringSubviewToFront:myView];
        [self.tableView setUserInteractionEnabled:NO];
        self.selectedFriendPool = [friendPools objectAtIndex:0];
    
    } else if ([friendPools count] == 1) {
        if (!self.friendViewController) {
            self.friendViewController = [[IPLeaderboardViewController alloc] initWithNibName:@"IPLeaderboardViewController" bundle:nil];
            self.friendViewController.game = self.game;
            self.friendViewController.friendPool = [friendPools objectAtIndex:0];
            self.friendViewController.lbType = 2;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
            else
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        }
        if (self.friendViewController)
            [self.navigationController pushViewController:self.friendViewController animated:YES];
    } else {
        IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.loggedin == NO) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login required" message:@"Please login first!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        if (!self.createViewController) {
            self.createViewController = [[IPCreateViewController alloc] initWithNibName:@"IPCreateViewController" bundle:nil];
        }
        if (self.createViewController) {
            [self.navigationController presentViewController:self.createViewController animated:YES completion:nil];
        }
    }
}

-(void)friendDone:(id)sender {
    [self friendLBPressed:self];
    [myView removeFromSuperview];
    [self.tableView setUserInteractionEnabled:YES];
}

-(void)actionPickerCancel:(id)sender {
    [myView removeFromSuperview];
    [self.tableView setUserInteractionEnabled:YES];
}

-(void)playerDone:(id)sender {
    [myView removeFromSuperview];
    [self.tableView setUserInteractionEnabled:YES];
    Selection *selection = [self.dataController objectInSelectionListAtIndex:selectedRow];
    selection.periodOptionID = selectedPeriodOption.periodOptionID;
    selection.periodName = selectedPeriodOption.name;
    selection.potentialPoints = selectedPeriodOption.points;
    if (self.dataController.userState == SUBMITTED) {
        [changeSelectionList removeAllObjects];
        [changeSelectionList addObject:selection];
        [self postSelections:changeSelectionList];
    } else {
        [self.tableView reloadData];
    }
}



- (void) friendLBPressed:(id)sender {
    if ([friendControllerList objectForKey:self.selectedFriendPool.name] == nil) {
        friendViewController = [[IPLeaderboardViewController alloc] initWithNibName:@"IPLeaderboardViewController" bundle:nil];
        friendViewController.game = self.game;
        friendViewController.friendPool = self.selectedFriendPool;
        friendViewController.lbType = 2;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        else
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        [friendControllerList setObject:friendViewController forKey:self.selectedFriendPool.name];
    }
    
    if ([friendControllerList objectForKey:self.selectedFriendPool.name]) {
        [self.navigationController pushViewController:[friendControllerList objectForKey:self.selectedFriendPool.name] animated:YES];
    }
}


- (IBAction)globalClicked:(id)sender {
    if (!self.globalViewController) {
        self.globalViewController = [[IPLeaderboardViewController alloc] initWithNibName:@"IPLeaderboardViewController" bundle:nil];
        self.globalViewController.game = self.game;
        self.globalViewController.lbType = 0;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        else
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    }
    if (self.globalViewController)
        [self.navigationController pushViewController:self.globalViewController animated:YES];
}


- (IBAction)h2hClicked:(id)sender {
    if ((self.dataController.points.h2hUser) && (self.game.state > 0) && (!self.dataController.points.lateEntry)) {
        if (!self.statsViewController) {
            self.statsViewController = [[IPStatsViewController alloc] initWithNibName:@"IPStatsViewController" bundle:nil];
            self.statsViewController.externalUsername = self.dataController.points.h2hUser;
            if (self.dataController.points.h2hFBID)
                self.statsViewController.externalFBID = self.dataController.points.h2hFBID;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
            else
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        }
        if (self.statsViewController)
            [self.navigationController pushViewController:self.statsViewController animated:YES];
    } else if (self.game.state <= 0) {
        [TSMessage showNotificationInViewController:self
                                              title:@"No Head2Head yet"
                                           subtitle:@"You will be automatically assigned a H2H player when the game starts."
                                              image:nil
                                               type:TSMessageNotificationTypeWarning
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:nil
                                         atPosition:TSMessageNotificationPositionTop
                                canBeDismisedByUser:YES];
    } else if (self.dataController.points.lateEntry) {
        [TSMessage showNotificationInViewController:self
                                              title:@"Late Entry"
                                           subtitle:@"A H2H player is only assigned at the start of the game."
                                              image:nil
                                               type:TSMessageNotificationTypeWarning
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:nil
                                         atPosition:TSMessageNotificationPositionTop
                                canBeDismisedByUser:YES];
    }
}

-(void)refreshView:(UIRefreshControl *)refresh
{
    if (!self.isLoading)
        [self getPeriods:self];
    else
        [self.refreshControl endRefreshing];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataController countOfPeriodList];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Period *periodAtIndex = [self.dataController objectInPeriodListAtIndex:indexPath.row];
    Selection *selectionAtIndex = [self.dataController objectInSelectionListAtIndex:indexPath.row];
    
    IPFantasyItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IPFantasyItemCell"];
    
    [cell setController:self];
    [cell setTableView:tableView];
    
    
    // generic stuff for all states
    UIImageView *imageView;
    if (indexPath.row % 2)
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-bar-2.png"]];
    else
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-bar-1.png"]];
    cell.backgroundView = imageView;
    [[cell periodLabel] setText:periodAtIndex.name];
    [[cell timeLabel] setText:periodAtIndex.score];
    cell.periodLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:16.0];
    cell.timeLabel.font = [UIFont fontWithName:@"Avalon-Book" size:12.0];
    cell.pointsLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
    cell.periodLabel.textColor = [UIColor colorWithRed:32.0/255.0 green:35.0/255.0 blue:45.0/255.0 alpha:1.0];
    cell.timeLabel.textColor = [UIColor colorWithRed:32.0/255.0 green:35.0/255.0 blue:45.0/255.0 alpha:1.0];
    UIImage *image = [UIImage imageNamed:@"submit-button.png"];
    UIImage *image2 = [UIImage imageNamed:@"submit-button-hit-state.png"];
    UIImage *image3 = [UIImage imageNamed:@"submit-button-disabled.png"];
    [cell.selectionButton setBackgroundImage:image forState:UIControlStateNormal];
    [cell.selectionButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
    [cell.selectionButton setBackgroundImage:image3 forState:UIControlStateDisabled];
    cell.selectionButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:16.0];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        cell.selectionButton.titleEdgeInsets = titleInsets;
    }
    [cell.selectionButton setTitle:@"SELECT PLAYER" forState:UIControlStateNormal];
    
    
    // state specific stuff
    switch (self.game.state) {
        case (TRANSITION):
        case (PREPLAY):  {
            if (self.dataController.userState == SUBMITTED) {
                [[cell pointsLabel] setText:selectionAtIndex.potentialPoints];
                [[cell pointsLabel] setTextColor:[UIColor blackColor]];
            }
            [[cell selectionButton] setEnabled:YES];
            [[cell inplayIcon] setHidden:YES];
            if (selectionAtIndex.periodOptionID > 0) {
                [cell.selectionButton setTitle:selectionAtIndex.periodName forState:UIControlStateNormal];
                [[cell pointsLabel] setText:selectionAtIndex.potentialPoints];
                [[cell pointsLabel] setTextColor:[UIColor blackColor]];
            }
            break;
        }
        case (NEVERINPLAY):
        case (SUSPENDED):
        case (INPLAY):  {
            UIImage *amberImage = [UIImage imageNamed:@"amber.png"];
            [[cell inplayIcon] setImage:amberImage];
            [[cell inplayIcon] setHidden:NO];
            [[cell selectionButton] setEnabled:NO];
            if (self.dataController.userState == SUBMITTED) {
                [cell.selectionButton setTitle:selectionAtIndex.periodName forState:UIControlStateNormal];
                [[cell pointsLabel] setText:selectionAtIndex.potentialPoints];
                [[cell pointsLabel] setTextColor:[UIColor blackColor]];
            }
            break;
        }
        case (COMPLETED):
        case (ARCHIVED):
        default: {
            UIImageView *completedView;
            if (indexPath.row % 2)
                completedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"completed-row-dark.png"]];
            else
                completedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"completed-row-light.png"]];
            cell.backgroundView = completedView;
            cell.periodLabel.textColor = [UIColor colorWithRed:71.0/255.0 green:71.0/255.0 blue:71.0/255.0 alpha:1.0];
            cell.timeLabel.textColor = [UIColor colorWithRed:71.0/255.0 green:71.0/255.0 blue:71.0/255.0 alpha:1.0];
            [[cell selectionButton] setEnabled:NO];
            [[cell inplayIcon] setHidden:YES];
            if (self.dataController.userState == SUBMITTED) {
                [cell.selectionButton setTitle:selectionAtIndex.periodName forState:UIControlStateNormal];
                [[cell pointsLabel] setText:selectionAtIndex.awardedPoints];
                if ([selectionAtIndex.awardedPoints isEqualToString:@"0"]) {
                    [[cell pointsLabel] setTextColor:[UIColor colorWithRed:237.0/255.0 green:0.0/255.0 blue:9.0/255.0 alpha:1.0]];
                } else {
                    [[cell pointsLabel] setTextColor:[UIColor colorWithRed:189.0/255.0 green:233.0/255.0 blue:51.0/255.0 alpha:1.0]];
                }
            }
            break;
        }
    }
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}



#pragma mark - Table view delegate


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (fromLeaderboard)
        return nil;
    else
        return [self headerView];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (fromLeaderboard)
        return 0;
    else
        return [[self headerView] bounds].size.height;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [self footerView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return [[self footerView] bounds].size.height;
}



- (IBAction)submitSelections:(id)sender
{
    
    IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
    switch (self.dataController.userState) {
        case (NOTSUBMITTED):
            if (appDelegate.loggedin == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign In required" message:@"Please register or login first!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                if (!self.multiLoginViewController) {
                    self.multiLoginViewController = [[IPMultiLoginViewController alloc] initWithNibName:@"IPMultiLoginViewController" bundle:nil];
                    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
                        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
                    else
                        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
                }
                if (self.multiLoginViewController)
                    [self.navigationController pushViewController:self.multiLoginViewController animated:YES];
                return;
            }
            [self postSelections:self.dataController.selectionList];
            break;
        case (SUBMITTED):
            if (appDelegate.loggedin == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign In required" message:@"Please register or login first!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
            [self postSelections:self.dataController.selectionList];
            break;
    }
    
    
}


- (void)changeSelection:(id)sender atIndexPath:(NSIndexPath *)ip
{
    Period *periodAtIndex = [self.dataController objectInPeriodListAtIndex:ip.row];
    PeriodOptions *periodOption = [periodAtIndex.periodOptions objectAtIndex:0];
    IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.loggedin == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign In required" message:@"Please register or login first!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        if (!self.multiLoginViewController) {
            self.multiLoginViewController = [[IPMultiLoginViewController alloc] initWithNibName:@"IPMultiLoginViewController" bundle:nil];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
            else
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        }
        if (self.multiLoginViewController)
            [self.navigationController pushViewController:self.multiLoginViewController animated:YES];
    } else {
        CGRect frame = CGRectMake(0, 0, 320, 44);
        UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:frame];
        pickerToolbar.barStyle = UIBarStyleBlack;
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target:self action:@selector(actionPickerCancel:)];
        [barItems addObject:cancelBtn];
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [barItems addObject:flexSpace];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(playerDone:)];
        [barItems addObject:doneButton];
        [pickerToolbar setItems:barItems animated:NO];
        [pickerToolbar setTintColor:[UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]];
        [cancelBtn setTintColor:[UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]];
        [doneButton setTintColor:[UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            [[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0] } forState:UIControlStateNormal];
        } else {
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil];
            [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
        }
        
        CGFloat windowHeight = self.view.superview.frame.size.height;
        myView = [[UIView alloc] initWithFrame:CGRectMake(0, windowHeight-260, 320, 260)];
        [myView setBackgroundColor:[UIColor lightGrayColor]];
        UIPickerView *myPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 320, 216)];
        myPicker.showsSelectionIndicator=YES;
        myPicker.dataSource = self;
        myPicker.delegate = self;
        myPicker.tag = PLAYERS;
        [myPicker selectRow:0 inComponent:0 animated:NO];
        [myView addSubview:pickerToolbar];
        [myView addSubview:myPicker];
        
        [self.view.superview addSubview:myView];
        [self.view.superview bringSubviewToFront:myView];
        [self.tableView setUserInteractionEnabled:NO];
        self.selectedPeriodOption = periodOption;
        self.selectedRow = ip.row;
        [myPicker reloadAllComponents];
    }
}


- (void)getMyPools:(id)sender
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager getObjectsAtPath:@"pool/mypools" parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         [friendPools removeAllObjects];
         NSArray* temp = [result array];
         for (int i=0; i<temp.count; i++) {
             FriendPool *friendPool = [temp objectAtIndex:i];
             if (!friendPool.name)
                 friendPool.name = @"Unknown";
             if (!friendPool.numPlayers)
                 friendPool.numPlayers = @"0";
             [friendPools addObject:friendPool];
         }
         if ([friendPools count] != 0) {
             [friendPools sortUsingSelector:@selector(compareWithName:)];
         }
     } failure:nil];
}

#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == FRIENDS) {
        return [friendPools count];
    } else {
        Period *period = [self.dataController objectInPeriodListAtIndex:self.selectedRow];
        return [period.periodOptions count];
    }
}


- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (pickerView.tag == FRIENDS) {
        FriendPool *friendPool = [friendPools objectAtIndex:row];
        return friendPool.name;
    } else {
        Period *period = [self.dataController objectInPeriodListAtIndex:self.selectedRow];
        if ([period.periodOptions count] > 0) {
            PeriodOptions *periodOption = [period.periodOptions objectAtIndex:row];
            return [periodOption.name stringByAppendingFormat:@"  %@", periodOption.points];
        } else {
            return @"No Players loaded yet";
        }
    }
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    if (pickerView.tag == FRIENDS) {
        self.selectedFriendPool = [friendPools objectAtIndex:row];
    } else {
        Period *period = [self.dataController objectInPeriodListAtIndex:self.selectedRow];
        self.selectedPeriodOption = [period.periodOptions objectAtIndex:row];
    }
}




/*
        if (row == 0) {
            self.selectedCompetitionID = competition.competitionID;
            self.selectedCompetitionRow = 0;
        }
*/




- (void) addFriends:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    FriendPool *friendPool = [userInfo objectForKey:@"friendPool"];
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    [self.tableView reloadData];
    if (!self.addFriendsViewController) {
        self.addFriendsViewController = [[IPAddFriendsViewController alloc] initWithNibName:@"IPAddFriendsViewController" bundle:nil];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        else
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    }
    if (self.addFriendsViewController) {
        self.addFriendsViewController.poolID = friendPool.poolID;
        [self.navigationController pushViewController:self.addFriendsViewController animated:YES];
    }
}




@end
