//
//  SideMenuViewController.m
//  MFSideMenuDemo
//

#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "IPLobbyViewController.h"
#import "IPSettingsViewController.h"
#import "IPFanViewController.h"
#import "IPLeaderboardViewController.h"
#import "IPInfoViewController.h"
#import "IPWinnersViewController.h"
#import "IPTutorialViewController.h"
#import "MenuDataController.h"
#import "Flurry.h"


@implementation SideMenuViewController

@synthesize sideMenu, lobbyController, settingsController, fanController, leaderboardController, infoController, winnersController, tutorialController;

- (void) viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.dataController = [[MenuDataController alloc] init];
    
    lobbyController = (IPLobbyViewController *)self.sideMenu.navigationController.topViewController;
    settingsController = nil;
    fanController = nil;
    leaderboardController = nil;
    infoController = nil;
    winnersController = nil;
    tutorialController = nil;
    
    self.tableView.scrollEnabled = NO;
    self.tableView.bounces = NO;
    self.tableView.rowHeight = 44.0;
    // CGRect searchBarFrame = CGRectMake(0, 0, self.tableView.frame.size.width, 45.0);
    // UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:searchBarFrame];
    // searchBar.delegate = self;
    // self.tableView.tableHeaderView = searchBar;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (UIView *)headerView
{
    if (!headerView) {
        [[NSBundle mainBundle] loadNibNamed:@"IPMenuHeaderView" owner:self options:nil];
    }
    return headerView;
}

- (UIView *)footerView
{
    if (!footerView) {
        [[NSBundle mainBundle] loadNibNamed:@"IPMenuFooterView" owner:self options:nil];
    }
    return footerView;
}
 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.dataController countOfList];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"menuCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
 
    NSString *itemAtIndex = [self.dataController objectInListAtIndex:indexPath.row];
    
    UIImageView *imageViewSelected = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu-row-hit.png"]];
    [cell setSelectedBackgroundView:imageViewSelected];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu-row.png"]];
    [cell setBackgroundView:imageView];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    cell.textLabel.text = itemAtIndex;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.highlightedTextColor = [UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0];
    
    switch (indexPath.row) {
        case (0): {
            UIImage *image = [UIImage imageNamed: @"lobby.png"];
            UIImage *imageHighlighted = [UIImage imageNamed: @"lobby-hit.png"];
            cell.imageView.image = image;
            cell.imageView.highlightedImage = imageHighlighted;
            break;
        }
        case (1): {
            UIImage *image = [UIImage imageNamed: @"leaderboard.png"];
            UIImage *imageHighlighted = [UIImage imageNamed: @"leaderboard-hit.png"];
            cell.imageView.image = image;
            cell.imageView.highlightedImage = imageHighlighted;
            break;
        }
        case (2): {
            UIImage *image = [UIImage imageNamed: @"winners.png"];
            UIImage *imageHighlighted = [UIImage imageNamed: @"winners-hit.png"];
            cell.imageView.image = image;
            cell.imageView.highlightedImage = imageHighlighted;
            break;
        }
        case (3): {
            UIImage *image = [UIImage imageNamed: @"fan.png"];
            UIImage *imageHighlighted = [UIImage imageNamed: @"fan-hit.png"];
            cell.imageView.image = image;
            cell.imageView.highlightedImage = imageHighlighted;
            break;
        }
        case (4): {
            UIImage *image = [UIImage imageNamed: @"tutorial-icon.png"];
            UIImage *imageHighlighted = [UIImage imageNamed: @"tutorial-icon-hit-state.png"];
            cell.imageView.image = image;
            cell.imageView.highlightedImage = imageHighlighted;
            break;
        }
        case (5): {
            UIImage *image = [UIImage imageNamed: @"settings.png"];
            UIImage *imageHighlighted = [UIImage imageNamed: @"settings-hit.png"];
            cell.imageView.image = image;
            cell.imageView.highlightedImage = imageHighlighted;
            break;
        }
        case (6): {
            UIImage *image = [UIImage imageNamed: @"info.png"];
            UIImage *imageHighlighted = [UIImage imageNamed: @"info-hit.png"];
            cell.imageView.image = image;
            cell.imageView.highlightedImage = imageHighlighted;
            /*
            UIImageView *separatorLine = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, cell.frame.size.height - 1.0f, cell.frame.size.width, 1.0f)];
            separatorLine.image = [[UIImage imageNamed:@"menu-final-row-line.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
            [cell.contentView addSubview:separatorLine];
             */
            break;
        }
    }


    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case (0): {
            if (lobbyController == nil) {
                self.lobbyController = [[IPLobbyViewController alloc] initWithNibName:@"IPLobbyViewController" bundle:nil];
            }
            NSArray *controllers = [NSArray arrayWithObject:lobbyController];
            self.sideMenu.navigationController.viewControllers = controllers;
            [self.sideMenu setMenuState:MFSideMenuStateHidden];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Lobby",
                                        @"row", nil];
            [Flurry logEvent:@"MENU" withParameters:dictionary];
            break;
        }
        case (1): {
            if (leaderboardController == nil) {
                self.leaderboardController = [[IPLeaderboardViewController alloc]
                                              initWithNibName:@"IPLeaderboardViewController" bundle:nil];
            }
            NSArray *controllers = [NSArray arrayWithObject:leaderboardController];
            self.sideMenu.navigationController.viewControllers = controllers;
            [self.sideMenu setMenuState:MFSideMenuStateHidden];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Leaderboard",
                                        @"row", nil];
            [Flurry logEvent:@"MENU" withParameters:dictionary];
            break;
        }
        case (2): {
            if (winnersController == nil) {
                self.winnersController = [[IPWinnersViewController alloc]
                                              initWithNibName:@"IPWinnersViewController" bundle:nil];
            }
            NSArray *controllers = [NSArray arrayWithObject:winnersController];
            self.sideMenu.navigationController.viewControllers = controllers;
            [self.sideMenu setMenuState:MFSideMenuStateHidden];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Winners",
                                        @"row", nil];
            [Flurry logEvent:@"MENU" withParameters:dictionary];
            break;
        }
        case (3): {
            if (fanController == nil) {
                self.fanController = [[IPFanViewController alloc]
                                                      initWithNibName:@"IPFanViewController" bundle:nil];
            }
            NSArray *controllers = [NSArray arrayWithObject:fanController];
            self.sideMenu.navigationController.viewControllers = controllers;
            [self.sideMenu setMenuState:MFSideMenuStateHidden];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Fan",
                                        @"row", nil];
            [Flurry logEvent:@"MENU" withParameters:dictionary];
            break;
        }
        case (4): {
            if (tutorialController == nil) {
                self.tutorialController = [[IPTutorialViewController alloc]
                                           initWithNibName:@"IPTutorialViewController" bundle:nil];
            }
            NSArray *controllers = [NSArray arrayWithObject:tutorialController];
            self.sideMenu.navigationController.viewControllers = controllers;
            [self.sideMenu setMenuState:MFSideMenuStateHidden];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Tutorial",
                                        @"row", nil];
            [Flurry logEvent:@"MENU" withParameters:dictionary];
            break;
        }
        case (5): {
            if (settingsController == nil) {
                self.settingsController = [[IPSettingsViewController alloc]
                                        initWithNibName:@"IPSettingsViewController" bundle:nil];
            }
            NSArray *controllers = [NSArray arrayWithObject:settingsController];
            self.sideMenu.navigationController.viewControllers = controllers;
            [self.sideMenu setMenuState:MFSideMenuStateHidden];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Settings",
                                        @"row", nil];
            [Flurry logEvent:@"MENU" withParameters:dictionary];
            break;
        }
        case (6): {
            if (infoController == nil) {
                self.infoController = [[IPInfoViewController alloc]
                                      initWithNibName:@"IPInfoViewController" bundle:nil];
            }
            NSArray *controllers = [NSArray arrayWithObject:infoController];
            self.sideMenu.navigationController.viewControllers = controllers;
            [self.sideMenu setMenuState:MFSideMenuStateHidden];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Info",
                                        @"row", nil];
            [Flurry logEvent:@"MENU" withParameters:dictionary];
            break;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self headerView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [[self headerView] bounds].size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [self footerView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return [[self footerView] bounds].size.height;
}

/*
#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}
 */

@end
