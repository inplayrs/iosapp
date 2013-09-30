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


#define COMPETITIONS 1
#define GAMES 2
#define SELECTBUTTON 0
#define LARGESTRANK 2000000000

enum State {
    PREPLAY=-1,
    TRANSITION=0,
    INPLAY=1,
    COMPLETED=2,
    SUSPENDED=3,
    NEVERINPLAY=4
};


@implementation IPLeaderboardViewController

@synthesize leftLabel, rightLabel, pointsButton, left, rankHeader, nameHeader, pointsHeader, winningsHeader, competitionButton, gameButton, isLoading, inplayIndicator;


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
    
    self.title = @"Leaderboard";
    self.dataController = [[LeaderboardDataController alloc] init];
    
    UINib *nib = [UINib nibWithNibName:@"IPLeaderboardItemCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"IPLeaderboardItemCell"];
    
    self.selectedCompetitionID = -1;
    self.selectedGameID = -1;
    self.selectedCompetitionRow = -1;
    self.selectedGameRow = -1;
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    refresh.tintColor = [UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [self.tableView setAlwaysBounceVertical:YES];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-only.png"]];
    
    self.type = 0;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isLoading = NO;
    if (self.game) {
        // self.title = self.game.name;
        NSString *stateString = [NSString stringWithFormat:@"%d", (int)self.game.state];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.game.name,
                                    @"name", stateString, @"state", @"fromGame", @"type", nil];
        [Flurry logEvent:@"LEADERBOARD" withParameters:dictionary];
        self.type = GAMES;
        [self getLeaderboard:self.game.gameID type:GAMES title:self.game.name];
    } else {
        [self getCompetitions:self];
        [self getGames:self];
    }
}

- (void) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)refreshView:(UIRefreshControl *)refresh
{
    if (!self.isLoading) {
        self.isLoading = YES;
        if (self.game) {
            [self getLeaderboard:self.game.gameID type:GAMES title:self.game.name];
        } else {
            [self getCompetitions:self];
            [self getGames:self];
            if (self.type == GAMES) {
                Game *game = [self.dataController.gameList objectAtIndex:self.selectedGameRow];
                if (game)
                    [self getLeaderboard:game.gameID type:GAMES title:game.name];
            } else if (self.type == COMPETITIONS) {
                Competition *competition = [self.dataController.competitionList objectAtIndex:self.selectedCompetitionRow];
                if (competition)
                    [self getLeaderboard:competition.competitionID type:COMPETITIONS title:competition.name];
            } else {
                self.isLoading = NO;
                [self.refreshControl endRefreshing];
            }
        }
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
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Avalon-Demi" size:14.0],UITextAttributeFont,[UIColor whiteColor], UITextAttributeTextColor, nil];
        [pointsButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [pointsButton setTitleTextAttributes:attributes forState:UIControlStateSelected];
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
    if (self.pointsButton.selectedSegmentIndex == 1) {
        self.nameHeader.text = @"TEAM";
        self.pointsHeader.text = @"AVG PTS";
    }
    if (self.type == COMPETITIONS)
        self.pointsHeader.text = @"GAMES";
    
    if (self.game) {
        UIImage *image = [UIImage imageNamed: @"green_dot.png"];
        [self.inplayIndicator setImage:image];
        if ((self.game.state == INPLAY) || (self.game.state == SUSPENDED)) {
            [self.inplayIndicator setHidden:NO];
        } else {
            [self.inplayIndicator setHidden:YES];
        }
    }
    

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
    
    return headerView;
}

- (UIView *)footerView
{
    if (!footerView) {
        [[NSBundle mainBundle] loadNibNamed:@"IPLeaderboardFooterView" owner:self options:nil];
        UIImage *image = [UIImage imageNamed:@"submit-button.png"];
        UIImage *image2 = [UIImage imageNamed:@"submit-button-hit-state.png"];
        UIImage *image3 = [UIImage imageNamed:@"grey-button.png"];
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((self.pointsButton.selectedSegmentIndex == 0) && (self.type == GAMES))
        return [self.dataController.globalGameLeaderboard count];
    else if ((self.pointsButton.selectedSegmentIndex == 1) && (self.type == GAMES))
        return [self.dataController.fangroupGameLeaderboard count];
    else if ((self.pointsButton.selectedSegmentIndex == 2) && (self.type == GAMES))
        return [self.dataController.userinfangroupGameLeaderboard count];
    else if ((self.pointsButton.selectedSegmentIndex == 0) && (self.type == COMPETITIONS))
        return [self.dataController.globalCompetitionLeaderboard count];
    else if ((self.pointsButton.selectedSegmentIndex == 1) && (self.type == COMPETITIONS))
        return [self.dataController.fangroupCompetitionLeaderboard count];
    else if ((self.pointsButton.selectedSegmentIndex == 2) && (self.type == COMPETITIONS))
        return [self.dataController.userinfangroupCompetitionLeaderboard count];
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
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"leaderboard-row.png"]];
    cell.backgroundView = imageView;
    // cell.backgroundColor = [UIColor colorWithRed:36.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0];
    
    Leaderboard *leaderboardAtIndex;
    if ((self.pointsButton.selectedSegmentIndex == 0) && (self.type == GAMES)) {
        leaderboardAtIndex = [self.dataController.globalGameLeaderboard objectAtIndex:indexPath.row];
    } else if ((self.pointsButton.selectedSegmentIndex == 1) && (self.type == GAMES)) {
        leaderboardAtIndex = [self.dataController.fangroupGameLeaderboard objectAtIndex:indexPath.row];
    } else if ((self.pointsButton.selectedSegmentIndex == 2) && (self.type == GAMES)) {
        leaderboardAtIndex = [self.dataController.userinfangroupGameLeaderboard objectAtIndex:indexPath.row];
    } else if ((self.pointsButton.selectedSegmentIndex == 0) && (self.type == COMPETITIONS)) {
        leaderboardAtIndex = [self.dataController.globalCompetitionLeaderboard objectAtIndex:indexPath.row];
    } else if ((self.pointsButton.selectedSegmentIndex == 1) && (self.type == COMPETITIONS)) {
        leaderboardAtIndex = [self.dataController.fangroupCompetitionLeaderboard objectAtIndex:indexPath.row];
    } else if ((self.pointsButton.selectedSegmentIndex == 2) && (self.type == COMPETITIONS)) {
        leaderboardAtIndex = [self.dataController.userinfangroupCompetitionLeaderboard objectAtIndex:indexPath.row];
    }
    
    NSString *rankString;
    if ((leaderboardAtIndex.rank == -1) || (leaderboardAtIndex.rank == 0) || (leaderboardAtIndex.rank == LARGESTRANK))
        rankString = @"-";
    else
        rankString = [NSString stringWithFormat:@"%d", (int)leaderboardAtIndex.rank];
    
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
    return [self headerView];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [[self headerView] bounds].size.height;
}


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

- (IBAction)changePoints:(id)sender
{
    [self.tableView reloadData];
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
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"SELECT", @"CANCEL", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = COMPETITIONS;
    
    UIPickerView *picker;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 150, 320, 320)];
    else
        picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 100, 320, 216)];
    picker.showsSelectionIndicator=YES;
    picker.dataSource = self;
    picker.delegate = self;
    picker.tag = COMPETITIONS;
    
    
    [actionSheet addSubview:picker];
    [picker selectRow:0 inComponent:0 animated:NO];
    [actionSheet showInView:self.view];
    [actionSheet setBounds:CGRectMake(0, 0, 320, 580)];
    
}


- (IBAction)submitGame:(id)sender {
    
    if ([self.dataController.gameList count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Games" message:@"You have not entered any games!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"SELECT", @"CANCEL", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = GAMES;
    
    
    UIPickerView *picker;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 150, 320, 320)];
    else
        picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 100, 320, 216)];
    picker.showsSelectionIndicator=YES;
    picker.dataSource = self;
    picker.delegate = self;
    picker.tag = GAMES;
    
    
    [actionSheet addSubview:picker];
    [picker selectRow:0 inComponent:0 animated:NO];
    [actionSheet showInView:self.view];
    [actionSheet setBounds:CGRectMake(0, 0, 320, 580)];
}


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

- (void)refresh:(NSInteger)type {
    NSSortDescriptor *rankSorter = [[NSSortDescriptor alloc] initWithKey:@"rank" ascending:YES];
    NSSortDescriptor *nameSorter = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    if (type == GAMES) {
        [self.dataController.globalGameLeaderboard sortUsingDescriptors:[NSArray arrayWithObjects:rankSorter, nameSorter, nil]];
        [self.dataController.fangroupGameLeaderboard sortUsingDescriptors:[NSArray arrayWithObjects:rankSorter, nameSorter, nil]];
        [self.dataController.userinfangroupGameLeaderboard sortUsingDescriptors:[NSArray arrayWithObjects:rankSorter, nameSorter, nil]];
    } else if (type == COMPETITIONS) {
        [self.dataController.globalCompetitionLeaderboard sortUsingDescriptors:[NSArray arrayWithObjects:rankSorter, nameSorter, nil]];
        [self.dataController.fangroupCompetitionLeaderboard sortUsingDescriptors:[NSArray arrayWithObjects:rankSorter, nameSorter, nil]];
        [self.dataController.userinfangroupCompetitionLeaderboard sortUsingDescriptors:[NSArray arrayWithObjects:rankSorter, nameSorter, nil]];
    }
    [self.tableView reloadData];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                             [formatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    [self.refreshControl endRefreshing];
    // [activityIndicator stopAnimating];
    self.isLoading = NO;
}

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


- (void)getLeaderboard:(NSInteger)gameID type:(NSInteger)type title:(NSString *)title
{
    // global leaderboard
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path;
    if (type == GAMES)
        path = [NSString stringWithFormat:@"game/leaderboard?game_id=%d&type=global", gameID];
    else if (type == COMPETITIONS)
        path = [NSString stringWithFormat:@"competition/leaderboard?comp_id=%d&type=global", gameID];
    [objectManager getObjectsAtPath:path parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         self.title = title;
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
        if (temp.count == 100) {
             Leaderboard *leaderboard = [[Leaderboard alloc] initWithRank:LARGESTRANK name:@"TOP 100 Returned" points:@"-" winnings:@"-"];
             if (type == GAMES)
                 [self.dataController.globalGameLeaderboard addObject:leaderboard];
             else if (type == COMPETITIONS)
                 [self.dataController.globalCompetitionLeaderboard addObject:leaderboard];
        } else if ((temp.count == 0) && (type == COMPETITIONS)) {
            Leaderboard *leaderboard = [[Leaderboard alloc] initWithRank:LARGESTRANK name:@"No Games Completed" points:@"-" winnings:@"-"];
            [self.dataController.globalCompetitionLeaderboard addObject:leaderboard];
        }
        [self getFangroupLeaderboard:gameID type:type];
        
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
        path2 = [NSString stringWithFormat:@"game/leaderboard?game_id=%d&type=fangroup", gameID];
    else if (type == COMPETITIONS)
        path2 = [NSString stringWithFormat:@"competition/leaderboard?comp_id=%d&type=fangroup", gameID];
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
             Leaderboard *leaderboard = [[Leaderboard alloc] initWithRank:LARGESTRANK name:@"No Games Completed" points:@"-" winnings:@"-"];
             [self.dataController.fangroupCompetitionLeaderboard addObject:leaderboard];
         }
        [self getUserinfangroupLeaderboard:gameID type:type];
        
     } failure:^(RKObjectRequestOperation *operation, NSError *error){
         [self.refreshControl endRefreshing];
         self.isLoading = NO;
     }];
}
    
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

- (void)getPoints:(NSInteger)gameID
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"game/points?game_id=%d&includeSelections=false", gameID];
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
        [self refresh:GAMES];
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        [self.refreshControl endRefreshing];
        self.isLoading = NO;
    }];
}

- (void)getCompetitionPoints:(NSInteger)gameID
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"competition/points?comp_id=%d", gameID];
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
         [self refresh:COMPETITIONS];
     } failure:^(RKObjectRequestOperation *operation, NSError *error){
         [self.refreshControl endRefreshing];
         self.isLoading = NO;
     }];
}


@end
