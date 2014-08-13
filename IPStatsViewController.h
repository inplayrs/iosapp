//
//  IPStatsViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 07/11/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface IPStatsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UILabel *winningsLabel;
@property (weak, nonatomic) IBOutlet UILabel *winsLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;
@property (weak, nonatomic) IBOutlet UIImageView *noProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *winningsChart;
@property (weak, nonatomic) IBOutlet UILabel *winsChart;
@property (weak, nonatomic) IBOutlet UITableView *statsTableView;

@property (strong, nonatomic) NSString *totalWinnings;
@property (strong, nonatomic) NSString *globalRank;
@property (strong, nonatomic) NSString *gamesPlayed;
@property (strong, nonatomic) NSString *correctPicks;

@property (nonatomic) NSInteger globalWinnings;
// @property (nonatomic) NSInteger fangroupWinnings;
@property (nonatomic) NSInteger h2hWinnings;
@property (nonatomic) NSInteger globalWins;
// @property (nonatomic) NSInteger fangroupWins;
@property (nonatomic) NSInteger h2hWins;
@property (nonatomic) NSInteger totalChartWins;
@property (nonatomic) NSString *externalUsername;
@property (nonatomic) NSString *externalFBID;

@end
