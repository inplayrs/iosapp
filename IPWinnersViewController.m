//
//  IPWinnersViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPWinnersViewController.h"
#import "MFSideMenu.h"
#import "RestKit.h"
#import "CompetitionWinners.h"
#import "GameWinners.h"
#import "OverallWinners.h"
#import "IPAppDelegate.h"
#import "Error.h"
#import "IPLeaderboardViewController.h"
#import "IPStatsViewController.h"
#import "Game.h"
#import "Competition.h"


enum Category {
    FOOTBALL=10,
    TENNIS=11,
    SNOOKER=12,
    MOTORRACING=13,
    CRICKET=14,
    GOLF=15,
    RUGBY=16,
    BASEBALL=20,
    BASKETBALL=21,
    ICEHOCKEY=22,
    AMERICANFOOTBALL=23,
    FINANCE=30,
    REALITYTV=31,
    AWARDS=32
};

@interface IPWinnersViewController ()

@end

@implementation IPWinnersViewController

@synthesize competitionWinnersList, gameWinnersList, overallWinnersList, winnersTab, gameControllerList, competitionControllerList, overallControllerList, statsViewController, gameViewController, competitionViewController;

- (void) dealloc {
    self.navigationController.sideMenu.menuStateEventBlock = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    competitionWinnersList = [[NSMutableArray alloc] init];
    gameWinnersList = [[NSMutableArray alloc] init];
    overallWinnersList = [[NSMutableArray alloc] init];
    self.title = @"Winners";
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-only.png"]];
    gameControllerList = [[NSMutableDictionary alloc] init];
    competitionControllerList = [[NSMutableDictionary alloc] init];
    overallControllerList = [[NSMutableDictionary alloc] init];
    statsViewController = nil;
    gameViewController = nil;
    competitionViewController = nil;
    // gameList = [[NSMutableDictionary alloc] init];
    
    // this isn't needed on the rootViewController of the navigation controller
    [self.navigationController.sideMenu setupSideMenuBarButtonItem];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // [self getGames:self];
    // [self getCompetitions:self];
    [self getGameWinnersList:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getCompetitionWinnersList:(id)sender
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager getObjectsAtPath:@"competition/winners" parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [competitionWinnersList removeAllObjects];
        NSArray* temp = [result array];
        for (int i=0; i<temp.count; i++) {
            CompetitionWinners *competitionWinners = [temp objectAtIndex:i];
            if (!competitionWinners.name)
                competitionWinners.name = @"Unassigned";
            [competitionWinnersList addObject:competitionWinners];
        }
        [competitionWinnersList sortUsingSelector:@selector(compareWithDate:)];
        [self getOverallWinnersList:self];
    } failure:nil];
}

- (void)getGameWinnersList:(id)sender
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager getObjectsAtPath:@"game/winners" parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         [gameWinnersList removeAllObjects];
         NSArray* temp = [result array];
         for (int i=0; i<temp.count; i++) {
             GameWinners *gameWinners = [temp objectAtIndex:i];
             if (!gameWinners.name)
                 gameWinners.name = @"Unassigned";
             [gameWinnersList addObject:gameWinners];
         }
         [gameWinnersList sortUsingSelector:@selector(compareWithDate:)];
         [self getCompetitionWinnersList:self];
     } failure:nil];
}

- (void)getOverallWinnersList:(id)sender
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager getObjectsAtPath:@"user/leaderboard" parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         [overallWinnersList removeAllObjects];
         NSArray* temp = [result array];
         for (int i=0; i<temp.count; i++) {
             OverallWinners *overallWinners = [temp objectAtIndex:i];
             if (!overallWinners.username)
                 overallWinners.username = @"Unknown";
             if (!overallWinners.winnings)
                 overallWinners.winnings = @"";
             [overallWinnersList addObject:overallWinners];
         }
         NSSortDescriptor *rankSorter = [[NSSortDescriptor alloc] initWithKey:@"rank" ascending:YES];
         NSSortDescriptor *nameSorter = [[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
         [overallWinnersList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:rankSorter, nameSorter, nil]];
         [self.tableView reloadData];
     } failure:nil];
}

/*
- (void)getCompetitions:(id)sender
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager getObjectsAtPath:@"competition/list" parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         [competitionList removeAllObjects];
         NSArray* temp = [result array];
         for (int i=0; i<temp.count; i++) {
             Competition *competition = [temp objectAtIndex:i];
             if (!competition.name)
                 competition.name = @"Unassigned";
             // if (competition.entered)
                 [competitionList setObject:competition forKey:competition.name];
         }
     } failure:nil];
}
 */

/*
- (void)getGames:(id)sender
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager getObjectsAtPath:@"competition/games" parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         [gameList removeAllObjects];
         NSArray* temp = [result array];
         for (int i=0; i<temp.count; i++) {
             Game *game = [temp objectAtIndex:i];
             if (!game.name)
                 game.name = @"Unassigned";
             // if (game.entered)
                 [gameList setObject:game forKey:game.name];
         }
     } failure:nil];
    
}
 */

- (UIView *)headerView
{
    if (!headerView) {
        [[NSBundle mainBundle] loadNibNamed:@"IPWinnersHeaderView" owner:self options:nil];
        UIImage *segmentSelected = [UIImage imageNamed:@"segcontrol_sel.png"];
        UIImage *segmentUnselected = [UIImage imageNamed:@"segcontrol_uns.png"];
        UIImage *segmentSelectedUnselected = [UIImage imageNamed:@"segcontrol_sel-uns.png"];
        UIImage *segUnselectedSelected = [UIImage imageNamed:@"segcontrol_uns-sel.png"];
        UIImage *segmentUnselectedUnselected = [UIImage imageNamed:@"segcontrol_uns-uns.png"];
        
        [winnersTab setBackgroundImage:segmentUnselected forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [winnersTab setBackgroundImage:segmentSelected forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        [winnersTab setDividerImage:segmentUnselectedUnselected
                  forLeftSegmentState:UIControlStateNormal
                    rightSegmentState:UIControlStateNormal
                           barMetrics:UIBarMetricsDefault];
        [winnersTab setDividerImage:segmentSelectedUnselected
                  forLeftSegmentState:UIControlStateSelected
                    rightSegmentState:UIControlStateNormal
                           barMetrics:UIBarMetricsDefault];
        [winnersTab setDividerImage:segUnselectedSelected
                  forLeftSegmentState:UIControlStateNormal
                    rightSegmentState:UIControlStateSelected
                           barMetrics:UIBarMetricsDefault];
        NSDictionary *attributesUnselected = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Avalon-Demi" size:14.0],UITextAttributeFont,[UIColor colorWithRed:96/255.0 green:97/255.0 blue:120/255.0 alpha:1], UITextAttributeTextColor, nil];
        NSDictionary *attributesSelected = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Avalon-Demi" size:14.0],UITextAttributeFont,[UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1], UITextAttributeTextColor, nil];
        [winnersTab setTitleTextAttributes:attributesUnselected forState:UIControlStateNormal];
        [winnersTab setTitleTextAttributes:attributesSelected forState:UIControlStateSelected];
    }
    
    return headerView;
}


- (IBAction)switchTab:(id)sender {
    [self.tableView reloadData];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (winnersTab.selectedSegmentIndex == 0)
        return [gameWinnersList count];
    else if (winnersTab.selectedSegmentIndex == 1)
        return [competitionWinnersList count];
    else
        return [overallWinnersList count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2) {
        cell.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:62/255.0 alpha:1];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (winnersTab.selectedSegmentIndex == 2) {
        static NSString *CellIdentifier = @"overallWinnersCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        OverallWinners *overallWinners;
        overallWinners = [overallWinnersList objectAtIndex:indexPath.row];
        NSString *winners = [NSString stringWithFormat:@"%ld", (long)overallWinners.rank];
        winners = [winners stringByAppendingString:@"    "];
        winners = [winners stringByAppendingString:overallWinners.username];
        
        // UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-row.png"]];
        // [cell setBackgroundView:imageView];
        if (indexPath.row % 2) {
            cell.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:62/255.0 alpha:1];
            cell.contentView.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:62/255.0 alpha:1];
        } else {
            cell.backgroundColor = [UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1];
            cell.contentView.backgroundColor = [UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1];
        }
        cell.textLabel.text = winners;
        cell.detailTextLabel.text = [@"$" stringByAppendingString:overallWinners.winnings];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0];
        // cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:14.0];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:14.0];
        return cell;
    } else {
        static NSString *CellIdentifier = @"winnersCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        CompetitionWinners *competitionWinners;
        if (winnersTab.selectedSegmentIndex == 0)
            competitionWinners = [gameWinnersList objectAtIndex:indexPath.row];
        else
            competitionWinners = [competitionWinnersList objectAtIndex:indexPath.row];
        NSString *competition = [competitionWinners.name stringByReplacingOccurrencesOfString:@":" withString:@""];
        competition = [competition stringByAppendingString:@":  "];
        NSString *winners = @"";
        if ([competitionWinners.winners count] > 0) {
            if ([competitionWinners.winners objectAtIndex:0])
                winners = [competitionWinners.winners objectAtIndex:0];
        }
        for (int i=1; i<[competitionWinners.winners count]; i++) {
            NSString *string = [competitionWinners.winners objectAtIndex:i];
            winners = [winners stringByAppendingFormat:@", %@", string];
        }
        competition = [competition stringByAppendingString:winners];
    
        // UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-row.png"]];
        // [cell setBackgroundView:imageView];
        if (indexPath.row % 2) {
            cell.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:62/255.0 alpha:1];
            cell.contentView.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:62/255.0 alpha:1];
        } else {
            cell.backgroundColor = [UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1];
            cell.contentView.backgroundColor = [UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1];
        }
        cell.textLabel.text = competition;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:14.0];
    
        switch (competitionWinners.category) {
            case (FOOTBALL): {
                UIImage *image = [UIImage imageNamed: @"football.png"];
                cell.imageView.image = image;
                break;
            }
            case (BASKETBALL): {
                UIImage *image = [UIImage imageNamed: @"basketball.png"];
                cell.imageView.image = image;
                break;
            }
            case (TENNIS): {
                UIImage *image = [UIImage imageNamed: @"tennis.png"];
                cell.imageView.image = image;
                break;
            }
            case (GOLF): {
                UIImage *image = [UIImage imageNamed: @"golf.png"];
                cell.imageView.image = image;
                break;
            }
            case (SNOOKER): {
                UIImage *image = [UIImage imageNamed: @"snooker.png"];
                cell.imageView.image = image;
                break;
            }
            case (MOTORRACING): {
                UIImage *image = [UIImage imageNamed: @"motor-racing.png"];
                cell.imageView.image = image;
                break;
            }
            case (CRICKET): {
                UIImage *image = [UIImage imageNamed: @"cricket.png"];
                cell.imageView.image = image;
                break;
            }
            case (RUGBY): {
                UIImage *image = [UIImage imageNamed: @"rugby.png"];
                cell.imageView.image = image;
                break;
            }
            case (BASEBALL): {
                UIImage *image = [UIImage imageNamed: @"baseball.png"];
                cell.imageView.image = image;
                break;
            }
            case (ICEHOCKEY): {
                UIImage *image = [UIImage imageNamed: @"ice-hockey.png"];
                cell.imageView.image = image;
                break;
            }
            case (AMERICANFOOTBALL): {
                UIImage *image = [UIImage imageNamed: @"american-football.png"];
                cell.imageView.image = image;
                break;
            }
            case (FINANCE): {
                UIImage *image = [UIImage imageNamed: @"finance.png"];
                cell.imageView.image = image;
                break;
            }
            case (REALITYTV): {
                UIImage *image = [UIImage imageNamed: @"reality-tv.png"];
                cell.imageView.image = image;
                break;
            }
            case (AWARDS): {
                UIImage *image = [UIImage imageNamed: @"awards.png"];
                cell.imageView.image = image;
                break;
            }
            default: {
                UIImage *image = [UIImage imageNamed: @"football.png"];
                cell.imageView.image = image;
                break;
            }
        }
        return cell;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self headerView];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [[self headerView] bounds].size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (winnersTab.selectedSegmentIndex == 0) { // game
        GameWinners *gameWinners = [gameWinnersList objectAtIndex:indexPath.row];
        if ([gameControllerList objectForKey:gameWinners.name] == nil) {
            gameViewController = [[IPLeaderboardViewController alloc] initWithNibName:@"IPLeaderboardViewController" bundle:nil];
            // gameViewController.game = [gameList objectForKey:competitionWinners.name];
            Game *game = [[Game alloc] initWithGameID:gameWinners.gameID name:gameWinners.name startDate:@"" state:gameWinners.state category:gameWinners.category type:gameWinners.type entered:NO inplayType:gameWinners.inplayType competitionID:gameWinners.competitionID];
            gameViewController.game = game;
            gameViewController.lbType = 0;
            gameViewController.fromWinners = YES;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
            else
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
            [gameControllerList setObject:gameViewController forKey:gameWinners.name];
        }
        if ([gameControllerList objectForKey:gameWinners.name]) {
            [self.navigationController pushViewController:[gameControllerList objectForKey:gameWinners.name] animated:YES];
        }
    } else if (winnersTab.selectedSegmentIndex == 1) { // competition
        CompetitionWinners *competitionWinners = [competitionWinnersList objectAtIndex:indexPath.row];
        if ([competitionControllerList objectForKey:competitionWinners.name] == nil) {
            competitionViewController = [[IPLeaderboardViewController alloc] initWithNibName:@"IPLeaderboardViewController" bundle:nil];
            competitionViewController.competitionName = competitionWinners.name;
            competitionViewController.lbType = 0;
            competitionViewController.competitionID = competitionWinners.competitionID;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
            else
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
            [competitionControllerList setObject:competitionViewController forKey:competitionWinners.name];
        }
        if ([competitionControllerList objectForKey:competitionWinners.name]) {
            [self.navigationController pushViewController:[competitionControllerList objectForKey:competitionWinners.name] animated:YES];
        }
        
    } else { // overall winners
        OverallWinners *overallWinners = [overallWinnersList objectAtIndex:indexPath.row];
        if ([overallControllerList objectForKey:overallWinners.username] == nil) {
            statsViewController = [[IPStatsViewController alloc] initWithNibName:@"IPStatsViewController" bundle:nil];
            statsViewController.externalUsername = overallWinners.username;
            if (overallWinners.fbID)
                statsViewController.externalFBID = overallWinners.fbID;
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil];
            [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
            [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
            else
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
            [overallControllerList setObject:statsViewController forKey:overallWinners.username];
        }
        if ([overallControllerList objectForKey:overallWinners.username]) {
            [self.navigationController pushViewController:[overallControllerList objectForKey:overallWinners.username] animated:YES];
        }
    }
    return;
}


@end
