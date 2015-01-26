//
//  IPLeaderboardViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 22/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPLeaderboardViewController.h"
#import "LeaderboardDataController.h"
#import "IPLeaderboardItemCell.h"
#import "Leaderboard.h"
#import "Points.h"
#import "Competition.h"
#import "Game.h"
#import "RestKit.h"
#import "IPAppDelegate.h"
#import "MFSideMenu.h"
#import "CompetitionPoints.h"
#import "Flurry.h"
#import "IPGameViewController.h"
#import "FriendPool.h"
#import "PoolPoints.h"
#import "IPAddFriendsViewController.h"
#import "IPFantasyViewController.h"
#import "IPStatsViewController.h"

#define FANTASY 40
#define QUIZ 100

#define COMPETITIONS 1
#define GAMES 2

#define GLOBAL 0
#define FANGROUP 1
#define FRIEND 2

#define SELECTBUTTON 0
#define LARGESTRANK 2000000000

enum State {
    PREPLAY=-1,
    TRANSITION=0,
    INPLAY=1,
    COMPLETED=2,
    SUSPENDED=3,
    NEVERINPLAY=4,
    ARCHIVED=5
};


@implementation IPLeaderboardViewController

@synthesize leftLabel, rightLabel, pointsButton, left, rankHeader, nameHeader, pointsHeader, winningsHeader, isLoading, inplayIndicator, controllerList, detailViewController, friendPool, competitionID, competitionName, addFriendsViewController, fromWinners, fantasyViewController, statsViewController, overallControllerList;


- (void) dealloc {
    self.navigationController.sideMenu.menuStateEventBlock = nil;
}

- (void)setLeaderboard:(Leaderboard *) newLeaderboard
{
    if (_leaderboard != newLeaderboard) {
        _leaderboard = newLeaderboard;
    }
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
    // Do any additional setup after loading the view from its nib.
    
    // this isn't needed on the rootViewController of the navigation controller
    [self.navigationController.sideMenu setupSideMenuBarButtonItem];
    
    // self.title = @"Leaderboard";
    self.dataController = [[LeaderboardDataController alloc] init];
    
    UINib *nib = [UINib nibWithNibName:@"IPLeaderboardItemCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"IPLeaderboardItemCell"];
    
    /*
    self.selectedCompetitionID = -1;
    self.selectedGameID = -1;
    self.selectedCompetitionRow = -1;
    self.selectedGameRow = -1;
     */
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh" attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]}];
    refresh.tintColor = [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [self.tableView setAlwaysBounceVertical:YES];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-only.png"]];
    
    self.type = GAMES;
    self.controllerList = [[NSMutableDictionary alloc] init];
    overallControllerList = [[NSMutableDictionary alloc] init];
    detailViewController = nil;
    addFriendsViewController = nil;
    fantasyViewController = nil;
    statsViewController = nil;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isLoading = NO;
    if (competitionID) {
        self.type = COMPETITIONS;
        if (competitionName)
            self.title = competitionName;
        else
            self.title = @"Global";
        [self getLeaderboard:competitionID type:COMPETITIONS];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Competition", @"type", nil];
        [Flurry logEvent:@"LEADERBOARD" withParameters:dictionary];
    } else if (self.lbType == FRIEND) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Invite" style:UIBarButtonItemStylePlain target:self action:@selector(addFriends:)];
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0];
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0],UITextAttributeFont,nil];
        [self.navigationItem.rightBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        if (!self.type)
            self.type = GAMES;
        self.title = friendPool.name;
        [self getFriendLeaderboard:self.game.gameID poolID:self.friendPool.poolID type:GAMES];
        [self getFriendLeaderboard:self.game.competitionID poolID:self.friendPool.poolID type:COMPETITIONS];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Friend", @"type", nil];
        [Flurry logEvent:@"LEADERBOARD" withParameters:dictionary];
    } else if (self.lbType == GLOBAL) {
        if (!self.type)
            self.type = GAMES;
        if (fromWinners)
            self.title = self.game.name;
        else
            self.title = @"Global";
        [self getLeaderboard:self.game.gameID type:GAMES];
        [self getLeaderboard:self.game.competitionID type:COMPETITIONS];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Global", @"type", nil];
        [Flurry logEvent:@"LEADERBOARD" withParameters:dictionary];
    } else if (self.lbType == FANGROUP) {
        self.type = GAMES;
        self.title = @"Fangroup";
        [self getFangroupLeaderboard:self.game.gameID type:GAMES];
        [self getFangroupLeaderboard:self.game.competitionID type:COMPETITIONS];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Fangroup", @"type", nil];
        [Flurry logEvent:@"LEADERBOARD" withParameters:dictionary];
    }
    /*
    } else {
        [self getCompetitions:self];
        [self getGames:self];
    }
     */
}

- (void) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)refreshView:(UIRefreshControl *)refresh
{
    if (!self.isLoading) {
        self.isLoading = YES;
        if (competitionID) {
            [self getLeaderboard:competitionID type:COMPETITIONS];
        } else if (self.lbType == FRIEND) {
            [self getFriendLeaderboard:self.game.gameID poolID:self.friendPool.poolID type:GAMES];
            [self getFriendLeaderboard:self.game.competitionID poolID:self.friendPool.poolID type:COMPETITIONS];
        } else if (self.lbType == GLOBAL) {
            [self getLeaderboard:self.game.gameID type:GAMES];
            [self getLeaderboard:self.game.competitionID type:COMPETITIONS];
        } else if (self.lbType == FANGROUP) {
            [self getFangroupLeaderboard:self.game.gameID type:GAMES];
            [self getFangroupLeaderboard:self.game.competitionID type:COMPETITIONS];
        }
        /*
        } else {
            [self getCompetitions:self];
            [self getGames:self];
            if (self.type == GAMES) {
                Game *game = [self.dataController.gameList objectAtIndex:self.selectedGameRow];
                if (game)
                    [self getLeaderboard:game.gameID type:GAMES];
            } else if (self.type == COMPETITIONS) {
                Competition *competition = [self.dataController.competitionList objectAtIndex:self.selectedCompetitionRow];
                if (competition)
                    [self getLeaderboard:competition.competitionID type:COMPETITIONS];
            } else {
                self.isLoading = NO;
                [self.refreshControl endRefreshing];
            }
        }
         */
    } else {
        [self.refreshControl endRefreshing];
    }
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
        [[NSBundle mainBundle] loadNibNamed:@"IPLeaderboardHeaderView" owner:self options:nil];
        
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
        NSDictionary *attributesUnselected = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Avalon-Demi" size:14.0],UITextAttributeFont,[UIColor colorWithRed:96/255.0 green:97/255.0 blue:120/255.0 alpha:1], UITextAttributeTextColor, nil];
        NSDictionary *attributesSelected = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Avalon-Demi" size:14.0],UITextAttributeFont,[UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1], UITextAttributeTextColor, nil];
        [pointsButton setTitleTextAttributes:attributesUnselected forState:UIControlStateNormal];
        [pointsButton setTitleTextAttributes:attributesSelected forState:UIControlStateSelected];
        rankHeader.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        winningsHeader.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        nameHeader.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        pointsHeader.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        leftLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        rightLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
    }
    self.rankHeader.text = @"RANK";
    self.winningsHeader.text = @"WINNINGS";
    self.nameHeader.text = @"NAME";
    self.pointsHeader.text = @"POINTS";
    if (self.lbType == FANGROUP) {
        self.nameHeader.text = @"TEAM";
        self.pointsHeader.text = @"AVG PTS";
    }
    if (self.type == COMPETITIONS)
        self.pointsHeader.text = @"GAMES";
    
    if (self.game) {
        UIImage *image = [UIImage imageNamed: @"green_dot.png"];
        UIImage *amberImage = [UIImage imageNamed:@"amber.png"];
        if (self.game.inplayType == 0)
            [self.inplayIndicator setImage:amberImage];
        else
            [self.inplayIndicator setImage:image];
        if ((self.game.state == INPLAY) || (self.game.state == SUSPENDED)) {
            [self.inplayIndicator setHidden:NO];
        } else {
            [self.inplayIndicator setHidden:YES];
        }
    }
    
    Points *points = self.dataController.gamePoints;
    CompetitionPoints *competitionPoints = self.dataController.competitionPoints;
    PoolPoints *poolGamePoints = self.dataController.poolGamePoints;
    PoolPoints *poolCompetitionPoints = self.dataController.poolCompetitionPoints;
    if (self.lbType == GLOBAL) {
        switch (self.pointsButton.selectedSegmentIndex) {
            case (0):
                self.left = [points.globalPoints stringByAppendingFormat:@" points    %@/%@", points.globalRank, points.globalPoolSize];
                [self.leftLabel setText:self.left];
                [self.rightLabel setText:points.globalPot];
                break;
            case (1):
                self.left = [competitionPoints.globalWinnings stringByAppendingFormat:@"    %@/%@",competitionPoints.globalRank, competitionPoints.globalPoolSize];
                [self.leftLabel setText:self.left];
                [self.rightLabel setText:competitionPoints.totalGlobalWinnings];
                break;
        }
    } else if (self.lbType == FANGROUP) {
        switch (self.pointsButton.selectedSegmentIndex) {
            case (0):
                if (points.lateEntry)
                    self.left = [points.fangroupName stringByAppendingString:@"    (Not Entered)"];
                else
                    self.left = [points.fangroupName stringByAppendingFormat:@"    %@/%@", points.fangroupRank, points.numFangroups];
                [self.leftLabel setText:self.left];
                [self.rightLabel setText:points.fangroupPot];
                break;
            case (1):
                self.left = [competitionPoints.fangroupName stringByAppendingFormat:@"    %@/%@",competitionPoints.fangroupRank, competitionPoints.numFangroups];
                [self.leftLabel setText:self.left];
                [self.rightLabel setText:competitionPoints.totalFangroupWinnings];
                break;
        }
    } else if (self.lbType == FRIEND) {
        switch (self.pointsButton.selectedSegmentIndex) {
            case (0):
                self.left = [poolGamePoints.points stringByAppendingFormat:@" points    %@/%@", poolGamePoints.poolRank, poolGamePoints.poolSize];
                [self.leftLabel setText:self.left];
                [self.rightLabel setText:poolGamePoints.poolPotSize];
                break;
            case (1):
                self.left = [poolCompetitionPoints.poolWinnings stringByAppendingFormat:@"    %@/%@",poolCompetitionPoints.poolRank, poolCompetitionPoints.poolSize];
                [self.leftLabel setText:self.left];
                [self.rightLabel setText:poolCompetitionPoints.totalPoolWinnings];
                break;
        }
    }
   
    
    /*
    if (self.type == GAMES) {
        Points *points = self.dataController.gamePoints;
        switch (self.pointsButton.selectedSegmentIndex) {
            case (0):
                self.left = [points.globalPoints stringByAppendingFormat:@" points    %@/%@", points.globalRank, points.globalPoolSize];
                [self.leftLabel setText:self.left];
                [self.rightLabel setText:points.globalPot];
                break;
            case (1):
                if (points.lateEntry)
                    self.left = [points.fangroupName stringByAppendingString:@"    <Not Entered>"];
                else
                    self.left = [points.fangroupName stringByAppendingFormat:@"    %@/%@", points.fangroupRank, points.numFangroups];
                [self.leftLabel setText:self.left];
                [self.rightLabel setText:points.fangroupPot];
                break;
            case (2):
                if (points.lateEntry)
                    self.left = [points.fangroupName stringByAppendingString:@"    <Not Entered>"];
                else
                    self.left = [points.globalPoints stringByAppendingFormat:@" points    %@/%@    %@", points.userinfangroupRank, points.fangroupPoolSize, points.fangroupName];
                [self.leftLabel setText:self.left];
                [self.rightLabel setText:points.fangroupPot];
                break;
        }
    }
    else if (self.type == COMPETITIONS) {
        CompetitionPoints *competitionPoints = self.dataController.competitionPoints;
        switch (self.pointsButton.selectedSegmentIndex) {
            case (0):
                self.left = [competitionPoints.globalWinnings stringByAppendingFormat:@"    %@/%@",competitionPoints.globalRank, competitionPoints.globalPoolSize];
                [self.leftLabel setText:self.left];
                [self.rightLabel setText:competitionPoints.totalGlobalWinnings];
                break;
            case (1):
                self.left = [competitionPoints.fangroupName stringByAppendingFormat:@"    %@/%@",competitionPoints.fangroupRank, competitionPoints.numFangroups];
                [self.leftLabel setText:self.left];
                [self.rightLabel setText:competitionPoints.totalFangroupWinnings];
                break;
            case (2):
                self.left = [competitionPoints.globalWinnings stringByAppendingFormat:@"    %@/%@    %@", competitionPoints.userinfangroupRank, competitionPoints.fangroupPoolSize, competitionPoints.fangroupName];
                [self.leftLabel setText:self.left];
                [self.rightLabel setText:competitionPoints.totalUserinfangroupWinnings];
                break;
        }
            
    }
     */
    
    return headerView;
}

- (UIView *)compHeaderView
{
    if (!compHeaderView) {
        [[NSBundle mainBundle] loadNibNamed:@"IPCompLeaderboardHeaderView" owner:self options:nil];
        rankHeader.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        winningsHeader.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        nameHeader.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        pointsHeader.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        leftLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        rightLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
    }
    self.rankHeader.text = @"RANK";
    self.winningsHeader.text = @"WINNINGS";
    self.nameHeader.text = @"NAME";
    self.pointsHeader.text = @"GAMES";
    
    CompetitionPoints *competitionPoints = self.dataController.competitionPoints;
    self.left = [competitionPoints.globalWinnings stringByAppendingFormat:@"    %@/%@",competitionPoints.globalRank, competitionPoints.globalPoolSize];
    [self.leftLabel setText:self.left];
    [self.rightLabel setText:competitionPoints.totalGlobalWinnings];
    
    return compHeaderView;
}


/*
- (UIView *)footerView
{
    if (!footerView) {
        [[NSBundle mainBundle] loadNibNamed:@"IPLeaderboardFooterView" owner:self options:nil];
        UIImage *image = [UIImage imageNamed:@"submit-button.png"];
        UIImage *image2 = [UIImage imageNamed:@"submit-button-hit-state.png"];
        UIImage *image3 = [UIImage imageNamed:@"submit-button-disabled.png"];
        [self.competitionButton setBackgroundImage:image forState:UIControlStateNormal];
        [self.competitionButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
        [self.competitionButton setBackgroundImage:image3 forState:UIControlStateDisabled];
        [self.gameButton setBackgroundImage:image forState:UIControlStateNormal];
        [self.gameButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
        [self.gameButton setBackgroundImage:image3 forState:UIControlStateDisabled];
        self.competitionButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
        self.gameButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
            self.gameButton.titleEdgeInsets = titleInsets;
            self.competitionButton.titleEdgeInsets = titleInsets;
        }
    }

    return footerView;
}
 */


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (((self.lbType == GLOBAL) || (self.lbType == FRIEND)) && (self.type == GAMES))
        return [self.dataController.globalGameLeaderboard count];
    else if ((self.lbType == FANGROUP) && (self.type == GAMES))
        return [self.dataController.fangroupGameLeaderboard count];
    else if (((self.lbType == GLOBAL) || (self.lbType == FRIEND)) && (self.type == COMPETITIONS))
        return [self.dataController.globalCompetitionLeaderboard count];
    else if ((self.lbType == FANGROUP) && (self.type == COMPETITIONS))
        return [self.dataController.fangroupCompetitionLeaderboard count];
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    IPLeaderboardItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IPLeaderboardItemCell"];
    cell.rankLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
    cell.nameLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
    cell.pointsLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
    cell.winningsLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
    cell.rankLabel.textColor = [UIColor whiteColor];
    cell.nameLabel.textColor = [UIColor whiteColor];
    cell.pointsLabel.textColor = [UIColor whiteColor];
    cell.winningsLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0];
    
    /*
    if (((self.lbType == GLOBAL) || (self.lbType == FRIEND)) && (self.type == GAMES) && ((self.game.state == COMPLETED) || (self.game.state == ARCHIVED))) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
     */
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (((self.lbType == GLOBAL) || (self.lbType == FRIEND)) && (self.type == GAMES)) {
        if ([self.dataController.globalGameLeaderboard count] == 1)
            cell.accessoryType = UITableViewCellAccessoryNone;
    } else if (((self.lbType == GLOBAL) || (self.lbType == FRIEND)) && (self.type == COMPETITIONS)) {
        if ([self.dataController.globalCompetitionLeaderboard count] == 1)
            cell.accessoryType = UITableViewCellAccessoryNone;
    }

    cell.row = indexPath.row;
    /*
    if (indexPath.row % 2) {
        cell.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:62/255.0 alpha:1];
        cell.contentView.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:62/255.0 alpha:1];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1];
        cell.contentView.backgroundColor = [UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1];
    }
     */
    
    Leaderboard *leaderboardAtIndex;
    if (((self.lbType == GLOBAL) || (self.lbType == FRIEND)) && (self.type == GAMES)) {
        leaderboardAtIndex = [self.dataController.globalGameLeaderboard objectAtIndex:indexPath.row];
    } else if ((self.lbType == FANGROUP) && (self.type == GAMES)) {
        leaderboardAtIndex = [self.dataController.fangroupGameLeaderboard objectAtIndex:indexPath.row];
    } else if (((self.lbType == GLOBAL) || (self.lbType == FRIEND)) && (self.type == COMPETITIONS)) {
        leaderboardAtIndex = [self.dataController.globalCompetitionLeaderboard objectAtIndex:indexPath.row];
    } else if ((self.lbType == FANGROUP) && (self.type == COMPETITIONS)) {
        leaderboardAtIndex = [self.dataController.fangroupCompetitionLeaderboard objectAtIndex:indexPath.row];
    }
    
    NSString *rankString;
    if ((leaderboardAtIndex.rank == -1) || (leaderboardAtIndex.rank == 0) || (leaderboardAtIndex.rank >= LARGESTRANK))
        rankString = @"-";
    else
        rankString = [NSString stringWithFormat:@"%d", (int)leaderboardAtIndex.rank];
    
    if (leaderboardAtIndex.rank == 1) {
        cell.rankLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:13.0];
        cell.nameLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:13.0];
        cell.pointsLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:13.0];
        cell.winningsLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:13.0];
    }
    
    IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.user isEqualToString:leaderboardAtIndex.name]) {
        cell.rankLabel.textColor = [UIColor colorWithRed:189/255.0 green:233/255.0 blue:51/255.0 alpha:1];
        cell.nameLabel.textColor = [UIColor colorWithRed:189/255.0 green:233/255.0 blue:51/255.0 alpha:1];
    }
    if (self.type == GAMES) {
        if ([self.dataController.gamePoints.fangroupName isEqualToString:leaderboardAtIndex.name]) {
            cell.rankLabel.textColor = [UIColor colorWithRed:189/255.0 green:233/255.0 blue:51/255.0 alpha:1];
            cell.nameLabel.textColor = [UIColor colorWithRed:189/255.0 green:233/255.0 blue:51/255.0 alpha:1];
        }
    } else if (self.type == COMPETITIONS) {
        if ([self.dataController.competitionPoints.fangroupName isEqualToString:leaderboardAtIndex.name]) {
            cell.rankLabel.textColor = [UIColor colorWithRed:189/255.0 green:233/255.0 blue:51/255.0 alpha:1];
            cell.nameLabel.textColor = [UIColor colorWithRed:189/255.0 green:233/255.0 blue:51/255.0 alpha:1];
        }
    }
    
    [[cell rankLabel] setText:rankString];
    [[cell nameLabel] setText:leaderboardAtIndex.name];
    [[cell pointsLabel] setText:leaderboardAtIndex.points];
    [[cell winningsLabel] setText:leaderboardAtIndex.winnings];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}



#pragma mark - Table view delegate


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (competitionID)
        return [self compHeaderView];
    else
        return [self headerView];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (competitionID)
        return [[self compHeaderView] bounds].size.height;
    else
        return [[self headerView] bounds].size.height;
}

/*
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (self.game)
        return nil;
    else 
        return [self footerView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.game)
        return 0;
    else
        return [[self footerView] bounds].size.height;
}
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (((self.lbType == GLOBAL) || (self.lbType == FRIEND)) && (self.type == GAMES)) {
        if ((self.game.state == COMPLETED) || (self.game.state == ARCHIVED)) {
            Leaderboard *leaderboardAtIndex = [self.dataController.globalGameLeaderboard objectAtIndex:indexPath.row];
            if ([controllerList objectForKey:leaderboardAtIndex.name] == nil) {
                if (self.game.type == FANTASY) {
                    fantasyViewController = [[IPFantasyViewController alloc] initWithNibName:@"IPFantasyViewController" bundle:nil];
                    fantasyViewController.game = self.game;
                    [controllerList setObject:fantasyViewController forKey:leaderboardAtIndex.name];
                    fantasyViewController.username = leaderboardAtIndex.name;
                    fantasyViewController.fromLeaderboard = YES;
                } else {
                    detailViewController = [[IPGameViewController alloc] initWithNibName:@"IPGameViewController" bundle:nil];
                    detailViewController.game = self.game;
                    [controllerList setObject:detailViewController forKey:leaderboardAtIndex.name];
                    detailViewController.username = leaderboardAtIndex.name;
                    detailViewController.fromLeaderboard = YES;
                }
                NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil];
                [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
                [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]];
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
                    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
                else
                    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
            }
            if ([controllerList objectForKey:leaderboardAtIndex.name]) {
                [self.navigationController pushViewController:[controllerList objectForKey:leaderboardAtIndex.name] animated:YES];
            }
            return;
        }
    }
    Leaderboard *leaderboardAtIndex;
    if (((self.lbType == GLOBAL) || (self.lbType == FRIEND)) && (self.type == GAMES)) {
        leaderboardAtIndex = [self.dataController.globalGameLeaderboard objectAtIndex:indexPath.row];
        if ([self.dataController.globalGameLeaderboard count] == 1)
            return;
    } else if (((self.lbType == GLOBAL) || (self.lbType == FRIEND)) && (self.type == COMPETITIONS)) {
        leaderboardAtIndex = [self.dataController.globalCompetitionLeaderboard objectAtIndex:indexPath.row];
        if ([self.dataController.globalCompetitionLeaderboard count] == 1)
            return;
    }
    if ([overallControllerList objectForKey:leaderboardAtIndex.name] == nil) {
        statsViewController = [[IPStatsViewController alloc] initWithNibName:@"IPStatsViewController" bundle:nil];
        statsViewController.externalUsername = leaderboardAtIndex.name;
        if (leaderboardAtIndex.fbID)
            statsViewController.externalFBID = leaderboardAtIndex.fbID;
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil];
        [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        else
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        [overallControllerList setObject:statsViewController forKey:leaderboardAtIndex.name];
    }
    if ([overallControllerList objectForKey:leaderboardAtIndex.name]) {
        [self.navigationController pushViewController:[overallControllerList objectForKey:leaderboardAtIndex.name] animated:YES];
    }
    return;
}

- (IBAction)changePoints:(id)sender
{
    if (self.pointsButton.selectedSegmentIndex == 0)
        self.type = GAMES;
    else
        self.type = COMPETITIONS;
    [self.tableView reloadData];
}

- (void)addFriends:(id)sender {
    if (!self.addFriendsViewController) {
        self.addFriendsViewController = [[IPAddFriendsViewController alloc] initWithNibName:@"IPAddFriendsViewController" bundle:nil];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        else
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    }
    if (self.addFriendsViewController) {
        self.addFriendsViewController.poolID = self.friendPool.poolID;
        [self.navigationController pushViewController:self.addFriendsViewController animated:YES];
    }
}

/*
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == COMPETITIONS) {
        return [self.dataController.competitionList count];
    } else {
        return [self.dataController.gameList count];
    }
    
}


- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (pickerView.tag == COMPETITIONS) {
        Competition *competition = [self.dataController.competitionList objectAtIndex:row];
        if (row == 0) {
            self.selectedCompetitionID = competition.competitionID;
            self.selectedCompetitionRow = 0;
        }
        return competition.name;
    } else {
        Game *game = [self.dataController.gameList objectAtIndex:row];
        if (row == 0) {
            self.selectedGameID = game.gameID;
            self.selectedGameRow = 0;
        }
        return game.name;
    }
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    if (pickerView.tag == COMPETITIONS) {
        Competition* competition = [self.dataController.competitionList objectAtIndex:row];
        self.selectedCompetitionID = competition.competitionID;
        self.selectedCompetitionRow = row;
    } else {
        Game *game = [self.dataController.gameList objectAtIndex:row];
        self.selectedGameID = game.gameID;
        self.selectedGameRow = row;
    }
}


- (IBAction)submitCompetition:(id)sender {
    
    if ([self.dataController.competitionList count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Competitions" message:@"You have not entered any competitions!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    CGRect frame = CGRectMake(0, 0, 320, 44);
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:frame];
    pickerToolbar.barStyle = UIBarStyleBlack;
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target:self action:@selector(actionPickerCancel:)];
    [cancelBtn setTintColor:[UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0]];
    [barItems addObject:cancelBtn];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [barItems addObject:flexSpace];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(competitionDone:)];
    [doneButton setTintColor:[UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0]];
    [barItems addObject:doneButton];
    [pickerToolbar setItems:barItems animated:NO];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0] } forState:UIControlStateNormal];
    } else {
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil];
        [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    }
    
    CGFloat windowHeight = self.view.superview.frame.size.height;
    myView = [[UIView alloc] initWithFrame:CGRectMake(0, windowHeight-260, 320, 260)];
    [myView setBackgroundColor:[UIColor lightGrayColor]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        [myView setTintColor:[UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0]];
    UIPickerView *myPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 320, 216)];
    myPicker.showsSelectionIndicator=YES;
    myPicker.dataSource = self;
    myPicker.delegate = self;
    myPicker.tag = COMPETITIONS;
    [myPicker selectRow:0 inComponent:0 animated:NO];
    [myView addSubview:pickerToolbar];
    [myView addSubview:myPicker];
    
    [self.view.superview addSubview:myView];
    [self.view.superview bringSubviewToFront:myView];
    [self.tableView setUserInteractionEnabled:NO];
 
}


- (IBAction)submitGame:(id)sender {
    
    if ([self.dataController.gameList count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Games" message:@"You have not entered any games!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    CGRect frame = CGRectMake(0, 0, 320, 44);
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:frame];
    pickerToolbar.barStyle = UIBarStyleBlack;
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target:self action:@selector(actionPickerCancel:)];
    [cancelBtn setTintColor:[UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0]];
    [barItems addObject:cancelBtn];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [barItems addObject:flexSpace];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(gameDone:)];
    [doneButton setTintColor:[UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0]];
    [barItems addObject:doneButton];
    [pickerToolbar setItems:barItems animated:NO];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0] } forState:UIControlStateNormal];
    } else {
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil];
        [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    }
    
    CGFloat windowHeight = self.view.superview.frame.size.height;
    myView = [[UIView alloc] initWithFrame:CGRectMake(0, windowHeight-260, 320, 260)];
    [myView setBackgroundColor:[UIColor lightGrayColor]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        [myView setTintColor:[UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0]];
    UIPickerView *myPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 320, 216)];
    myPicker.showsSelectionIndicator=YES;
    myPicker.dataSource = self;
    myPicker.delegate = self;
    myPicker.tag = GAMES;
    [myPicker selectRow:0 inComponent:0 animated:NO];
    [myView addSubview:pickerToolbar];
    [myView addSubview:myPicker];
    
    [self.view.superview addSubview:myView];
    [self.view.superview bringSubviewToFront:myView];
    [self.tableView setUserInteractionEnabled:NO];
    

}

-(void)actionPickerCancel:(id)sender {
    [myView removeFromSuperview];
    [self.tableView setUserInteractionEnabled:YES];
}

-(void)competitionDone:(id)sender {
    Competition *competition = [self.dataController.competitionList objectAtIndex:self.selectedCompetitionRow];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:competition.name,
                                @"name", @"Competition", @"type", nil];
    [Flurry logEvent:@"LEADERBOARD" withParameters:dictionary];
    self.type = COMPETITIONS;
    [self getLeaderboard:competition.competitionID type:COMPETITIONS];
    [myView removeFromSuperview];
    [self.tableView setUserInteractionEnabled:YES];
}

-(void)gameDone:(id)sender {
    Game *game = [self.dataController.gameList objectAtIndex:self.selectedGameRow];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:game.name,
                                @"name", @"Game", @"type", nil];
    [Flurry logEvent:@"LEADERBOARD" withParameters:dictionary];
    self.type = GAMES;
    [self getLeaderboard:game.gameID type:GAMES];
    [myView removeFromSuperview];
    [self.tableView setUserInteractionEnabled:YES];
}
 */

/*
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == COMPETITIONS)
    {
        if (buttonIndex == SELECTBUTTON) {
            Competition *competition = [self.dataController.competitionList objectAtIndex:self.selectedCompetitionRow];
            // self.title = competition.name;
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:competition.name,
                                        @"name", @"Competition", @"type", nil];
            [Flurry logEvent:@"LEADERBOARD" withParameters:dictionary];
            self.type = COMPETITIONS;
            [self getLeaderboard:competition.competitionID type:COMPETITIONS title:competition.name];
        }
        
    } else if (actionSheet.tag == GAMES) {
        if (buttonIndex == SELECTBUTTON) {
            Game *game = [self.dataController.gameList objectAtIndex:self.selectedGameRow];
            // self.title = game.name;
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:game.name,
                                        @"name", @"Game", @"type", nil];
            [Flurry logEvent:@"LEADERBOARD" withParameters:dictionary];
            self.type = GAMES;
            [self getLeaderboard:game.gameID type:GAMES title:game.name];
        }
    }
}
*/

- (void)refresh:(NSInteger)type {
    NSSortDescriptor *rankSorter = [[NSSortDescriptor alloc] initWithKey:@"rank" ascending:YES];
    NSSortDescriptor *nameSorter = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    if (competitionID) {
        [self.dataController.globalCompetitionLeaderboard sortUsingDescriptors:[NSArray arrayWithObjects:rankSorter, nameSorter, nil]];
    } else if (type == GLOBAL) {
        [self.dataController.globalGameLeaderboard sortUsingDescriptors:[NSArray arrayWithObjects:rankSorter, nameSorter, nil]];
        [self.dataController.globalCompetitionLeaderboard sortUsingDescriptors:[NSArray arrayWithObjects:rankSorter, nameSorter, nil]];
    } else if (type == FANGROUP) {
        [self.dataController.fangroupGameLeaderboard sortUsingDescriptors:[NSArray arrayWithObjects:rankSorter, nameSorter, nil]];
        [self.dataController.fangroupCompetitionLeaderboard sortUsingDescriptors:[NSArray arrayWithObjects:rankSorter, nameSorter, nil]];
    }
    [self.tableView reloadData];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                             [formatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]}];
    [self.refreshControl endRefreshing];
    self.isLoading = NO;
}

/*
- (void)getCompetitions:(id)sender
{
    [self.competitionButton setEnabled:NO];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager getObjectsAtPath:@"competition/list" parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [self.dataController.competitionList removeAllObjects];
        NSArray* temp = [result array];
        for (int i=0; i<temp.count; i++) {
            Competition *competition = [temp objectAtIndex:i];
            if (!competition.name)
                competition.name = @"Unassigned";
            if (competition.entered)
                [self.dataController.competitionList addObject:competition];
        }
        [self.dataController.competitionList sortUsingSelector:@selector(compareWithName:)];
        [self.competitionButton setEnabled:YES]; 
     } failure:nil];
}

- (void)getGames:(id)sender
{
    [self.gameButton setEnabled:NO];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager getObjectsAtPath:@"competition/games" parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [self.dataController.gameList removeAllObjects];
        NSArray* temp = [result array];
        for (int i=0; i<temp.count; i++) {
            Game *game = [temp objectAtIndex:i];
            if (!game.name)
                game.name = @"Unassigned";
            if (game.entered)
                [self.dataController.gameList addObject:game];
        }
        [self.dataController.gameList sortUsingSelector:@selector(compareWithName:)];
        [self.gameButton setEnabled:YES];
    } failure:nil];
    
}
 */

- (void)getFriendLeaderboard:(NSInteger)gameID poolID:(NSInteger)poolID type:(NSInteger)type
{
    // friend leaderboard
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path;
    if (type == GAMES)
        path = [NSString stringWithFormat:@"game/leaderboard?game_id=%ld&type=pool&pool_id=%ld", (long)gameID, (long)poolID];
    else if (type == COMPETITIONS)
        path = [NSString stringWithFormat:@"competition/leaderboard?comp_id=%ld&type=pool&pool_id=%ld", (long)gameID, (long)poolID];
    [objectManager getObjectsAtPath:path parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         if (type == GAMES)
             [self.dataController.globalGameLeaderboard removeAllObjects];
         else if (type == COMPETITIONS)
             [self.dataController.globalCompetitionLeaderboard removeAllObjects];
         NSArray* temp = [result array];
         for (int i=0; i<temp.count; i++) {
             Leaderboard *leaderboard = [temp objectAtIndex:i];
             if (!leaderboard.name)
                 leaderboard.name = @"-";
             if (!leaderboard.points)
                 leaderboard.points = @"0";
             if (!leaderboard.winnings)
                 leaderboard.winnings = @"$0";
             else
                 leaderboard.winnings = [@"$" stringByAppendingString:leaderboard.winnings];
             if (type == GAMES)
                 [self.dataController.globalGameLeaderboard addObject:leaderboard];
             else if (type == COMPETITIONS)
                 [self.dataController.globalCompetitionLeaderboard addObject:leaderboard];
         }
         if ((temp.count == 0) && (type == COMPETITIONS)) {
             Leaderboard *leaderboard = [[Leaderboard alloc] initWithRank:LARGESTRANK name:@"No Games Done" points:@"-" winnings:@"-"];
             [self.dataController.globalCompetitionLeaderboard addObject:leaderboard];
         } else if ((temp.count == 0) && (type == GAMES)) {
             Leaderboard *leaderboard = [[Leaderboard alloc] initWithRank:LARGESTRANK name:@"No Entries yet" points:@"-" winnings:@"-"];
             [self.dataController.globalGameLeaderboard addObject:leaderboard];
         }
         if (type == GAMES)
             [self getPoolGamePoints:gameID poolID:poolID];
         else if (type == COMPETITIONS)
             [self getPoolCompetitionPoints:gameID poolID:poolID];
     } failure:^(RKObjectRequestOperation *operation, NSError *error){
         [self.refreshControl endRefreshing];
         self.isLoading = NO;
     }];
}


- (void)getLeaderboard:(NSInteger)gameID type:(NSInteger)type
{
    // global leaderboard
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path;
    if (type == GAMES)
        path = [NSString stringWithFormat:@"game/leaderboard?game_id=%ld&type=global", (long)gameID];
    else if (type == COMPETITIONS)
        path = [NSString stringWithFormat:@"competition/leaderboard?comp_id=%ld&type=global", (long)gameID];
    [objectManager getObjectsAtPath:path parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         if (type == GAMES)
            [self.dataController.globalGameLeaderboard removeAllObjects];
         else if (type == COMPETITIONS)
            [self.dataController.globalCompetitionLeaderboard removeAllObjects];
        NSArray* temp = [result array];
        for (int i=0; i<temp.count; i++) {
            Leaderboard *leaderboard = [temp objectAtIndex:i];
            if (!leaderboard.name)
                leaderboard.name = @"-";
            if (!leaderboard.points)
                leaderboard.points = @"0";
            if (!leaderboard.winnings)
                leaderboard.winnings = @"$0";
            else
                leaderboard.winnings = [@"$" stringByAppendingString:leaderboard.winnings];
            if (type == GAMES)
                [self.dataController.globalGameLeaderboard addObject:leaderboard];
            else if (type == COMPETITIONS)
                [self.dataController.globalCompetitionLeaderboard addObject:leaderboard];
        }
        if (temp.count >= 100) {
             Leaderboard *leaderboard = [[Leaderboard alloc] initWithRank:LARGESTRANK+1 name:@"TOP 100 Returned" points:@"-" winnings:@"-"];
             if (type == GAMES)
                 [self.dataController.globalGameLeaderboard addObject:leaderboard];
             else if (type == COMPETITIONS)
                 [self.dataController.globalCompetitionLeaderboard addObject:leaderboard];
        } else if ((temp.count == 0) && (type == COMPETITIONS)) {
            Leaderboard *leaderboard = [[Leaderboard alloc] initWithRank:LARGESTRANK name:@"No Games Done" points:@"-" winnings:@"-"];
            [self.dataController.globalCompetitionLeaderboard addObject:leaderboard];
        } else if ((temp.count == 0) && (type == GAMES)) {
            Leaderboard *leaderboard = [[Leaderboard alloc] initWithRank:LARGESTRANK name:@"No Entries yet" points:@"-" winnings:@"-"];
            [self.dataController.globalGameLeaderboard addObject:leaderboard];
        }
         if (type == GAMES)
             [self getPoints:gameID];
         else if (type == COMPETITIONS)
             [self getCompetitionPoints:gameID];
     } failure:^(RKObjectRequestOperation *operation, NSError *error){
         [self.refreshControl endRefreshing];
         self.isLoading = NO;
     }];
}

- (void)getFangroupLeaderboard:(NSInteger)gameID type:(NSInteger)type
{
    // fangroup leaderboard
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path2;
    if (type == GAMES)
        path2 = [NSString stringWithFormat:@"game/leaderboard?game_id=%ld&type=fangroup", (long)gameID];
    else if (type == COMPETITIONS)
        path2 = [NSString stringWithFormat:@"competition/leaderboard?comp_id=%ld&type=fangroup", (long)gameID];
    [objectManager getObjectsAtPath:path2 parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if (type == GAMES)
            [self.dataController.fangroupGameLeaderboard removeAllObjects];
        else if (type == COMPETITIONS)
            [self.dataController.fangroupCompetitionLeaderboard removeAllObjects];
        NSArray* temp = [result array];
        for (int i=0; i<temp.count; i++) {
            Leaderboard *leaderboard = [temp objectAtIndex:i];
            if (!leaderboard.name)
                leaderboard.name = @"-";
            if (!leaderboard.points)
                leaderboard.points = @"0";
            if (!leaderboard.winnings)
                leaderboard.winnings = @"$0";
            else
                leaderboard.winnings = [@"$" stringByAppendingString:leaderboard.winnings];
            if (type == GAMES)
                [self.dataController.fangroupGameLeaderboard addObject:leaderboard];
            else if (type == COMPETITIONS)
                [self.dataController.fangroupCompetitionLeaderboard addObject:leaderboard];
        }
         if ((temp.count == 0) && (type == COMPETITIONS)) {
             Leaderboard *leaderboard = [[Leaderboard alloc] initWithRank:LARGESTRANK name:@"No Games Done" points:@"-" winnings:@"-"];
             [self.dataController.fangroupCompetitionLeaderboard addObject:leaderboard];
         } else if ((temp.count == 0) && (type == GAMES)) {
             Leaderboard *leaderboard = [[Leaderboard alloc] initWithRank:LARGESTRANK name:@"No Entries yet" points:@"-" winnings:@"-"];
             [self.dataController.fangroupGameLeaderboard addObject:leaderboard];
         }
         if (type == GAMES)
             [self getPoints:gameID];
         else if (type == COMPETITIONS)
             [self getCompetitionPoints:gameID];
     } failure:^(RKObjectRequestOperation *operation, NSError *error){
         [self.refreshControl endRefreshing];
         self.isLoading = NO;
     }];
}

/*
- (void)getUserinfangroupLeaderboard:(NSInteger)gameID type:(NSInteger)type
{
    // userinfangroup leaderboard
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path3;
    if (type == GAMES)
        path3 = [NSString stringWithFormat:@"game/leaderboard?game_id=%d&type=userinfangroup", gameID];
    else if (type == COMPETITIONS)
        path3 = [NSString stringWithFormat:@"competition/leaderboard?comp_id=%d&type=userinfangroup", gameID];
    [objectManager getObjectsAtPath:path3 parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        if (type == GAMES)
            [self.dataController.userinfangroupGameLeaderboard removeAllObjects];
        else if (type == COMPETITIONS)
            [self.dataController.userinfangroupCompetitionLeaderboard removeAllObjects];
        NSArray* temp = [result array];
        for (int i=0; i<temp.count; i++) {
            Leaderboard *leaderboard = [temp objectAtIndex:i];
            if (!leaderboard.name)
                leaderboard.name = @"-";
            if (!leaderboard.points)
                leaderboard.points = @"0";
            if (!leaderboard.winnings)
                leaderboard.winnings = @"$0";
            else
                leaderboard.winnings = [@"$" stringByAppendingString:leaderboard.winnings];
            if (type == GAMES)
                [self.dataController.userinfangroupGameLeaderboard addObject:leaderboard];
            else if (type == COMPETITIONS)
                [self.dataController.userinfangroupCompetitionLeaderboard addObject:leaderboard];
        }
        if (temp.count == 100) {
             Leaderboard *leaderboard = [[Leaderboard alloc] initWithRank:LARGESTRANK name:@"TOP 100 Returned" points:@"-" winnings:@"-"];
             if (type == GAMES)
                 [self.dataController.userinfangroupGameLeaderboard addObject:leaderboard];
             else if (type == COMPETITIONS)
                 [self.dataController.userinfangroupCompetitionLeaderboard addObject:leaderboard];
        } else if ((temp.count == 0) && (type == COMPETITIONS)) {
            Leaderboard *leaderboard = [[Leaderboard alloc] initWithRank:LARGESTRANK name:@"No Games Completed" points:@"-" winnings:@"-"];
            [self.dataController.userinfangroupCompetitionLeaderboard addObject:leaderboard];
        }
        if (type == GAMES)
             [self getPoints:gameID];
        else if (type == COMPETITIONS)
             [self getCompetitionPoints:gameID];
     
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        [self.refreshControl endRefreshing];
        self.isLoading = NO;
    }];
}
 */

- (void)getPoints:(NSInteger)gameID
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"game/points?game_id=%ld&includeSelections=false", (long)gameID];
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
        
        self.dataController.gamePoints = points;
        if (self.lbType == GLOBAL)
            [self refresh:GLOBAL];
        else
            [self refresh:FANGROUP];
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        [self.refreshControl endRefreshing];
        self.isLoading = NO;
    }];
}

- (void)getCompetitionPoints:(NSInteger)gameID
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"competition/points?comp_id=%ld", (long)gameID];
    [objectManager getObjectsAtPath:path parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         CompetitionPoints *points = [result firstObject];
         // data checking and formatting
         if ((!points.globalWinnings) || ([points.globalWinnings isEqualToString:@"-1"]))
             points.globalWinnings = @"-";
         else
             points.globalWinnings = [@"$" stringByAppendingString:points.globalWinnings];
         
         if ((!points.globalRank) || ([points.globalRank isEqualToString:@"2000000000"]) || ([points.globalRank isEqualToString:@"0"]))
             points.globalRank = @"#-";
         else
             points.globalRank = [@"#" stringByAppendingString:points.globalRank];
         if ((!points.fangroupRank) || ([points.fangroupRank isEqualToString:@"2000000000"]) || ([points.fangroupRank isEqualToString:@"0"]))
             points.fangroupRank = @"#-";
         else
             points.fangroupRank = [@"#" stringByAppendingString:points.fangroupRank];
         if ((!points.userinfangroupRank) || ([points.userinfangroupRank isEqualToString:@"2000000000"])  || ([points.userinfangroupRank isEqualToString:@"0"]))
             points.userinfangroupRank = @"#-";
         else
             points.userinfangroupRank = [@"#" stringByAppendingString:points.userinfangroupRank];
         
         if (!points.fangroupName)
             points.fangroupName = @"-";
         
         if (!points.globalPoolSize)
             points.globalPoolSize = @"-";
         if (!points.numFangroups)
             points.numFangroups = @"-";
         if (!points.fangroupPoolSize)
             points.fangroupPoolSize = @"-";
         
         if (!points.totalGlobalWinnings)
             points.totalGlobalWinnings = @"Total: $-";
         else
             points.totalGlobalWinnings = [@"Total: $" stringByAppendingString:points.totalGlobalWinnings];
         if (!points.totalFangroupWinnings)
             points.totalFangroupWinnings = @"Total: $-";
         else
             points.totalFangroupWinnings = [@"Total: $" stringByAppendingString:points.totalFangroupWinnings];
         if (!points.totalUserinfangroupWinnings)
             points.totalUserinfangroupWinnings = @"Total: $-";
         else
             points.totalUserinfangroupWinnings = [@"Total: $" stringByAppendingString:points.totalUserinfangroupWinnings];
         
         self.dataController.competitionPoints = points;
         if (competitionID)
             [self refresh:GLOBAL];
     } failure:^(RKObjectRequestOperation *operation, NSError *error){
         [self.refreshControl endRefreshing];
         self.isLoading = NO;
     }];
}

- (void)getPoolGamePoints:(NSInteger)gameID poolID:(NSInteger)poolID
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"pool/points?pool_id=%ld&game_id=%ld", (long)poolID, (long)gameID];
    [objectManager getObjectsAtPath:path parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         PoolPoints *points = [result firstObject];
         // data checking and formatting
         if ((!points.poolPotSize) || ([points.poolPotSize isEqualToString:@"-1"]))
             points.poolPotSize = @"Pot: $-";
         else
             points.poolPotSize = [@"Pot: $" stringByAppendingString:points.poolPotSize];
         if ((!points.poolRank) || ([points.poolRank isEqualToString:@"2000000000"]) || ([points.poolRank isEqualToString:@"0"]))
             points.poolRank = @"#-";
         else
             points.poolRank = [@"#" stringByAppendingString:points.poolRank];
         if ((!points.points) || ([points.points isEqualToString:@"-1"]))
             points.points = @"0";
         if (!points.poolSize)
             points.poolSize = @"-";
         self.dataController.poolGamePoints = points;
         [self refresh:GLOBAL];
     } failure:^(RKObjectRequestOperation *operation, NSError *error){
         [self.refreshControl endRefreshing];
         self.isLoading = NO;
     }];
}

- (void)getPoolCompetitionPoints:(NSInteger)compID poolID:(NSInteger)poolID
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"pool/points?pool_id=%ld&comp_id=%ld", (long)poolID, (long)compID];
    [objectManager getObjectsAtPath:path parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         PoolPoints *points = [result firstObject];
         // data checking and formatting
         if ((!points.poolWinnings) || ([points.poolWinnings isEqualToString:@"-1"]))
             points.poolWinnings = @"-";
         else
             points.poolWinnings = [@"$" stringByAppendingString:points.poolWinnings];
         
         if ((!points.poolRank) || ([points.poolRank isEqualToString:@"2000000000"]) || ([points.poolRank isEqualToString:@"0"]))
             points.poolRank = @"#-";
         else
             points.poolRank = [@"#" stringByAppendingString:points.poolRank];
         if (!points.poolSize)
             points.poolSize = @"-";
         if (!points.totalPoolWinnings)
             points.totalPoolWinnings = @"Total: $-";
         else
             points.totalPoolWinnings = [@"Total: $" stringByAppendingString:points.totalPoolWinnings];
         
         self.dataController.poolCompetitionPoints = points;
     } failure:^(RKObjectRequestOperation *operation, NSError *error){
         [self.refreshControl endRefreshing];
         self.isLoading = NO;
     }];
}

@end
