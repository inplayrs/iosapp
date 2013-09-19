//
//  SideMenuViewController.h
// 
//

#import <UIKit/UIKit.h>
#import "MFSideMenu.h"

@class MenuDataController;
@class IPLobbyViewController;
@class IPSettingsViewController;
@class IPFanViewController;
@class IPLeaderboardViewController;
@class IPInfoViewController;
@class IPWinnersViewController;
@class IPTutorialViewController;

@interface SideMenuViewController : UITableViewController
// <UISearchBarDelegate>
{
    IBOutlet UIView *headerView;
    IBOutlet UIView *footerView;
}

- (UIView *)headerView;
- (UIView *)footerView;

@property (nonatomic, assign) MFSideMenu *sideMenu;
@property (strong, nonatomic) MenuDataController *dataController;
@property (strong, nonatomic) IPLobbyViewController *lobbyController;
@property (strong, nonatomic) IPSettingsViewController *settingsController;
@property (strong, nonatomic) IPFanViewController *fanController;
@property (strong, nonatomic) IPLeaderboardViewController *leaderboardController;
@property (strong, nonatomic) IPInfoViewController *infoController;
@property (strong, nonatomic) IPWinnersViewController *winnersController;
@property (strong, nonatomic) IPTutorialViewController *tutorialController;

@end