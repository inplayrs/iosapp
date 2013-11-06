//
//  IPGameViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 22/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPGameViewController.h"
#import "GameDataController.h"
#import "IPGameItemCell.h"
#import "Game.h"
#import "Period.h"
#import "Selection.h"
#import "Points.h"
#import "RestKit.h"
#import "IPAppDelegate.h"
#import "IPLeaderboardViewController.h"
#import "IPFanViewController.h"
#import "IPRegisterViewController.h"
#import "IPTutorialViewController.h"
#import "Flurry.h"
#import "Error.h"
#import "TSMessage.h"


#define CONFIRM_BANK 1

#define NOTSUBMITTED -1
#define SUBMITTED 0

enum State {
    INACTIVE=-2,
    PREPLAY=-1,
    TRANSITION=0,
    INPLAY=1,
    COMPLETED=2,
    SUSPENDED=3,
    NEVERINPLAY=4
};

enum GameType {
    WINAB=20,
    UPDOWN=21,
    THRUCUT=22,
    YESNO=23,
    OVERUNDER=24,
    HOMEDRAWAWAY=30,
    TOP10=31,
    TOP5=32,
    TOP3=33,
    LEADTHRUCUT=34,
    ZEROONETWO=35
};


@implementation IPGameViewController

@synthesize leftLabel, rightLabel, pointsButton, left, selectedRow, selectionHeader1, selectionHeader2, selectionHeader3, selectionHeader4, selectionHeader5, selectionLabel0, selectionLabel1, selectionLabel2, isLoaded, isUpdated, isLoading, pointsChanged, inplayIndicator, leaderboardViewController, fanViewController, registerViewController, tutorialViewController, submitButton, fangroupChallenge;


- (void)getPeriods:(id)sender
{
 
    if (self.isLoading)
        return;
    self.isLoading = YES;
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"game/periods?game_id=%d", self.game.gameID];
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
    NSString *path = [NSString stringWithFormat:@"game/points?game_id=%d", self.game.gameID];
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
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0]}];
        [self refresh:self];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        [self.refreshControl endRefreshing];
        self.isLoading = NO;
    }];
}

- (void)postSelections
{
    self.isLoading = YES;
    [self.submitButton setEnabled:NO];

    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"game/selections?game_id=%d", self.game.gameID];
    [objectManager postObject:self.dataController.selectionList path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
            self.isUpdated = YES;
            self.isLoading = NO;
            [self.submitButton setEnabled:YES];
            if (self.dataController.userState == NOTSUBMITTED) {
                self.dataController.userState = SUBMITTED;
                self.navigationItem.rightBarButtonItem = nil;
                [self getPeriods:self];
                if ((self.game.state == PREPLAY) || (self.game.state == TRANSITION)) {
                    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.game.name,
                                            @"gameName", @"Submit", @"result", nil];
                    [Flurry logEvent:@"SUBMIT" withParameters:dictionary];
                    [TSMessage showNotificationInViewController:self
                                                          title:@"Entry Successful"
                                                       subtitle:@"Your selections have been entered."
                                                          image:nil
                                                           type:TSMessageNotificationTypeSuccess
                                                       duration:TSMessageNotificationDurationAutomatic
                                                       callback:nil
                                                    buttonTitle:nil
                                                 buttonCallback:nil
                                                     atPosition:TSMessageNotificationPositionTop
                                            canBeDismisedByUser:YES];
                    /*
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Entry Successful" message:@"You have successfully entered your selections for this game!  Your entry has been submitted to all 3 pools." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                     */
                } else {
                    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.game.name,
                                                @"gameName", @"Late", @"result", nil];
                    [Flurry logEvent:@"SUBMIT" withParameters:dictionary];
                    [TSMessage showNotificationInViewController:self
                                                          title:@"Entry Successful"
                                                       subtitle:@"Your selections have been entered."
                                                          image:nil
                                                           type:TSMessageNotificationTypeSuccess
                                                       duration:TSMessageNotificationDurationAutomatic
                                                       callback:nil
                                                    buttonTitle:nil
                                                 buttonCallback:nil
                                                     atPosition:TSMessageNotificationPositionTop
                                            canBeDismisedByUser:YES];
                    /*
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Entry Successful" message:@"You have successfully entered your selections for this game!  The game has started, so you will not be entered into the Fan and H2H pools." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                     */
                }
                IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
                appDelegate.refreshLobby = YES;
            } else {
                [self getPeriods:self];
                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.game.name,
                                            @"gameName", @"Update", @"result", nil];
                [Flurry logEvent:@"SUBMIT" withParameters:dictionary];
                [TSMessage showNotificationInViewController:self
                                                      title:@"Update Successful"
                                                   subtitle:@"Your selections have been updated."
                                                      image:nil
                                                       type:TSMessageNotificationTypeSuccess
                                                   duration:TSMessageNotificationDurationAutomatic
                                                   callback:nil
                                                buttonTitle:nil
                                                buttonCallback:nil
                                                 atPosition:TSMessageNotificationPositionTop
                                                canBeDismisedByUser:YES];
                /*
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update Successful" message:@"You have successfully updated your selections for this game!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                 */
            }
    
        } failure:^(RKObjectRequestOperation *operation, NSError *error){
            self.isLoading = NO;
            [self.submitButton setEnabled:YES];
            NSArray *errorMessages = [[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey];
            Error *myerror = [errorMessages objectAtIndex:0];
            if (!myerror.message)
                myerror.message = @"Please try again later!";
            if (myerror.code == 2201) {
                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.game.name,
                                            @"gameName", @"Fangroup", @"result", nil];
                [Flurry logEvent:@"SUBMIT" withParameters:dictionary];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Select Fangroup" message:myerror.message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                if (!self.fanViewController) {
                    self.fanViewController = [[IPFanViewController alloc] initWithNibName:@"IPFanViewController" bundle:nil];
                    self.fanViewController.game = self.game;
                }
                if (self.fanViewController)
                    [self.navigationController pushViewController:self.fanViewController animated:YES];
            } else {
                NSString *errorString = [NSString stringWithFormat:@"%d", (int)myerror.code];
                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.game.name,
                                        @"gameName", @"Fail", @"result", errorString, @"error", nil];
                [Flurry logEvent:@"SUBMIT" withParameters:dictionary];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Failed" message:myerror.message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];

}

- (void)postBank:(Selection *)selection
{
    
    self.isLoading = YES;

    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"game/period/bank?period_id=%d", selection.periodID];
    [objectManager postObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        selection.bank = YES;
        self.isUpdated = YES;
        self.isLoading = NO;
        [self getPeriods:self];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.game.name,
                                    @"gameName", selection.potentialPoints, @"potentialPoints", @"Success", @"result", nil];
        [Flurry logEvent:@"BANK" withParameters:dictionary];
        [TSMessage showNotificationInViewController:self
                                              title:@"Bank Successful"
                                           subtitle:@"Your selection has been banked."
                                              image:nil
                                               type:TSMessageNotificationTypeSuccess
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:nil
                                         atPosition:TSMessageNotificationPositionTop
                                canBeDismisedByUser:YES];
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bank Successful" message:@"You have successfully banked your selection!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
         */
        
   } failure:^(RKObjectRequestOperation *operation, NSError *error){
       self.isLoading = NO;
       NSArray *errorMessages = [[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey];
       Error *myerror = [errorMessages objectAtIndex:0];
       if (!myerror.message)
           myerror.message = @"Please try again later!";
       NSString *errorString = [NSString stringWithFormat:@"%d", (int)myerror.code];
       NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.game.name,
                                   @"gameName", selection.potentialPoints, @"potentialPoints", @"Fail", @"result", errorString, @"error", nil];
       [Flurry logEvent:@"BANK" withParameters:dictionary];
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
    if (theGame) {
        self.title = theGame.name;
    }
    [self.tableView setAlwaysBounceVertical:YES];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-only.png"]];
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
    [self.submitButton setEnabled:NO];
    
    self.dataController = [[GameDataController alloc] init];
    fanViewController = nil;
    leaderboardViewController = nil;
    registerViewController = nil;
    tutorialViewController = nil;
    selectedRow = 0;
    if (self.game.type >= 30) {
        UINib *nib = [UINib nibWithNibName:@"IPGameItemCell" bundle:nil];
        [[self tableView] registerNib:nib forCellReuseIdentifier:@"IPGameItemCell"];
    } else {
        UINib *nib = [UINib nibWithNibName:@"IPGameItemCell2" bundle:nil];
        [[self tableView] registerNib:nib forCellReuseIdentifier:@"IPGameItemCell2"];
    }
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh" attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0]}];
    refresh.tintColor = [UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
}

- (void) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) pushLeaderboard:(id)sender {
    if (!self.leaderboardViewController) {
        self.leaderboardViewController = [[IPLeaderboardViewController alloc] initWithNibName:@"IPLeaderboardViewController" bundle:nil];
        self.leaderboardViewController.game = self.game;
    }
    if (self.leaderboardViewController)
        [self.navigationController pushViewController:self.leaderboardViewController animated:YES];
}


- (void) tutorialPressed:(id)sender {
    if (!self.tutorialViewController) {
        self.tutorialViewController = [[IPTutorialViewController alloc] initWithNibName:@"IPTutorialViewController" bundle:nil];
    }
    if (self.tutorialViewController)
        [self.navigationController pushViewController:self.tutorialViewController animated:YES];
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
    
    NSString *stateString = [NSString stringWithFormat:@"%d", (int)self.game.state];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.game.name,
                                @"gameName", stateString, @"state", nil];
    [Flurry logEvent:@"GAME" withParameters:dictionary];
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
        // Custom initialization
    }
    return self;
}

- (UIView *)headerView
{
    if (!headerView) {
        [[NSBundle mainBundle] loadNibNamed:@"IPGameHeaderView" owner:self options:nil];
    
    switch (self.game.type) {
        case (HOMEDRAWAWAY): {
            selectionHeader1.text = @"HOME";
            selectionHeader2.text = @"DRAW";
            selectionHeader3.text = @"AWAY";
            selectionLabel0 = @"HOME";
            selectionLabel1 = @"DRAW";
            selectionLabel2 = @"AWAY";
            break;
        }
        case (TOP10): {
            selectionHeader1.text = @"LEAD";
            selectionHeader2.text = @"2-10";
            selectionHeader3.text = @"11+";
            selectionLabel0 = @"LEAD";
            selectionLabel1 = @"2-10";
            selectionLabel2 = @"11+";
            break;
        }
        case (TOP5): {
            selectionHeader1.text = @"LEAD";
            selectionHeader2.text = @"2-5";
            selectionHeader3.text = @"6+";
            selectionLabel0 = @"LEAD";
            selectionLabel1 = @"2-5";
            selectionLabel2 = @"6+";
            break;
        }
        case (TOP3): {
            selectionHeader1.text = @"WIN";
            selectionHeader2.text = @"2-3";
            selectionHeader3.text = @"4+";
            selectionLabel0 = @"WIN";
            selectionLabel1 = @"2-3";
            selectionLabel2 = @"4+";
            break;
        }
        case (LEADTHRUCUT): {
            selectionHeader1.text = @"LEAD";
            selectionHeader2.text = @"THRU";
            selectionHeader3.text = @"CUT";
            selectionLabel0 = @"LEAD";
            selectionLabel1 = @"THRU";
            selectionLabel2 = @"CUT";
            break;
        }
        case (ZEROONETWO): {
            selectionHeader1.text = @"0";
            selectionHeader2.text = @"1";
            selectionHeader3.text = @"2+";
            selectionLabel0 = @"0";
            selectionLabel1 = @"1";
            selectionLabel2 = @"2+";
            break;
        }
        case (WINAB): {
            selectionHeader4.text = @"WIN A";
            selectionHeader5.text = @"WIN B";
            selectionLabel0 = @"WIN A";
            selectionLabel1 = @"WIN B";
            selectionLabel2 = @" ";
            break;
        }
        case (UPDOWN): {
            selectionHeader4.text = @"+";
            selectionHeader5.text = @"-/0";
            selectionLabel0 = @"+";
            selectionLabel1 = @"-/0";
            selectionLabel2 = @" ";
            break;
        }
        case (THRUCUT): {
            selectionHeader4.text = @"THRU";
            selectionHeader5.text = @"CUT";
            selectionLabel0 = @"THRU";
            selectionLabel1 = @"CUT";
            selectionLabel2 = @" ";
            break;
        }
        case (YESNO): {
            selectionHeader4.text = @"YES";
            selectionHeader5.text = @"NO";
            selectionLabel0 = @"YES";
            selectionLabel1 = @"NO";
            selectionLabel2 = @" ";
            break;
        }
        case (OVERUNDER): {
            selectionHeader4.text = @"OVER";
            selectionHeader5.text = @"UNDER";
            selectionLabel0 = @"OVER";
            selectionLabel1 = @"UNDER";
            selectionLabel2 = @" ";
            break;
        }
        default: {
            selectionHeader4.text = @"WIN A";
            selectionHeader5.text = @"WIN B";
            selectionLabel0 = @"WIN A";
            selectionLabel1 = @"WIN B";
            selectionLabel2 = @" ";
            break;
        }
    }
    
    selectionHeader1.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
    selectionHeader2.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
    selectionHeader3.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
    selectionHeader4.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
    selectionHeader5.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
    [selectionLabel0 sizeWithFont: [UIFont fontWithName:@"Avalon-Demi" size:12.0]];
    [selectionLabel1 sizeWithFont: [UIFont fontWithName:@"Avalon-Demi" size:12.0]];
    [selectionLabel2 sizeWithFont: [UIFont fontWithName:@"Avalon-Demi" size:12.0]];
    
    UIImage *segmentSelected = [UIImage imageNamed:@"segcontrol_sel.png"];
    UIImage *segmentUnselected = [UIImage imageNamed:@"segcontrol_uns.png"];
    UIImage *segmentSelectedUnselected = [UIImage imageNamed:@"segcontrol_sel-uns.png"];
    UIImage *segUnselectedSelected = [UIImage imageNamed:@"segcontrol_uns-sel.png"];
    UIImage *segmentUnselectedUnselected = [UIImage imageNamed:@"segcontrol_uns-uns.png"];
    
    [pointsButton setBackgroundImage:segmentUnselected forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [pointsButton setBackgroundImage:segmentSelected forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [pointsButton setDividerImage:segmentUnselectedUnselected
              forLeftSegmentState:UIControlStateNormal
                rightSegmentState:UIControlStateNormal
                    barMetrics:UIBarMetricsDefault];
    [pointsButton setDividerImage:segmentSelectedUnselected
              forLeftSegmentState:UIControlStateSelected
                rightSegmentState:UIControlStateNormal
                    barMetrics:UIBarMetricsDefault];
    [pointsButton setDividerImage:segUnselectedSelected 
              forLeftSegmentState:UIControlStateNormal 
                rightSegmentState:UIControlStateSelected 
                    barMetrics:UIBarMetricsDefault];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Avalon-Demi" size:14.0],UITextAttributeFont,[UIColor whiteColor],UITextAttributeTextColor,nil];
    [pointsButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [pointsButton setTitleTextAttributes:attributes forState:UIControlStateSelected];
        
    self.leftLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
    self.rightLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
    UIImage *image = [UIImage imageNamed: @"green_dot.png"];
    [self.inplayIndicator setImage:image];
    }
    
     if ((self.game.state == INPLAY) || (self.game.state == SUSPENDED)) {
         [self.inplayIndicator setHidden:NO];
     } else {
         [self.inplayIndicator setHidden:YES];
     }

    [self changePoints:self];
    return headerView;
}

- (UIView *)footerView
{
    if (!footerView) {
        [[NSBundle mainBundle] loadNibNamed:@"IPGameFooterView" owner:self options:nil];

    
        UIImage *image = [UIImage imageNamed:@"submit-button.png"];
        UIImage *image2 = [UIImage imageNamed:@"submit-button-hit-state.png"];
        UIImage *image3 = [UIImage imageNamed:@"grey-button.png"];
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
            if (([self.dataController.points.winnings isEqualToString:@"-"]) || (!self.dataController.points.winnings)) {
                [self.submitButton setTitle:@"COMPLETE" forState:UIControlStateNormal];
                [self.submitButton setTitle:@"COMPLETE" forState:UIControlStateDisabled];
            } else if ([self.dataController.points.winnings isEqualToString:@"$0"]) {
                [self.submitButton setTitle:@"NO WINNINGS!" forState:UIControlStateNormal];
                [self.submitButton setTitle:@"NO WINNINGS!" forState:UIControlStateDisabled];
            } else {
                NSString *winnings;
                winnings = [@"YOU WON " stringByAppendingString:self.dataController.points.winnings];
                winnings = [winnings stringByAppendingString:@"!"];
                [self.submitButton setTitle:winnings forState:UIControlStateNormal];
                [self.submitButton setTitleColor:[UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                [self.submitButton setTitle:winnings forState:UIControlStateDisabled];
                [self.submitButton setTitleColor:[UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0] forState:UIControlStateDisabled];
            }
            [self.submitButton setEnabled:NO];
            break;
        case (NEVERINPLAY):
        case (INPLAY):
            if (self.dataController.userState == NOTSUBMITTED) {
                [self.submitButton setTitle:@"SUBMIT" forState:UIControlStateNormal];
            } else {
                [self.submitButton setTitle:@"UPDATE" forState:UIControlStateNormal];
            }
            BOOL preplayPeriodExists = NO;
            for (int i=0; i < [self.dataController countOfPeriodList]; i++) {
                Period *period = [self.dataController objectInPeriodListAtIndex:i];
                if (period.state == PREPLAY)
                    preplayPeriodExists = YES;
            }
            if (preplayPeriodExists) {
                [self.submitButton setEnabled:YES];
            } else {
                [self.submitButton setEnabled:NO];
            }
            break;
        case (TRANSITION):
        case (PREPLAY):
            if (self.dataController.userState == NOTSUBMITTED) {
                [self.submitButton setTitle:@"SUBMIT" forState:UIControlStateNormal];
            } else {
                [self.submitButton setTitle:@"UPDATE" forState:UIControlStateNormal];
            }
            if (self.isLoaded)
                [self.submitButton setEnabled:YES];
            else
                [self.submitButton setEnabled:NO];
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
    
    if (self.dataController.userState == SUBMITTED) {
            UIImage *leaderboardButtonNormal = [UIImage imageNamed:@"leaderboard-button.png"];
            UIImage *leaderboardButtonHighlighted = [UIImage imageNamed:@"leaderboard-button-hit-state.png"];
            CGRect frameimg = CGRectMake(0, 0, leaderboardButtonNormal.size.width, leaderboardButtonNormal.size.height);
            UIButton *leaderboardButton = [[UIButton alloc] initWithFrame:frameimg];
            [leaderboardButton setBackgroundImage:leaderboardButtonNormal forState:UIControlStateNormal];
            [leaderboardButton setBackgroundImage:leaderboardButtonHighlighted forState:UIControlStateHighlighted];
            [leaderboardButton addTarget:self action:@selector(pushLeaderboard:)
             forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *barButtonItem =[[UIBarButtonItem alloc] initWithCustomView:leaderboardButton];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
                negativeSpacer.width = -10;
                [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, barButtonItem, nil]];
            } else {
                self.navigationItem.rightBarButtonItem = barButtonItem;
            }
    } else {
        if (!self.navigationItem.rightBarButtonItem) {
            /*
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tutorial" style:UIBarButtonItemStylePlain target:self action:@selector(tutorialPressed:)];
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0];
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0],UITextAttributeFont,nil];
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
             */
            UIImage *tutorialButtonNormal = [UIImage imageNamed:@"tutorial-button.png"];
            UIImage *tutorialButtonHighlighted = [UIImage imageNamed:@"tutorial-button-hit-state.png"];
            CGRect frameimg = CGRectMake(0, 0, tutorialButtonNormal.size.width, tutorialButtonNormal.size.height);
            UIButton *tutorialButton = [[UIButton alloc] initWithFrame:frameimg];
            [tutorialButton setBackgroundImage:tutorialButtonNormal forState:UIControlStateNormal];
            [tutorialButton setBackgroundImage:tutorialButtonHighlighted forState:UIControlStateHighlighted];
            [tutorialButton addTarget:self action:@selector(tutorialPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *barButtonItem =[[UIBarButtonItem alloc] initWithCustomView:tutorialButton];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
                negativeSpacer.width = -10;
                [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, barButtonItem, nil]];
            } else {
                self.navigationItem.rightBarButtonItem = barButtonItem;
            }
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
        /*
        for (int j=0; j < [self.dataController.points.periodSelections count]; j++) {
            Selection *periodSelection = [self.dataController.points.periodSelections objectAtIndex:j];
            if (period.periodID == periodSelection.periodID) {
                periodSelection.row = i;
                break;
            }
        }
        */
    }
    NSSortDescriptor *primary = [NSSortDescriptor sortDescriptorWithKey:@"row" ascending:YES];
    [self.dataController.selectionList sortUsingDescriptors:@[primary]];
    // [self.dataController.points.periodSelections sortUsingDescriptors:@[primary]];
    
    /*
    for (int i=0; i < [self.dataController.periodList count]; i++) {
        Period *period = [self.dataController.periodList objectAtIndex:i];
        Selection *selection = [self.dataController.selectionList objectAtIndex:i];
        Selection *selection2 = [self.dataController.points.periodSelections objectAtIndex:i];
        NSLog (@"periodID = %d %d %d", period.periodID, selection.periodID, selection2.periodID);
    }
    */
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
    
    IPGameItemCell *cell;
    if (self.game.type < 30)
        cell = [tableView dequeueReusableCellWithIdentifier:@"IPGameItemCell2"];
    else
        cell = [tableView dequeueReusableCellWithIdentifier:@"IPGameItemCell"];
    
    [cell setController:self];
    [cell setTableView:tableView];
    
    
    // generic stuff for all states
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-row.png"]];
    cell.backgroundView = imageView;
    [[cell periodLabel] setText:periodAtIndex.name];
    cell.periodLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    cell.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    cell.pointsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:29.0/255.0 green:28.0/255.0 blue:27.0/255.0 alpha:1.0],UITextAttributeTextColor,[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0],UITextAttributeFont,[NSValue valueWithUIOffset:UIOffsetMake(0.0,0.0)],UITextAttributeTextShadowOffset,nil];
    [[cell selectionButton] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [[cell selectionButton] setTitleTextAttributes:attributes forState:UIControlStateDisabled];
    UIImage *segmentSelected = [UIImage imageNamed:@"gamecontrol_sel.png"];
    UIImage *segmentUnselected = [UIImage imageNamed:@"gamecontrol_uns.png"];
    UIImage *segmentSelectedUnselected = [UIImage imageNamed:@"gamecontrol_sel-uns.png"];
    UIImage *segmentUnselectedSelected = [UIImage imageNamed:@"gamecontrol_uns-sel.png"];
    UIImage *segmentUnselectedUnselected = [UIImage imageNamed:@"gamecontrol_uns-uns.png"];
    UIImage *segmentSelectedSelected = [UIImage imageNamed:@"gamecontrol_sel-sel.png"];
    UIImage *segmentDisabled = [UIImage imageNamed:@"discontrol_uns.png"];
    UIImage *segmentDisabledDisabled = [UIImage imageNamed:@"discontrol_uns-uns.png"];
    
    [[cell selectionButton] setBackgroundImage:segmentUnselected forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[cell selectionButton] setBackgroundImage:segmentSelected forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [[cell selectionButton] setBackgroundImage:segmentSelected forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [[cell selectionButton] setBackgroundImage:segmentDisabled forState:UIControlStateDisabled barMetrics:UIBarMetricsDefault];
    
    [[cell selectionButton] setDividerImage:segmentUnselectedUnselected
        forLeftSegmentState:UIControlStateNormal
        rightSegmentState:UIControlStateNormal
        barMetrics:UIBarMetricsDefault];
    [[cell selectionButton] setDividerImage:segmentSelectedUnselected
        forLeftSegmentState:UIControlStateSelected
        rightSegmentState:UIControlStateNormal
        barMetrics:UIBarMetricsDefault];
    [[cell selectionButton] setDividerImage:segmentUnselectedSelected
        forLeftSegmentState:UIControlStateNormal
        rightSegmentState:UIControlStateSelected
        barMetrics:UIBarMetricsDefault];
    [[cell selectionButton] setDividerImage:segmentSelectedSelected
                        forLeftSegmentState:UIControlStateSelected
                          rightSegmentState:UIControlStateHighlighted
                                 barMetrics:UIBarMetricsDefault];
    [[cell selectionButton] setDividerImage:segmentUnselectedSelected
                        forLeftSegmentState:UIControlStateNormal
                          rightSegmentState:UIControlStateHighlighted
                                 barMetrics:UIBarMetricsDefault];
    [[cell selectionButton] setDividerImage:segmentSelectedSelected
                        forLeftSegmentState:UIControlStateHighlighted
                          rightSegmentState:UIControlStateSelected
                                 barMetrics:UIBarMetricsDefault];
    [[cell selectionButton] setDividerImage:segmentSelectedUnselected
                        forLeftSegmentState:UIControlStateHighlighted
                          rightSegmentState:UIControlStateNormal
                                 barMetrics:UIBarMetricsDefault];
    
    [[cell selectionButton] setDividerImage:segmentDisabledDisabled forLeftSegmentState:UIControlStateDisabled rightSegmentState:UIControlStateDisabled barMetrics:UIBarMetricsDefault];
    
    // state specific stuff
    switch (self.game.state) {
        case (TRANSITION):
        case (PREPLAY):  {  // game state
            [[cell timeLabel] setText:periodAtIndex.startDate];
            cell.periodLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
            cell.timeLabel.textColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
           
            if (cell.selectionButton.numberOfSegments == 3) {
                [[cell selectionButton] setTitle:periodAtIndex.points0 forSegmentAtIndex:0];
                [[cell selectionButton] setTitle:periodAtIndex.points1 forSegmentAtIndex:1];
                [[cell selectionButton] setTitle:periodAtIndex.points2 forSegmentAtIndex:2];
            } else if (cell.selectionButton.numberOfSegments == 2) {
                [[cell selectionButton] setTitle:periodAtIndex.points0 forSegmentAtIndex:0];
                [[cell selectionButton] setTitle:periodAtIndex.points1 forSegmentAtIndex:1];
            }
            [[cell selectionButton] setSelectedSegmentIndex:selectionAtIndex.selection];
            if (self.dataController.userState == SUBMITTED) {
                [[cell pointsLabel] setText:selectionAtIndex.potentialPoints];
                [[cell pointsLabel] setTextColor:[UIColor whiteColor]];
            }
            if ((periodAtIndex.state == INACTIVE) || (periodAtIndex.state == SUSPENDED))
                [cell.selectionButton setEnabled:NO];
            else
                [cell.selectionButton setEnabled:YES];
            break;
        }
        case (NEVERINPLAY):
        case (SUSPENDED):
        case (INPLAY):  // game state
            switch (periodAtIndex.state) {
                case (TRANSITION):
                case (PREPLAY): {  // period state
                    [[cell timeLabel] setText:periodAtIndex.startDate];
                    cell.periodLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
                    cell.timeLabel.textColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
                    
                    [[cell selectionButton] setSelectedSegmentIndex:-1];
                    if (cell.selectionButton.numberOfSegments == 3) {
                        [[cell selectionButton] setTitle:periodAtIndex.points0 forSegmentAtIndex:0];
                        [[cell selectionButton] setTitle:periodAtIndex.points1 forSegmentAtIndex:1];
                        [[cell selectionButton] setTitle:periodAtIndex.points2 forSegmentAtIndex:2];
                    } else if (cell.selectionButton.numberOfSegments == 2) {
                        [[cell selectionButton] setTitle:periodAtIndex.points0 forSegmentAtIndex:0];
                        [[cell selectionButton] setTitle:periodAtIndex.points1 forSegmentAtIndex:1];
                    } else if (cell.selectionButton.numberOfSegments == 1) {
                        [[cell selectionButton] setTitle:periodAtIndex.points0 forSegmentAtIndex:0];
                        if (self.game.type >=30) {
                            [[cell selectionButton] insertSegmentWithTitle:periodAtIndex.points1 atIndex:1 animated:NO];
                            [[cell selectionButton] insertSegmentWithTitle:periodAtIndex.points2 atIndex:2 animated:NO];
                        } else {
                            [[cell selectionButton] insertSegmentWithTitle:periodAtIndex.points1 atIndex:1 animated:NO];
                        }
                    }
                    [[cell pointsLabel] setText:@" "];
                    [[cell inplayIcon] setHidden:YES];
                    [cell.selectionButton setEnabled:YES];
                    [[cell selectionButton] setSelectedSegmentIndex:selectionAtIndex.selection];
                    if (self.dataController.userState == SUBMITTED) {
                        [[cell pointsLabel] setText:selectionAtIndex.potentialPoints];
                        [[cell pointsLabel] setTextColor:[UIColor whiteColor]];
                    }
                    break;
                }
                case (NEVERINPLAY):
                case (SUSPENDED):
                case (INPLAY): { // period state
                    NSString *subline = [periodAtIndex.elapsedTime stringByAppendingString:@" "];
                    subline = [subline stringByAppendingString:periodAtIndex.score];
                    [[cell timeLabel] setText:subline];
                    cell.periodLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
                    cell.timeLabel.textColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
                    UIImage *image = [UIImage imageNamed: @"green_dot.png"];
                    [[cell inplayIcon] setImage:image];
                    [[cell inplayIcon] setHidden:NO];
                    
                    if (periodAtIndex.state == NEVERINPLAY) {
                        NSString *inplay;
                        if (selectionAtIndex.selection == 0)
                            inplay = [@"INPLAY: " stringByAppendingString:selectionLabel0];
                        else if (selectionAtIndex.selection == 1)
                            inplay = [@"INPLAY: " stringByAppendingString:selectionLabel1];
                        else if (selectionAtIndex.selection == 2)
                            inplay = [@"INPLAY: " stringByAppendingString:selectionLabel2];
                        else
                            inplay = @"INPLAY";
                        [[cell selectionButton] setTitle:inplay forSegmentAtIndex:0];
                        NSDictionary *black = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:29.0/255.0 green:28.0/255.0 blue:27.0/255.0 alpha:1.0],UITextAttributeTextColor,nil];
                        [[cell selectionButton] setTitleTextAttributes:black forState:UIControlStateDisabled];
                        [[cell selectionButton] removeSegmentAtIndex:2 animated:NO];
                        [[cell selectionButton] removeSegmentAtIndex:1 animated:NO];
                        [[cell selectionButton] setSelectedSegmentIndex:-1];
                        UIImage *bankSelected = [UIImage imageNamed:@"neverinplay.png"];
                        [[cell selectionButton] setBackgroundImage:bankSelected forState:UIControlStateDisabled barMetrics:UIBarMetricsDefault];
                        [cell.selectionButton setEnabled:NO];
                        if (self.dataController.userState == SUBMITTED) {
                            [[cell pointsLabel] setText:selectionAtIndex.potentialPoints];
                            [[cell pointsLabel] setTextColor:[UIColor whiteColor]];
                        }
                    } else if (selectionAtIndex.bank == NO) {
                        NSString *bank;
                        if (selectionAtIndex.selection == 0) {
                            bank = [periodAtIndex.points0 stringByAppendingString:@" BANK: "];
                            bank = [bank stringByAppendingString:selectionLabel0];
                        } else if (selectionAtIndex.selection == 1) {
                            bank = [periodAtIndex.points1 stringByAppendingString:@" BANK: "];
                            bank = [bank stringByAppendingString:selectionLabel1];
                        } else if (selectionAtIndex.selection == 2) {
                            bank = [periodAtIndex.points2 stringByAppendingString:@" BANK: "];
                            bank = [bank stringByAppendingString:selectionLabel2];
                        } else {
                            bank = @"BANK";
                        }
                        [[cell selectionButton] setTitle:bank forSegmentAtIndex:0];
                        NSDictionary *black = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:29.0/255.0 green:28.0/255.0 blue:27.0/255.0 alpha:1.0],UITextAttributeTextColor,nil];
                        [[cell selectionButton] setTitleTextAttributes:black forState:UIControlStateDisabled];
                        [[cell selectionButton] removeSegmentAtIndex:2 animated:NO];
                        [[cell selectionButton] removeSegmentAtIndex:1 animated:NO];
                        [[cell selectionButton] setSelectedSegmentIndex:-1];
                        UIImage *bankNormal = [UIImage imageNamed:@"bank-normal.png"];
                        UIImage *bankSelected = [UIImage imageNamed:@"bank-select.png"];
                        [[cell selectionButton] setBackgroundImage:bankNormal forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
                        [[cell selectionButton] setBackgroundImage:bankSelected forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
                        [[cell selectionButton] setBackgroundImage:bankSelected forState:UIControlStateDisabled barMetrics:UIBarMetricsDefault];
                        if (self.dataController.userState == SUBMITTED) {
                            [cell.selectionButton setEnabled:YES];
                            [[cell pointsLabel] setText:selectionAtIndex.potentialPoints];
                            [[cell pointsLabel] setTextColor:[UIColor whiteColor]];
                        } else {
                            [cell.selectionButton setEnabled:NO];
                        }
                        if ((periodAtIndex.state == SUSPENDED) || (selectionAtIndex.selection == -1))
                            [cell.selectionButton setEnabled:NO];
                    } else {
                        NSString *bank;
                        if (selectionAtIndex.selection == 0)
                            bank = [@"BANKED: " stringByAppendingString:selectionLabel0];
                        else if (selectionAtIndex.selection == 1)
                            bank = [@"BANKED: " stringByAppendingString:selectionLabel1];
                        else if (selectionAtIndex.selection == 2)
                            bank = [@"BANKED: " stringByAppendingString:selectionLabel2];
                        else
                            bank = @" ";
                        [[cell selectionButton] setTitle:bank forSegmentAtIndex:0];
                        NSDictionary *green = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:75.0/255.0 green:209.0/255.0 blue:3.0/255.0 alpha:1.0],UITextAttributeTextColor,nil];
                        [[cell selectionButton] setTitleTextAttributes:green forState:UIControlStateDisabled];
                        [[cell selectionButton] removeSegmentAtIndex:2 animated:NO];
                        [[cell selectionButton] removeSegmentAtIndex:1 animated:NO];
                        [[cell selectionButton] setEnabled:NO];
                        [[cell selectionButton] setSelectedSegmentIndex:-1];
                        if (self.dataController.userState == SUBMITTED) {
                            [[cell pointsLabel] setText:selectionAtIndex.awardedPoints];
                            if ([selectionAtIndex.awardedPoints isEqualToString:@"0"]) {
                                [[cell pointsLabel] setTextColor:[UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0]];
                            } else {
                                [[cell pointsLabel] setTextColor:[UIColor colorWithRed:75.0/255.0 green:209.0/255.0 blue:3.0/255.0 alpha:1.0]];
                            }
                        }
                    }
                    break;
                }
                case (COMPLETED):  // period state
                default: {
                    UIImageView *completedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"completed-row.png"]];
                    cell.backgroundView = completedView;
                    NSString *subline = [periodAtIndex.elapsedTime stringByAppendingString:@" "];
                    subline = [subline stringByAppendingString:periodAtIndex.score];
                    [[cell timeLabel] setText:subline];
                    cell.periodLabel.textColor = [UIColor darkGrayColor];
                    cell.timeLabel.textColor = [UIColor darkGrayColor];
                    [[cell selectionButton] setSelectedSegmentIndex:-1];
                    
                    if (selectionAtIndex.bank == YES) {
                        NSString *bank;
                        if (selectionAtIndex.selection == 0)
                            bank = [@"BANKED: " stringByAppendingString:selectionLabel0];
                        else if (selectionAtIndex.selection == 1)
                            bank = [@"BANKED: " stringByAppendingString:selectionLabel1];
                        else if (selectionAtIndex.selection == 2)
                            bank = [@"BANKED: " stringByAppendingString:selectionLabel2];
                        else
                            bank = @" ";
                        [[cell selectionButton] setTitle:bank forSegmentAtIndex:0];
                        NSDictionary *green = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:75.0/255.0 green:209.0/255.0 blue:3.0/255.0 alpha:1.0],UITextAttributeTextColor,[UIFont fontWithName:@"Avalon-Demi" size:12.0],UITextAttributeFont,nil];
                        [[cell selectionButton] setTitleTextAttributes:green forState:UIControlStateDisabled];
                        [[cell selectionButton] removeSegmentAtIndex:2 animated:NO];
                        [[cell selectionButton] removeSegmentAtIndex:1 animated:NO];
                    } else { // bank == NO
                        if (cell.selectionButton.numberOfSegments == 1) {
                            [[cell selectionButton] setTitle:@" " forSegmentAtIndex:0];
                            if (self.game.type >=30) {
                                [[cell selectionButton] insertSegmentWithTitle:@" " atIndex:1 animated:NO];
                                [[cell selectionButton] insertSegmentWithTitle:@" " atIndex:2 animated:NO];
                            } else {
                                [[cell selectionButton] insertSegmentWithTitle:@" " atIndex:1 animated:NO];
                            }
                        } else if (cell.selectionButton.numberOfSegments == 2) {
                            [[cell selectionButton] setTitle:@" " forSegmentAtIndex:0];
                            [[cell selectionButton] setTitle:@" " forSegmentAtIndex:1];
                        } else if (cell.selectionButton.numberOfSegments == 3) {
                            [[cell selectionButton] setTitle:@" " forSegmentAtIndex:0];
                            [[cell selectionButton] setTitle:@" " forSegmentAtIndex:1];
                            [[cell selectionButton] setTitle:@" " forSegmentAtIndex:2];
                            
                        }
                        if (selectionAtIndex.selection == 0) {
                            if (periodAtIndex.result == 0) {
                                [[cell selectionButton] setImage:[UIImage imageNamed:@"tick.png"] forSegmentAtIndex:0];
                                [[cell selectionButton] setTintColor:[UIColor greenColor]];
                            } else {
                                [[cell selectionButton] setImage:[UIImage imageNamed:@"cross.png"] forSegmentAtIndex:0];
                                [[cell selectionButton] setTintColor:[UIColor redColor]];
                            }
                        } else if (selectionAtIndex.selection == 1) {
                            if (periodAtIndex.result == 1) {
                                [[cell selectionButton] setImage:[UIImage imageNamed:@"tick.png"] forSegmentAtIndex:1];
                                [[cell selectionButton] setTintColor:[UIColor greenColor]];
                            } else {
                                [[cell selectionButton] setImage:[UIImage imageNamed:@"cross.png"] forSegmentAtIndex:1];
                                [[cell selectionButton] setTintColor:[UIColor redColor]];
                            }
                        } else if ((selectionAtIndex.selection == 2) && (cell.selectionButton.numberOfSegments >2)) {
                            if (periodAtIndex.result == 2) {
                                [[cell selectionButton] setImage:[UIImage imageNamed:@"tick.png"] forSegmentAtIndex:2];
                                [[cell selectionButton] setTintColor:[UIColor greenColor]];
                            } else {
                                [[cell selectionButton] setImage:[UIImage imageNamed:@"cross.png"] forSegmentAtIndex:2];
                                [[cell selectionButton] setTintColor:[UIColor redColor]];
                            }
                        }
                        /*
                        NSDictionary *green = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:75.0/255.0 green:209.0/255.0 blue:3.0/255.0 alpha:1.0],UITextAttributeTextColor,[UIFont fontWithName:@"Avalon-Demi" size:12.0],UITextAttributeFont,nil];
                        NSDictionary *red = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0],UITextAttributeTextColor,[UIFont fontWithName:@"Avalon-Demi" size:12.0],UITextAttributeFont,nil];
                        if (selectionAtIndex.selection == 0) {
                            [[cell selectionButton] setTitle:selectionLabel0 forSegmentAtIndex:0];
                            if (periodAtIndex.result == 0)
                                [[cell selectionButton] setTitleTextAttributes:green forState:UIControlStateDisabled];
                            else
                                [[cell selectionButton] setTitleTextAttributes:red forState:UIControlStateDisabled];
                        } else if (selectionAtIndex.selection == 1) {
                            [[cell selectionButton] setTitle:selectionLabel1 forSegmentAtIndex:1];
                            if (periodAtIndex.result == 1)
                                [[cell selectionButton] setTitleTextAttributes:green forState:UIControlStateDisabled];
                            else
                                [[cell selectionButton] setTitleTextAttributes:red forState:UIControlStateDisabled];
                        } else if ((selectionAtIndex.selection == 2) && (cell.selectionButton.numberOfSegments >2)) {
                            [[cell selectionButton] setTitle:selectionLabel2 forSegmentAtIndex:2];
                            if (periodAtIndex.result == 2)
                                [[cell selectionButton] setTitleTextAttributes:green forState:UIControlStateDisabled];
                            else
                                [[cell selectionButton] setTitleTextAttributes:red forState:UIControlStateDisabled];
                        }
                         */
                    }
                    
                    [[cell selectionButton] setEnabled:NO];
                    [[cell inplayIcon] setHidden:YES];
                    
                    if (self.dataController.userState == SUBMITTED) {
                        [[cell pointsLabel] setText:selectionAtIndex.awardedPoints];
                        if ([selectionAtIndex.awardedPoints isEqualToString:@"0"]) {
                            [[cell pointsLabel] setTextColor:[UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0]];
                        } else {
                            [[cell pointsLabel] setTextColor:[UIColor colorWithRed:75.0/255.0 green:209.0/255.0 blue:3.0/255.0 alpha:1.0]];
                        }
                    }
                    break;
                }
            }
            break;
        case (COMPLETED):  // game state
        default: {
            UIImageView *completedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"completed-row.png"]];
            cell.backgroundView = completedView;
            [[cell timeLabel] setText:periodAtIndex.score];
            cell.periodLabel.textColor = [UIColor darkGrayColor];
            cell.timeLabel.textColor = [UIColor darkGrayColor];
            [[cell selectionButton] setSelectedSegmentIndex:-1];
            
            if (selectionAtIndex.bank == YES) {
                NSString *bank;
                if (selectionAtIndex.selection == 0)
                    bank = [@"BANKED: " stringByAppendingString:selectionLabel0];
                else if (selectionAtIndex.selection == 1)
                    bank = [@"BANKED: " stringByAppendingString:selectionLabel1];
                else if (selectionAtIndex.selection == 2)
                    bank = [@"BANKED: " stringByAppendingString:selectionLabel2];
                else
                    bank = @" ";
                [[cell selectionButton] setTitle:bank forSegmentAtIndex:0];
                NSDictionary *green = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:75.0/255.0 green:209.0/255.0 blue:3.0/255.0 alpha:1.0],UITextAttributeTextColor,[UIFont fontWithName:@"Avalon-Demi" size:12.0],UITextAttributeFont,nil];
                [[cell selectionButton] setTitleTextAttributes:green forState:UIControlStateDisabled];
                [[cell selectionButton] removeSegmentAtIndex:2 animated:NO];
                [[cell selectionButton] removeSegmentAtIndex:1 animated:NO];
            } else { // bank == NO
                if (cell.selectionButton.numberOfSegments == 1) {
                    [[cell selectionButton] setTitle:@" " forSegmentAtIndex:0];
                    if (self.game.type >=30) {
                        [[cell selectionButton] insertSegmentWithTitle:@" " atIndex:1 animated:NO];
                        [[cell selectionButton] insertSegmentWithTitle:@" " atIndex:2 animated:NO];
                    } else {
                        [[cell selectionButton] insertSegmentWithTitle:@" " atIndex:1 animated:NO];
                    }
                } else if (cell.selectionButton.numberOfSegments == 2) {
                    [[cell selectionButton] setTitle:@" " forSegmentAtIndex:0];
                    [[cell selectionButton] setTitle:@" " forSegmentAtIndex:1];
                } else if (cell.selectionButton.numberOfSegments == 3) {
                    [[cell selectionButton] setTitle:@" " forSegmentAtIndex:0];
                    [[cell selectionButton] setTitle:@" " forSegmentAtIndex:1];
                    [[cell selectionButton] setTitle:@" " forSegmentAtIndex:2];
                }
                if (selectionAtIndex.selection == 0) {
                    if (periodAtIndex.result == 0) {
                        [[cell selectionButton] setImage:[UIImage imageNamed:@"tick.png"] forSegmentAtIndex:0];
                        [[cell selectionButton] setTintColor:[UIColor greenColor]];
                    } else {
                        [[cell selectionButton] setImage:[UIImage imageNamed:@"cross.png"] forSegmentAtIndex:0];
                        [[cell selectionButton] setTintColor:[UIColor redColor]];
                    }
                } else if (selectionAtIndex.selection == 1) {
                    if (periodAtIndex.result == 1) {
                        [[cell selectionButton] setImage:[UIImage imageNamed:@"tick.png"] forSegmentAtIndex:1];
                        [[cell selectionButton] setTintColor:[UIColor greenColor]];
                    } else {
                        [[cell selectionButton] setImage:[UIImage imageNamed:@"cross.png"] forSegmentAtIndex:1];
                        [[cell selectionButton] setTintColor:[UIColor redColor]];
                    }
                } else if ((selectionAtIndex.selection == 2) && (cell.selectionButton.numberOfSegments >2)) {
                    if (periodAtIndex.result == 2) {
                        [[cell selectionButton] setImage:[UIImage imageNamed:@"tick.png"] forSegmentAtIndex:2];
                        [[cell selectionButton] setTintColor:[UIColor greenColor]];
                    } else {
                        [[cell selectionButton] setImage:[UIImage imageNamed:@"cross.png"] forSegmentAtIndex:2];
                        [[cell selectionButton] setTintColor:[UIColor redColor]];
                    }
                }
            }
            
            [[cell selectionButton] setEnabled: NO];
            [[cell inplayIcon] setHidden:YES];
            if (self.dataController.userState == SUBMITTED) {
                [[cell pointsLabel] setText:selectionAtIndex.awardedPoints];
                if ([selectionAtIndex.awardedPoints isEqualToString:@"0"]) {
                    [[cell pointsLabel] setTextColor:[UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0]];
                } else {
                    [[cell pointsLabel] setTextColor:[UIColor colorWithRed:75.0/255.0 green:209.0/255.0 blue:3.0/255.0 alpha:1.0]];
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
    return [self headerView];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration required" message:@"Please register or login first!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                if (!self.registerViewController) {
                    self.registerViewController = [[IPRegisterViewController alloc] initWithNibName:@"IPRegisterViewController" bundle:nil];
                }
                if (self.registerViewController)
                    [self.navigationController pushViewController:self.registerViewController animated:YES];
                return;
            }
            /*
            if (self.game.state != PREPLAY) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game started" message:@"You can no longer join this game!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
             */
            if ((self.game.state == PREPLAY) || (self.game.state == TRANSITION)) {
                for (int i=0; i < self.dataController.countOfSelectionList; i++) {
                    Selection *selectionAtIndex = [self.dataController objectInSelectionListAtIndex:i];
                    if (selectionAtIndex.selection == -1) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing selections" message:@"Please pick all selections!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                
                }
            }
            [self postSelections];
            // self.dataController.userState = SUBMITTED;
            // [self refresh:self];
            break;
        case (SUBMITTED):
            if (appDelegate.loggedin == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login required" message:@"Please login first!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
            [self postSelections];
            // [self refresh:self];
            break;
    }
    
    
}


- (void)changeSelection:(id)sender atIndexPath:(NSIndexPath *)ip
{
    UISegmentedControl* segmentControl = sender;
    // NSLog(@"row=%@ index=%d", ip, segmentControl.selectedSegmentIndex);
    Selection *selectionAtIndex = [self.dataController objectInSelectionListAtIndex:ip.row];
    Period *periodAtIndex = [self.dataController objectInPeriodListAtIndex:ip.row];
    if (((periodAtIndex.state == INPLAY) || (periodAtIndex.state == SUSPENDED)) && (self.game.state != PREPLAY)) {
            IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
            if (appDelegate.loggedin == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login required" message:@"Please login first!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Bank" message:@"Are you sure you want to bank and take your points now?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
                alert.tag = CONFIRM_BANK;
                [alert show];
            }
            segmentControl.selectedSegmentIndex = -1;
            selectedRow = ip.row;
    } else {
        selectionAtIndex.selection = segmentControl.selectedSegmentIndex;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (alertView.tag) {
		case CONFIRM_BANK:
            switch (buttonIndex) {
				case 0: // cancel
				{
					// NSLog(@"Delete was cancelled by the user");
				}
					break;
				case 1: // confirm
				{
					// POST bank, if successful
                    Selection *selectionAtIndex = [self.dataController objectInSelectionListAtIndex:selectedRow];
                    [self postBank:selectionAtIndex];
                    // selectionAtIndex.bank = YES;
                    // [self refresh:self];
				}
					break;
			}
    }
}

- (IBAction)changePoints:(id)sender
{
    Points *points = self.dataController.points;
    switch (self.pointsButton.selectedSegmentIndex) {
        case (0):
            self.left = [points.globalPoints stringByAppendingFormat:@" points    %@/%@", points.globalRank, points.globalPoolSize];
            [self.leftLabel setText:self.left];
            [self.rightLabel setText:points.globalPot];
            break;
        case (1):
            if (points.lateEntry) {
                self.left = [points.fangroupName stringByAppendingString:@"    <Not Entered>"];
                [self.rightLabel setText:@""];
            } else {
                self.left = [points.fangroupName stringByAppendingFormat:@"    %@/%@", points.fangroupRank, points.numFangroups];
                [self.rightLabel setText:points.fangroupPot];
            }
            [self.leftLabel setText:self.left];
            break;
        case (2):
            if (points.lateEntry) {
                [self.leftLabel setText:@"<Not Entered>"];
                [self.rightLabel setText:@""];
            } else if (points.globalPoints) {
                self.left = [NSString stringWithFormat: @"%@ vs. %@ %@", points.globalPoints, points.h2hPoints, points.h2hUser];
                [self.leftLabel setText:self.left];
                [self.rightLabel setText:points.h2hPot];
            }
            break;

    }
    
}


@end
