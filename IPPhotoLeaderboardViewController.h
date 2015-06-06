//
//  IPPhotoLeaderboardViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 22/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoLeaderboard;
@class PhotoLeaderboardDataController;
@class IPPhotoResultViewController;
@class Game;


@interface IPPhotoLeaderboardViewController : UITableViewController <UIAlertViewDelegate>
{
    IBOutlet UIView *headerView;
}


- (UIView *)headerView;


@property (strong, nonatomic) PhotoLeaderboard *leaderboard;
@property (strong, nonatomic) PhotoLeaderboardDataController *dataController;
@property (weak, nonatomic) IBOutlet UIImageView *inplayIndicator;
@property (weak, nonatomic) IBOutlet UILabel *rankHeader;
@property (weak, nonatomic) IBOutlet UILabel *nameHeader;
@property (weak, nonatomic) IBOutlet UILabel *pointsHeader;
@property (weak, nonatomic) IBOutlet UILabel *winningsHeader;
@property (weak, nonatomic) IBOutlet UILabel *photoHeader;
@property (nonatomic) BOOL isLoading;
@property (strong, nonatomic) Game *game;
@property (strong, nonatomic) NSMutableDictionary *controllerList;
@property (strong, nonatomic) IPPhotoResultViewController *detailViewController;


@end
