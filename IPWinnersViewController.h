//
//  IPWinnersViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IPStatsViewController;
@class IPLeaderboardViewController;

@interface IPWinnersViewController : UITableViewController
{
    IBOutlet UIView *headerView;
    
}

- (void)getCompetitionWinnersList:(id)sender;
- (void)getGameWinnersList:(id)sender;
- (void)getOverallWinnersList:(id)sender;
- (UIView *)headerView;
- (IBAction)switchTab:(id)sender;

@property (weak, nonatomic) IBOutlet UISegmentedControl *winnersTab;
@property (nonatomic, copy) NSMutableArray *competitionWinnersList;
@property (nonatomic, copy) NSMutableArray *gameWinnersList;
@property (nonatomic, copy) NSMutableArray *overallWinnersList;
@property (strong, nonatomic) NSMutableDictionary *competitionControllerList;
@property (strong, nonatomic) NSMutableDictionary *gameControllerList;
@property (strong, nonatomic) NSMutableDictionary *overallControllerList;
@property (strong, nonatomic) IPStatsViewController *statsViewController;
@property (strong, nonatomic) IPLeaderboardViewController *gameViewController;
@property (strong, nonatomic) IPLeaderboardViewController *competitionViewController;
// @property (strong, nonatomic) NSMutableDictionary *gameList;


@end
