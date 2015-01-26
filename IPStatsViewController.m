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
#import "IPTrophyViewController.h"

@interface IPStatsViewController () <PieChartViewDelegate, PieChartViewDataSource>
{
    PieChartView *pieChartViewLeft;
    PieChartView *pieChartViewRight;
    UILabel *holeLabel;
    UILabel *valueLabel;
}

@end

@implementation IPStatsViewController


@synthesize winningsLabel, winsLabel, usernameLabel, noProfileImage, winningsChart, winsChart, totalChartWins, externalUsername, externalFBID, totalWinnings, globalRank, gamesPlayed, correctPicks, statsTableView, trophyButton, trophyViewController, titleLabel;

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
    
    self.winningsLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:16.0];
    self.winsLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:16.0];
    self.usernameLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:16.0];
    self.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:16.0];
    self.view.backgroundColor = [UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1];
    [statsTableView setBackgroundColor:[UIColor clearColor]];
    trophyViewController = nil;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (externalUsername) {
        if ((FBSession.activeSession.isOpen) && (externalFBID)) {
            self.userProfileImage.profileID = externalFBID;
            self.userProfileImage.layer.cornerRadius = 30.0;
            [self.noProfileImage setHidden:YES];
            [self.userProfileImage setHidden:NO];
        } else {
            UIImage *image = [UIImage imageNamed: @"stats-avatar.png"];
            [self.userProfileImage setHidden:YES];
            [self.noProfileImage setImage:image];
            [self.noProfileImage setHidden:NO];
        }
        self.usernameLabel.text = externalUsername;
        [self getStats:externalUsername];
    } else if (appDelegate.loggedin) {
        self.usernameLabel.text = appDelegate.user;
        if (FBSession.activeSession.isOpen) {
            [[FBRequest requestForMe] startWithCompletionHandler:
             ^(FBRequestConnection *connection,
               NSDictionary<FBGraphUser> *user,
               NSError *error) {
                 if (!error) {
                     // self.userProfileImage.profileID = user.id;
                     self.userProfileImage.profileID = [user objectForKey:@"id"];
                     self.userProfileImage.layer.cornerRadius = 30.0;
                     externalFBID = [user objectForKey:@"id"];
                 }
             }];
            [self.noProfileImage setHidden:YES];
            [self.userProfileImage setHidden:NO];
        } else {
            UIImage *image = [UIImage imageNamed: @"stats-avatar.png"];
            [self.userProfileImage setHidden:YES];
            [self.noProfileImage setImage:image];
            [self.noProfileImage setHidden:NO];
        }
        [self getStats:appDelegate.user];
    } else {
        self.usernameLabel.text = @"";
        self.titleLabel.text = @"";
        self.userProfileImage.profileID = nil;
        UIImage *image = [UIImage imageNamed: @"stats-avatar.png"];
        [self.noProfileImage setImage:image];
        [self.noProfileImage setHidden:NO];
        [self.userProfileImage setHidden:YES];
        self.totalWinnings = @"$0";
        self.globalRank = @"-";
        self.gamesPlayed = @"0";
        self.correctPicks = @"-";
        // self.rating.text = @"";
        self.winningsChart.text = @"";
        self.winsChart.text = @"";
        self.globalWinnings = 0;
        // self.fangroupWinnings = 0;
        self.h2hWinnings = 0;
        self.globalWins = 0;
        // self.fangroupWins = 0;
        self.h2hWins = 0;
        [pieChartViewLeft setHidden:YES];
        [pieChartViewRight setHidden:YES];
    }
}


- (void)drawPieCharts
{
    pieChartViewLeft = [[PieChartView alloc] initWithFrame:CGRectMake(40, 314, 100, 100)];
    pieChartViewLeft.delegate = self;
    pieChartViewLeft.datasource = self;
    [self.view addSubview:pieChartViewLeft];
    self.winningsChart.text = self.totalWinnings;
    
    pieChartViewRight = [[PieChartView alloc] initWithFrame:CGRectMake(180, 314, 100, 100)];
    pieChartViewRight.delegate = self;
    pieChartViewRight.datasource = self;
    [self.view addSubview:pieChartViewRight];
    self.winsChart.text = [NSString stringWithFormat:@"%ld", (long)totalChartWins];
    
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
         float hWinnings=0;
         float total=0;
         float gWins=0;
         float hWins=0;
         float totalWins=0;
         if (!stats.totalWinnings)
             self.totalWinnings = @"";
         else
             self.totalWinnings = [@"$" stringByAppendingString:stats.totalWinnings];
         if ((!stats.totalRank) || (!stats.totalUsers))
             self.globalRank = @"";
         else
             self.globalRank = [stats.totalRank stringByAppendingFormat:@"/%@", stats.totalUsers];
         if (!stats.totalGames)
             self.gamesPlayed = @"";
         else
             self.gamesPlayed = stats.totalGames;
         if (!stats.totalCorrect)
             self.correctPicks = @"";
         else {
             self.correctPicks = [NSString stringWithFormat:@"%.1f", stats.totalCorrect];
             self.correctPicks = [self.correctPicks stringByAppendingString:@"%"];
         }
         if (!stats.userRating)
             self.titleLabel.text = @"";
         else
             self.titleLabel.text = stats.userRating;
         if (!stats.globalWinnings)
             self.globalWinnings = 0;
         else
             gWinnings = [stats.globalWinnings floatValue];
         /*
         if (!stats.fangroupWinnings)
             self.fangroupWinnings = 0;
         else
             fWinnings = [stats.fangroupWinnings floatValue];
          */
         if (!stats.h2hWinnings)
             self.h2hWinnings = 0;
         else
             hWinnings = [stats.h2hWinnings floatValue];
         total = gWinnings + hWinnings;
         if (total > 0) {
             self.globalWinnings = roundf((gWinnings/total)*100);
             // self.fangroupWinnings = roundf((fWinnings/total)*100);
             self.h2hWinnings = roundf((hWinnings/total)*100);
         }
         if (!stats.globalWon)
             self.globalWins = 0;
         else
             gWins = [stats.globalWon floatValue];
         /*
         if (!stats.fangroupWon)
             self.fangroupWins = 0;
         else
             fWins = [stats.fangroupWon floatValue];
          */
         if (!stats.h2hWon)
             self.h2hWins = 0;
         else
             hWins = [stats.h2hWon floatValue];
         totalWins = gWins + hWins;
         totalChartWins = totalWins;
         if (totalWins > 0) {
             self.globalWins = roundf((gWins/totalWins)*100);
             // self.fangroupWins = roundf((fWins/totalWins)*100);
             self.h2hWins = roundf((hWins/totalWins)*100);
         }
         [self drawPieCharts];
         [statsTableView reloadData];
     } failure:^(RKObjectRequestOperation *operation, NSError *error){
         self.totalWinnings = @"$0";
         self.globalRank = @"-";
         self.gamesPlayed = @"0";
         self.correctPicks = @"-";
         // self.rating.text = @"";
         self.winningsChart.text = @"";
         self.winsChart.text = @"";
         self.globalWinnings = 0;
         // self.fangroupWinnings = 0;
         self.h2hWinnings = 0;
         self.globalWins = 0;
         // self.fangroupWins = 0;
         self.h2hWins = 0;
         self.titleLabel.text = @"";
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
    return 36;
}

#pragma mark - PieChartViewDataSource

-(int)numberOfSlicesInPieChartView:(PieChartView *)pieChartView
{
    return 2;
}

-(UIColor *)pieChartView:(PieChartView *)pieChartView colorForSliceAtIndex:(NSUInteger)index
{
    UIColor *color;
    if (index == 0)
        // color = [UIColor colorWithRed:246/255.0 green:155/255.0 blue:0/255.0 alpha:1];
        color = [UIColor colorWithRed:255/255.0 green:224/255.0 blue:41/255.0 alpha:1];
    else if (index == 1)
        // color = [UIColor colorWithRed:129/255.0 green:195/255.0 blue:29/255.0 alpha:1];
        color = [UIColor colorWithRed:74/255.0 green:202/255.0 blue:180/255.0 alpha:1];
        // color = [UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:1];
    else
        // color = [UIColor colorWithRed:62/255.0 green:173/255.0 blue:219/255.0 alpha:1];
        color = [UIColor colorWithRed:255/255.0 green:129/255.0 blue:83/255.0 alpha:1];
    return color;
}

-(double)pieChartView:(PieChartView *)pieChartView valueForSliceAtIndex:(NSUInteger)index
{
    if ((index == 0) && (pieChartView == pieChartViewLeft))
        return self.globalWinnings;
    else if ((index == 1) && (pieChartView == pieChartViewLeft))
        return self.h2hWinnings;
    else if (index == 0)
        return self.globalWins;
    else
        return self.h2hWins;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"statsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:14.0];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:14.0];
    
    if (indexPath.row % 2) {
        cell.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:62/255.0 alpha:1];
        cell.contentView.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:62/255.0 alpha:1];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1];
        cell.contentView.backgroundColor = [UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1];
    }
    
    switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = @"Total Winnings";
            cell.detailTextLabel.text = self.totalWinnings;
            break;
        }
        case 1: {
            cell.textLabel.text = @"Global Rank";
            cell.detailTextLabel.text = self.globalRank;
            break;
        }
        case 2: {
            cell.textLabel.text = @"Games Played";
            cell.detailTextLabel.text = self.gamesPlayed;
            break;
        }
        case 3: {
            cell.textLabel.text = @"Correct Picks";
            cell.detailTextLabel.text = self.correctPicks;
            break;
        }
    }
    
    return cell;
}


- (IBAction)trophyClicked:(id)sender {
    if (!self.trophyViewController) {
        self.trophyViewController = [[IPTrophyViewController alloc] initWithNibName:@"IPTrophyView" bundle:nil];
        if (externalUsername)
            self.trophyViewController.externalUsername = externalUsername;
        else {
            IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
            self.trophyViewController.externalUsername = appDelegate.user;
        }
        self.trophyViewController.externalTitle = self.titleLabel.text;
        if (externalFBID)
            self.trophyViewController.externalFBID = externalFBID;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        else
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    }
    if (self.trophyViewController) {
        [self.navigationController pushViewController:self.trophyViewController animated:YES];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Trophy",
                                    @"click", nil];
        [Flurry logEvent:@"MENU" withParameters:dictionary];
    }
}
@end
