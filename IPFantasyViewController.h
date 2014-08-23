//
//  IPFantasyViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 22/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Game;
@class GameDataController;
@class Selection;
@class IPLeaderboardViewController;
@class IPMultiLoginViewController;
@class IPTutorialViewController;
@class IPCreateViewController;
@class FriendPool;
@class IPAddFriendsViewController;
@class IPStatsViewController;
@class PeriodOptions;
@class IPFantasyResultViewController;

@interface IPFantasyViewController : UITableViewController <UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    IBOutlet UIView *headerView;
    IBOutlet UIView *footerView;
    NSTimer *timer;
    UIView *myView;
}


- (UIView *)headerView;
- (UIView *)footerView;
- (IBAction)submitSelections:(id)sender;
- (void)getPeriods:(id)sender;
- (void)getPoints;
- (void)refresh:(id)sender;
- (void)postSelections:(NSMutableArray *)postSelectionList;
- (void)sortSelections;
- (IBAction)friendClicked:(id)sender;
- (IBAction)globalClicked:(id)sender;
- (IBAction)h2hClicked:(id)sender;
- (void) addFriends:(NSNotification *)notification;

@property (strong, nonatomic) Game *game;
@property (strong, nonatomic) GameDataController *dataController;
@property (strong, nonatomic) IPLeaderboardViewController *leaderboardViewController;
@property (strong, nonatomic) IPMultiLoginViewController *multiLoginViewController;
@property (strong, nonatomic) IPTutorialViewController *tutorialViewController;
@property (strong, nonatomic) IPCreateViewController *createViewController;
@property (strong, nonatomic) IPLeaderboardViewController *globalViewController;
@property (strong, nonatomic) IPLeaderboardViewController *friendViewController;
@property (strong, nonatomic) IPStatsViewController *statsViewController;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *friendButton;
@property (weak, nonatomic) IBOutlet UILabel *globalLabel;
@property (weak, nonatomic) IBOutlet UILabel *h2hLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendLabel;
@property (weak, nonatomic) IBOutlet UILabel *global1;
@property (weak, nonatomic) IBOutlet UILabel *global2;
@property (weak, nonatomic) IBOutlet UILabel *h2h1;
@property (weak, nonatomic) IBOutlet UILabel *h2h2;
@property (weak, nonatomic) IBOutlet UILabel *friend1;
@property (weak, nonatomic) IBOutlet UILabel *friend2;
@property (weak, nonatomic) IBOutlet UIButton *globalButton;
@property (weak, nonatomic) IBOutlet UIButton *h2hButton;
@property (weak, nonatomic) IBOutlet UIImageView *inplayIndicator;


@property (nonatomic) NSInteger selectedRow;
@property (nonatomic) BOOL isLoaded;
@property (nonatomic) BOOL isUpdated;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL pointsChanged;
@property (weak, nonatomic) NSString *oldPoints;
@property (nonatomic) NSInteger oldState;
@property (nonatomic) NSString *username;
@property (nonatomic, copy) NSMutableArray *friendPools;
@property (nonatomic, copy) NSMutableDictionary *periodOptionList;
@property (nonatomic, copy) NSMutableArray *changeSelectionList;
@property (nonatomic, copy) NSMutableDictionary *friendControllerList;
@property (nonatomic, weak) FriendPool *selectedFriendPool;
@property (nonatomic, weak) PeriodOptions *selectedPeriodOption;
@property (strong, nonatomic) IPAddFriendsViewController *addFriendsViewController;
@property (nonatomic) BOOL fromLeaderboard;
@property (strong, nonatomic) IPFantasyResultViewController *detailViewController;
@property (strong, nonatomic) NSMutableDictionary *controllerList;

@end