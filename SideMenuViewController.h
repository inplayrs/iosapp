//
//  SideMenuViewController.h
// 
//

#import <UIKit/UIKit.h>
#import "MFSideMenu.h"

@class MenuDataController;
@class IPLobbyViewController;
@class IPNewInfoViewController;
@class IPWinnersViewController;
@class IPTutorialViewController;
@class IPStatsViewController;
@class IPFriendViewController;

@interface SideMenuViewController : UITableViewController
{
    IBOutlet UIView *headerView;
}

- (UIView *)headerView;

@property (nonatomic, assign) MFSideMenu *sideMenu;
@property (strong, nonatomic) MenuDataController *dataController;
@property (strong, nonatomic) IPLobbyViewController *lobbyController;
@property (strong, nonatomic) IPNewInfoViewController *infoController;
@property (strong, nonatomic) IPWinnersViewController *winnersController;
@property (strong, nonatomic) IPTutorialViewController *tutorialController;
@property (strong, nonatomic) IPStatsViewController *statsController;
@property (strong, nonatomic) IPFriendViewController *friendController;

@end