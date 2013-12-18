//
//  IPStatsViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 07/11/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface IPStatsViewController : UIViewController


@property (weak, nonatomic) IBOutlet UILabel *totalWinningsLabel;
@property (weak, nonatomic) IBOutlet UILabel *globalRankLabel;
@property (weak, nonatomic) IBOutlet UILabel *gamesPlayedLabel;
@property (weak, nonatomic) IBOutlet UILabel *correctLabel;
@property (weak, nonatomic) IBOutlet UILabel *winningsLabel;
@property (weak, nonatomic) IBOutlet UILabel *winsLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalWinnings;
@property (weak, nonatomic) IBOutlet UILabel *globalRank;
@property (weak, nonatomic) IBOutlet UILabel *gamesPlayed;
@property (weak, nonatomic) IBOutlet UILabel *correct;
@property (weak, nonatomic) IBOutlet UILabel *rating;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;
@property (weak, nonatomic) IBOutlet UIImageView *noProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *winningsChart;
@property (weak, nonatomic) IBOutlet UILabel *winsChart;

@property (nonatomic) NSInteger globalWinnings;
@property (nonatomic) NSInteger fangroupWinnings;
@property (nonatomic) NSInteger h2hWinnings;
@property (nonatomic) NSInteger globalWins;
@property (nonatomic) NSInteger fangroupWins;
@property (nonatomic) NSInteger h2hWins;
@property (nonatomic) NSInteger totalChartWins;

@end
