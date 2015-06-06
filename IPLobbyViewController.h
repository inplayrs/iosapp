//
//  IPLobbyViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 22/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IPGameViewController;
@class IPMultiLoginViewController;
@class IPStatsViewController;
@class IPFantasyViewController;
@class IPPhotoViewController;

@interface IPLobbyViewController : UITableViewController
{
    int currentExpandedIndex;
    int imageIndex;
    IBOutlet UIView *headerView;
    NSTimer *timer;
}

- (UIView *)headerView;
- (void)getGames:(NSInteger)competitionID order:(NSUInteger)order competitionName:(NSString *)competitionName;
- (void)getCompetitions:(id)sender;

@property (strong, nonatomic) IPGameViewController *detailViewController;
@property (strong, nonatomic) IPFantasyViewController *fantasyViewController;
@property (strong, nonatomic) IPPhotoViewController *photoViewController;
@property (strong, nonatomic) IPMultiLoginViewController *multiLoginViewController;
@property (strong, nonatomic) IPStatsViewController *statsViewController;
@property (strong, nonatomic) NSMutableDictionary *controllerList;
@property (nonatomic) BOOL gamesLoading;
@property (nonatomic, copy) NSMutableArray *topItems;
@property (nonatomic, copy) NSMutableArray *subItems;
@property (nonatomic, copy) NSMutableArray *tempTopItems;
@property (nonatomic, copy) NSMutableArray *tempSubItems;
@property (nonatomic, copy) NSMutableArray *bannerItems;
@property (nonatomic, copy) NSMutableArray *bannerImages;
@property (nonatomic) NSInteger gamesRequested;
@property (nonatomic) NSInteger gamesResponded;
@property (weak, nonatomic) IBOutlet UIButton *bannerButton;
- (IBAction)clickBanner:(id)sender;


@end
