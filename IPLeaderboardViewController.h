//
//  IPLeaderboardViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 22/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Leaderboard;
@class LeaderboardDataController;
@class Game;
@class IPGameViewController;
@class FriendPool;
@class IPAddFriendsViewController;

@interface IPLeaderboardViewController : UITableViewController <UIAlertViewDelegate>
{
    IBOutlet UIView *headerView;
    IBOutlet UIView *compHeaderView;
//    IBOutlet UIView *footerView;
    UIView *myView;
}


- (UIView *)headerView;
- (UIView *)compHeaderView;
// - (UIView *)footerView;
// - (IBAction)submitCompetition:(id)sender;
- (IBAction)changePoints:(id)sender;
// - (IBAction)submitGame:(id)sender;
// - (void)getCompetitions:(id)sender;
// - (void)getGames:(id)sender;
- (void)getLeaderboard:(NSInteger)gameID type:(NSInteger)type;
- (void)getFangroupLeaderboard:(NSInteger)gameID type:(NSInteger)type;
- (void)getFriendLeaderboard:(NSInteger)gameID poolID:(NSInteger)poolID type:(NSInteger)type;
- (void)refresh:(NSInteger)type;


@property (strong, nonatomic) Leaderboard *leaderboard;
@property (strong, nonatomic) LeaderboardDataController *dataController;
@property (weak, nonatomic) IBOutlet UIImageView *inplayIndicator;
// @property (weak, nonatomic) IBOutlet UIButton *competitionButton;
// @property (weak, nonatomic) IBOutlet UIButton *gameButton;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *pointsButton;
@property (weak, nonatomic) IBOutlet UILabel *rankHeader;
@property (weak, nonatomic) IBOutlet UILabel *nameHeader;
@property (weak, nonatomic) IBOutlet UILabel *pointsHeader;
@property (weak, nonatomic) IBOutlet UILabel *winningsHeader;
@property (weak, nonatomic) NSString *left;
// @property (nonatomic) NSInteger selectedCompetitionID;
// @property (nonatomic) NSInteger selectedGameID;
// @property (nonatomic) NSInteger selectedCompetitionRow;
// @property (nonatomic) NSInteger selectedGameRow;
@property (nonatomic) NSInteger type;
@property (nonatomic) BOOL isLoading;
@property (strong, nonatomic) Game *game;
@property (strong, nonatomic) FriendPool *friendPool;
@property (strong, nonatomic) NSMutableDictionary *controllerList;
@property (strong, nonatomic) IPGameViewController *detailViewController;
@property (nonatomic) NSInteger lbType;
@property (nonatomic) NSInteger competitionID;
@property (weak, nonatomic) NSString *competitionName;
@property (strong, nonatomic) IPAddFriendsViewController *addFriendsViewController;
@property (nonatomic) BOOL fromWinners;

@end
