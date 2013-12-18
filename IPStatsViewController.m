//
//  IPStatsViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 07/11/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPStatsViewController.h"
#import "MFSideMenu.h"
#import "RestKit.h"
#import "Flurry.h"
#import "Stats.h"
#import "IPAppDelegate.h"
#import "PieChartView.h"

@interface IPStatsViewController () <PieChartViewDelegate, PieChartViewDataSource>
{
    PieChartView *pieChartViewLeft;
    PieChartView *pieChartViewRight;
    UILabel *holeLabel;
    UILabel *valueLabel;
}

@end

@implementation IPStatsViewController


@synthesize totalWinningsLabel, globalRankLabel, gamesPlayedLabel, correctLabel, winningsLabel, winsLabel, totalWinnings, globalRank, gamesPlayed, correct, rating, usernameLabel, noProfileImage, winningsChart, winsChart, totalChartWins;

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
	self.title = @"Stats";
    [self.navigationController.sideMenu setupSideMenuBarButtonItem];
    
    self.totalWinningsLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:16.0];
    self.globalRankLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:16.0];
    self.gamesPlayedLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:16.0];
    self.correctLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:16.0];
    self.winningsLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:16.0];
    self.winsLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:16.0];
    self.usernameLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.loggedin) {
        self.usernameLabel.text = appDelegate.user;
        if (FBSession.activeSession.isOpen) {
            [[FBRequest requestForMe] startWithCompletionHandler:
             ^(FBRequestConnection *connection,
               NSDictionary<FBGraphUser> *user,
               NSError *error) {
                 if (!error) {
                     self.userProfileImage.profileID = user.id;
                 }
             }];
            [self.noProfileImage setHidden:YES];
        } else {
            UIImage *image = [UIImage imageNamed: @"user.png"];
            [self.noProfileImage setImage:image];
            [self.noProfileImage setHidden:NO];
        }
        [self getStats:appDelegate.user];
    } else {
        self.usernameLabel.text = @"";
        self.userProfileImage.profileID = nil;
        UIImage *image = [UIImage imageNamed: @"user.png"];
        [self.noProfileImage setImage:image];
        [self.noProfileImage setHidden:NO];
        self.totalWinnings.text = @"$0";
        self.globalRank.text = @"-";
        self.gamesPlayed.text = @"0";
        self.correct.text = @"-";
        self.rating.text = @"";
        self.winningsChart.text = @"";
        self.winsChart.text = @"";
        self.globalWinnings = 0;
        self.fangroupWinnings = 0;
        self.h2hWinnings = 0;
        self.globalWins = 0;
        self.fangroupWins = 0;
        self.h2hWins = 0;
        [pieChartViewLeft setHidden:YES];
        [pieChartViewRight setHidden:YES];
    }
}


- (void)drawPieCharts
{
    pieChartViewLeft = [[PieChartView alloc] initWithFrame:CGRectMake(20, 245, 120, 120)];
    pieChartViewLeft.delegate = self;
    pieChartViewLeft.datasource = self;
    [self.view addSubview:pieChartViewLeft];
    self.winningsChart.text = self.totalWinnings.text;
    
    pieChartViewRight = [[PieChartView alloc] initWithFrame:CGRectMake(180, 245, 120, 120)];
    pieChartViewRight.delegate = self;
    pieChartViewRight.datasource = self;
    [self.view addSubview:pieChartViewRight];
    self.winsChart.text = [NSString stringWithFormat:@"%d", totalChartWins];
    
    [pieChartViewLeft setHidden:NO];
    [pieChartViewRight setHidden:NO];
    
    [pieChartViewLeft reloadData];
    [pieChartViewRight reloadData];
}

- (void)getStats:(NSString *)username
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"user/stats?username=%@", username];
    [objectManager getObjectsAtPath:path parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         Stats *stats = [result firstObject];
         float gWinnings=0;
         float fWinnings=0;
         float hWinnings=0;
         float total=0;
         float gWins=0;
         float fWins=0;
         float hWins=0;
         float totalWins=0;
         if (!stats.totalWinnings)
             self.totalWinnings.text = @"";
         else
             self.totalWinnings.text = [@"$" stringByAppendingString:stats.totalWinnings];
         if ((!stats.totalRank) || (!stats.totalUsers))
             self.globalRank.text = @"";
         else
             self.globalRank.text = [stats.totalRank stringByAppendingFormat:@"/%@", stats.totalUsers];
         if (!stats.totalGames)
             self.gamesPlayed.text = @"";
         else
             self.gamesPlayed.text = stats.totalGames;
         if (!stats.totalCorrect)
             self.correct.text = @"";
         else
             self.correct.text = [stats.totalCorrect stringByAppendingString:@"%"];
         if (!stats.userRating)
             self.rating.text = @"";
         else
             self.rating.text = stats.userRating;
         if (!stats.globalWinnings)
             self.globalWinnings = 0;
         else
             gWinnings = [stats.globalWinnings floatValue];
         if (!stats.fangroupWinnings)
             self.fangroupWinnings = 0;
         else
             fWinnings = [stats.fangroupWinnings floatValue];
         if (!stats.h2hWinnings)
             self.h2hWinnings = 0;
         else
             hWinnings = [stats.h2hWinnings floatValue];
         total = gWinnings + fWinnings + hWinnings;
         if (total > 0) {
             self.globalWinnings = roundf((gWinnings/total)*100);
             self.fangroupWinnings = roundf((fWinnings/total)*100);
             self.h2hWinnings = roundf((hWinnings/total)*100);
         }
         if (!stats.globalWon)
             self.globalWins = 0;
         else
             gWins = [stats.globalWon floatValue];
         if (!stats.fangroupWon)
             self.fangroupWins = 0;
         else
             fWins = [stats.fangroupWon floatValue];
         if (!stats.h2hWon)
             self.h2hWins = 0;
         else
             hWins = [stats.h2hWon floatValue];
         totalWins = gWins + fWins + hWins;
         totalChartWins = totalWins;
         if (totalWins > 0) {
             self.globalWins = roundf((gWins/totalWins)*100);
             self.fangroupWins = roundf((fWins/totalWins)*100);
             self.h2hWins = roundf((hWins/totalWins)*100);
         }
         [self drawPieCharts];
     } failure:^(RKObjectRequestOperation *operation, NSError *error){
         self.totalWinnings.text = @"$0";
         self.globalRank.text = @"-";
         self.gamesPlayed.text = @"0";
         self.correct.text = @"-";
         self.rating.text = @"";
         self.winningsChart.text = @"";
         self.winsChart.text = @"";
         self.globalWinnings = 0;
         self.fangroupWinnings = 0;
         self.h2hWinnings = 0;
         self.globalWins = 0;
         self.fangroupWins = 0;
         self.h2hWins = 0;
         [pieChartViewLeft setHidden:YES];
         [pieChartViewRight setHidden:YES];
         
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -    PieChartViewDelegate

-(CGFloat)centerCircleRadius
{
    return 35;
}

#pragma mark - PieChartViewDataSource

-(int)numberOfSlicesInPieChartView:(PieChartView *)pieChartView
{
    return 3;
}

-(UIColor *)pieChartView:(PieChartView *)pieChartView colorForSliceAtIndex:(NSUInteger)index
{
    UIColor *color;
    if (index == 0)
        color = [UIColor colorWithRed:246/255.0 green:155/255.0 blue:0/255.0 alpha:1];
    else if (index == 1)
        color = [UIColor colorWithRed:129/255.0 green:195/255.0 blue:29/255.0 alpha:1];
    else
        color = [UIColor colorWithRed:62/255.0 green:173/255.0 blue:219/255.0 alpha:1];
    return color;
}

-(double)pieChartView:(PieChartView *)pieChartView valueForSliceAtIndex:(NSUInteger)index
{
    if ((index == 0) && (pieChartView == pieChartViewLeft))
        return self.globalWinnings;
    else if ((index == 1) && (pieChartView == pieChartViewLeft))
        return self.fangroupWinnings;
    else if (pieChartView == pieChartViewLeft)
        return self.h2hWinnings;
    else if (index == 0)
        return self.globalWins;
    else if (index == 1)
        return self.fangroupWins;
    else
        return self.h2hWins;
}


@end
