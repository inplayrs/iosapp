//
//  IPGameViewController.h
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
@class IPFanViewController;
@class IPRegisterViewController;
@class IPTutorialViewController;

@interface IPGameViewController : UITableViewController <UIAlertViewDelegate>
{
    IBOutlet UIView *headerView;
    IBOutlet UIView *footerView;
    NSTimer *timer;
}


- (UIView *)headerView;
- (UIView *)footerView;
- (IBAction)submitSelections:(id)sender;
- (IBAction)changePoints:(id)sender;
- (void)getPeriods:(id)sender;
- (void)getPoints;
- (void)refresh:(id)sender;
- (void)postSelections;
- (void)postBank:(Selection *)selection;
- (void)sortSelections;

@property (strong, nonatomic) Game *game;
@property (strong, nonatomic) GameDataController *dataController;
@property (strong, nonatomic) IPLeaderboardViewController *leaderboardViewController;
@property (strong, nonatomic) IPFanViewController *fanViewController;
@property (strong, nonatomic) IPRegisterViewController *registerViewController;
@property (strong, nonatomic) IPTutorialViewController *tutorialViewController;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *pointsButton;
@property (weak, nonatomic) IBOutlet UILabel *selectionHeader1;
@property (weak, nonatomic) IBOutlet UILabel *selectionHeader2;
@property (weak, nonatomic) IBOutlet UILabel *selectionHeader3;
@property (weak, nonatomic) IBOutlet UILabel *selectionHeader4;
@property (weak, nonatomic) IBOutlet UILabel *selectionHeader5;


@property (weak, nonatomic) IBOutlet UIImageView *inplayIndicator;
@property (weak, nonatomic) NSString *left;
@property (nonatomic) NSInteger selectedRow;
@property (weak, nonatomic) NSString *selectionLabel0;
@property (weak, nonatomic) NSString *selectionLabel1;
@property (weak, nonatomic) NSString *selectionLabel2;
@property (nonatomic) BOOL isLoaded;
@property (nonatomic) BOOL isUpdated;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL pointsChanged;
@property (nonatomic) BOOL fangroupChallenge;
@property (weak, nonatomic) NSString *oldPoints;
@property (nonatomic) NSInteger oldState;


@end
