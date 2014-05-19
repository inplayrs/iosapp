//
//  IPPickUsernamesViewController.h
// 
//

#import <UIKit/UIKit.h>

@class AddUsers;

@interface IPPickUsernamesViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>
{
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;
}

@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (strong, nonatomic) AddUsers *addUsers;
@property (nonatomic) NSInteger poolID;

@end