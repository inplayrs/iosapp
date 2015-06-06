//
//  IPPhotoLeaderboardViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 22/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPPhotoLeaderboardViewController.h"
#import "IPPhotoLeaderboardItemCell.h"
#import "PhotoLeaderboard.h"
#import "PhotoLeaderboardDataController.h"
#import "IPPhotoResultViewController.h"
#import "Game.h"
#import "RestKit.h"
#import "IPAppDelegate.h"
#import "MFSideMenu.h"
#import "Flurry.h"
#import <SDWebImage/UIImageView+WebCache.h>


#define LARGESTRANK 2000000000

enum State {
    PREPLAY=-1,
    TRANSITION=0,
    INPLAY=1,
    COMPLETED=2,
    SUSPENDED=3,
    NEVERINPLAY=4,
    ARCHIVED=5
};


@implementation IPPhotoLeaderboardViewController

@synthesize rankHeader, nameHeader, pointsHeader, winningsHeader, photoHeader, isLoading, inplayIndicator, controllerList, detailViewController;


- (void) dealloc {
    self.navigationController.sideMenu.menuStateEventBlock = nil;
}


- (void)setGame:(Game *) newGame
{
    if (_game != newGame) {
        _game = newGame;
    }
}

- (void)setLeaderboard:(PhotoLeaderboard *) newLeaderboard
{
    if (_leaderboard != newLeaderboard) {
        _leaderboard = newLeaderboard;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // this isn't needed on the rootViewController of the navigation controller
    [self.navigationController.sideMenu setupSideMenuBarButtonItem];
    
    self.title = @"Leaderboard";
    
    UINib *nib = [UINib nibWithNibName:@"IPPhotoLeaderboardItemCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"IPPhotoLeaderboardItemCell"];
    
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh" attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]}];
    refresh.tintColor = [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [self.tableView setAlwaysBounceVertical:YES];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-only.png"]];
    self.dataController = [[PhotoLeaderboardDataController alloc] init];
    self.controllerList = [[NSMutableDictionary alloc] init];
    detailViewController = nil;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isLoading = NO;
    [self getLeaderboard];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Photo", @"type", nil];
    [Flurry logEvent:@"LEADERBOARD" withParameters:dictionary];
}

- (void) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)refreshView:(UIRefreshControl *)refresh
{
    if (!self.isLoading) {
        self.isLoading = YES;
        [self getLeaderboard];
    } else {
        [self.refreshControl endRefreshing];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (UIView *)headerView
{
    if (!headerView) {
        [[NSBundle mainBundle] loadNibNamed:@"IPPhotoLeaderboardHeaderView" owner:self options:nil];
        rankHeader.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        winningsHeader.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        nameHeader.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        pointsHeader.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        photoHeader.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
    }
    self.rankHeader.text = @"RANK";
    self.winningsHeader.text = @"WINNINGS";
    self.nameHeader.text = @"NAME";
    self.pointsHeader.text = @"LIKES";
    self.photoHeader.text = @"PHOTO";
    
    if (self.game) {
        UIImage *image = [UIImage imageNamed: @"green_dot.png"];
        UIImage *amberImage = [UIImage imageNamed:@"amber.png"];
        if (self.game.inplayType == 0)
            [self.inplayIndicator setImage:amberImage];
        else
            [self.inplayIndicator setImage:image];
        if ((self.game.state == INPLAY) || (self.game.state == SUSPENDED)) {
            [self.inplayIndicator setHidden:NO];
        } else {
            [self.inplayIndicator setHidden:YES];
        }
    }
    
    return headerView;
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    return [self.dataController.photoGameLeaderboard count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IPPhotoLeaderboardItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IPPhotoLeaderboardItemCell"];
    cell.rankLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
    cell.nameLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
    cell.pointsLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
    cell.winningsLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
    cell.rankLabel.textColor = [UIColor whiteColor];
    cell.nameLabel.textColor = [UIColor whiteColor];
    cell.pointsLabel.textColor = [UIColor whiteColor];
    cell.winningsLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0];

    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if ([self.dataController.photoGameLeaderboard count] == 1)
            cell.accessoryType = UITableViewCellAccessoryNone;

    cell.row = indexPath.row;
    
    PhotoLeaderboard *leaderboardAtIndex;
    leaderboardAtIndex = [self.dataController.photoGameLeaderboard objectAtIndex:indexPath.row];
    
    NSString *rankString;
    if ((leaderboardAtIndex.rank == -1) || (leaderboardAtIndex.rank == 0) || (leaderboardAtIndex.rank >= LARGESTRANK))
        rankString = @"-";
    else
        rankString = [NSString stringWithFormat:@"%d", (int)leaderboardAtIndex.rank];
    
    if (leaderboardAtIndex.rank == 1) {
        cell.rankLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:13.0];
        cell.nameLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:13.0];
        cell.pointsLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:13.0];
        cell.winningsLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:13.0];
    }
    
    NSString *likesString;
    if ((leaderboardAtIndex.likes == 0))
        likesString = @"0";
    else
        likesString = [NSString stringWithFormat:@"%d", (int)leaderboardAtIndex.likes];
    
    NSString *winningsString;
    if ((leaderboardAtIndex.winnings == 0))
        winningsString = @"0";
    else
        winningsString = [NSString stringWithFormat:@"%d", (int)leaderboardAtIndex.winnings];
    
    IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.user isEqualToString:leaderboardAtIndex.name]) {
        cell.rankLabel.textColor = [UIColor colorWithRed:189/255.0 green:233/255.0 blue:51/255.0 alpha:1];
        cell.nameLabel.textColor = [UIColor colorWithRed:189/255.0 green:233/255.0 blue:51/255.0 alpha:1];
    }
    
    
    [[cell rankLabel] setText:rankString];
    [[cell nameLabel] setText:leaderboardAtIndex.name];
    [[cell pointsLabel] setText:likesString];
    [[cell winningsLabel] setText:winningsString];
    [[cell photo] setImageWithURL:leaderboardAtIndex.url];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}



#pragma mark - Table view delegate


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self headerView];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [[self headerView] bounds].size.height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataController.photoGameLeaderboard count] == 1)
        return;
    PhotoLeaderboard *leaderboard = [self.dataController.photoGameLeaderboard objectAtIndex:indexPath.row];
    detailViewController = [[IPPhotoResultViewController alloc] initWithNibName:@"IPPhotoResultViewController" bundle:nil];
    detailViewController.url = leaderboard.url;
    detailViewController.username = leaderboard.name;
    detailViewController.caption = leaderboard.caption;
    [controllerList setObject:detailViewController forKey:leaderboard.url];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil];
    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    else
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];

    if ([controllerList objectForKey:leaderboard.url]) {
        [self.navigationController pushViewController:[controllerList objectForKey:leaderboard.url] animated:YES];
    }
    return;
}


- (void)refresh {
    NSSortDescriptor *rankSorter = [[NSSortDescriptor alloc] initWithKey:@"rank" ascending:YES];
    NSSortDescriptor *nameSorter = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    [self.dataController.photoGameLeaderboard sortUsingDescriptors:[NSArray arrayWithObjects:rankSorter, nameSorter, nil]];
    
    [self.tableView reloadData];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                             [formatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]}];
    [self.refreshControl endRefreshing];
    self.isLoading = NO;
}


- (void)getLeaderboard
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"game/photo/leaderboard?game_id=%ld", (long)self.game.gameID];
    
    [objectManager getObjectsAtPath:path parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
      
        [self.dataController.photoGameLeaderboard removeAllObjects];
        NSArray* temp = [result array];
        for (int i=0; i<temp.count; i++) {
            PhotoLeaderboard *leaderboard = [temp objectAtIndex:i];
            if (!leaderboard.name)
                leaderboard.name = @"-";
            if (!leaderboard.likes)
                leaderboard.likes = @"0";
        [self.dataController.photoGameLeaderboard addObject:leaderboard];
        }
         
        if (temp.count >= 100) {
            PhotoLeaderboard *leaderboard = [[PhotoLeaderboard alloc] initWithRank:LARGESTRANK+1 name:@"TOP 100 Returned" fbID:@"0" photoID:0 likes:0 url:nil caption:nil winnings:0];
            [self.dataController.photoGameLeaderboard addObject:leaderboard];
        } else if (temp.count == 0) {
            PhotoLeaderboard *leaderboard = [[PhotoLeaderboard alloc] initWithRank:LARGESTRANK name:@"No Entries yet" fbID:@"0" photoID:0 likes:0 url:nil caption:nil winnings:0];
            [self.dataController.photoGameLeaderboard addObject:leaderboard];
        }
         
        [self refresh];
     } failure:^(RKObjectRequestOperation *operation, NSError *error){
         [self.refreshControl endRefreshing];
         self.isLoading = NO;
     }];
}




@end
