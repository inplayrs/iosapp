//
//  IPPickUsernamesViewController.m
//

#import "IPPickUsernamesViewController.h"
#import "RestKit.h"
#import "Flurry.h"
#import "Motd.h"
#import "Error.h"
#import "TSMessage.h"
#import "AddUsers.h"


@implementation IPPickUsernamesViewController

@synthesize tableData, searchResults, poolID;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Pick Usernames";

    self.tableView.backgroundColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = YES;
    self.tableView.bounces = NO;
    self.tableView.rowHeight = 43.0;
    self.tableView.allowsMultipleSelection = YES;
    if ([self.tableView respondsToSelector:@selector(setTintColor:)]) {
        [self.tableView setTintColor:[UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(donePressed:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0],UITextAttributeFont,nil];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    tableData = [[NSMutableArray alloc] init];
    searchResults = [[NSMutableArray alloc] init];
    self.addUsers = [[AddUsers alloc] init];
    
    
    CGRect searchBarFrame = CGRectMake(0, 0, 320, 44);
    searchBar = [[UISearchBar alloc] initWithFrame:searchBarFrame];
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchBar.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.delegate = self;
    self.tableView.tableHeaderView = searchBar;
    
    /*
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.tableView.window.clipsToBounds = YES;
        self.view.clipsToBounds = YES;
        searchBar.clipsToBounds = YES;
    }
     */
    
    /*
    searchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
    searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    searchDisplayController.searchResultsTableView.scrollEnabled = YES;
    searchDisplayController.searchResultsTableView.bounces = NO;
    searchDisplayController.searchResultsTableView.rowHeight = 44.0;
    searchDisplayController.searchResultsTableView.allowsMultipleSelection = YES;
    if ([searchDisplayController.searchResultsTableView respondsToSelector:@selector(setTintColor:)]) {
        [searchDisplayController.searchResultsTableView setTintColor:[UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0]];
    }
     */
}


/*
- (UIView *)headerView
{
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 109)];
        CGRect frame = CGRectMake(0, 20, 320, 44);
        UIToolbar *createToolbar = [[UIToolbar alloc] initWithFrame:frame];
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed:)];
        [cancelBtn setTintColor:[UIColor blackColor]];
        [barItems addObject:cancelBtn];
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [barItems addObject:flexSpace];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed:)];
        [barItems addObject:doneButton];
        
        [createToolbar setItems:barItems animated:NO];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            [[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] } forState:UIControlStateNormal];
            createToolbar.barTintColor = [UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0];
        } else {
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil];
            [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
            [cancelBtn setTintColor:[UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0]];
            [doneButton setTintColor:[UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0]];
            createToolbar.tintColor = [UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0];
        }
        [headerView addSubview:createToolbar];
 
        CGRect searchBarFrame = CGRectMake(0, 64, self.tableView.frame.size.width, 45.0);
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:searchBarFrame];
        UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
        searchBar.delegate = self;
        searchDisplayController.searchResultsDataSource = self;
        searchDisplayController.searchResultsDelegate = self;
        searchDisplayController.delegate = self;
        [headerView addSubview:searchBar];
    
        return headerView;
}
 */

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getUsernames:self];
    [self.addUsers.usernames removeAllObjects];
    
}

- (void)getUsernames:(id)sender
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager getObjectsAtPath:@"user/list" parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         [tableData removeAllObjects];
         NSArray* temp = [result array];
         for (int i=0; i<temp.count; i++) {
             Motd *motd = [temp objectAtIndex:i];
             if (!motd.message)
                 motd.message = @"Unknown";
             [tableData addObject:motd.message];
         }
         // [tableData sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
         [self.tableView reloadData];
     } failure:nil];
}


- (void) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) donePressed:(id)sender {
    for (int i=0; i < [self.addUsers.usernames count]; i++) {
        NSLog(@"%@", [self.addUsers.usernames objectAtIndex:i]);
    }
    
    if ([self.addUsers.usernames count] > 0) {
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        NSString *path = [NSString stringWithFormat:@"pool/addusers?pool_id=%ld", (long)self.poolID];
        [objectManager postObject:self.addUsers path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"AddUsernames",
                                        @"type", @"Success", @"result", nil];
            [Flurry logEvent:@"FRIEND" withParameters:dictionary];
            // [[NSNotificationCenter defaultCenter] postNotificationName: @"ShowSuccess" object:nil userInfo:nil];
    
            [self dismissViewControllerAnimated:YES completion:nil];
            [TSMessage showNotificationInViewController:self
                                                  title:@"Add Successful"
                                               subtitle:@"Your friends have been added to this pool."
                                                  image:nil
                                                   type:TSMessageNotificationTypeSuccess
                                               duration:TSMessageNotificationDurationAutomatic
                                               callback:nil
                                            buttonTitle:nil
                                         buttonCallback:nil
                                             atPosition:TSMessageNotificationPositionTop
                                    canBeDismisedByUser:YES];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(RKObjectRequestOperation *operation, NSError *error){
            NSArray *errorMessages = [[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey];
            Error *myerror = [errorMessages objectAtIndex:0];
            if (!myerror.message)
                myerror.message = @"Please try again later!";
            NSString *errorString = [NSString stringWithFormat:@"%d", (int)myerror.code];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"AddUsernames",
                                        @"type", @"Fail", @"result", errorString, @"error", nil];
            [Flurry logEvent:@"FRIEND" withParameters:dictionary];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Failed" message:myerror.message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}
 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.searchResults count];
    }
    else
    {
        return [self.tableData count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"usernameCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (cell.isHighlighted)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.row % 2) {
        cell.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:62/255.0 alpha:1];
        cell.contentView.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:62/255.0 alpha:1];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1];
        cell.contentView.backgroundColor = [UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:14.0];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.highlightedTextColor = [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0];
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        cell.textLabel.text = [self.searchResults objectAtIndex:indexPath.row];
    }
    else
    {
        cell.textLabel.text = self.tableData[indexPath.row];
    }
    

    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    if (tableView == searchDisplayController.searchResultsTableView)
    {
        [searchBar resignFirstResponder];
        [searchDisplayController.searchContentsController.navigationController setNavigationBarHidden:NO animated:NO];
        [self.addUsers.usernames addObject:[self.searchResults objectAtIndex:indexPath.row]];
    }
    else
    {
        [self.addUsers.usernames addObject:self.tableData[indexPath.row]];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (tableView == searchDisplayController.searchResultsTableView)
    {
        [self.addUsers.usernames removeObject:[self.searchResults objectAtIndex:indexPath.row]];
    }
    else
    {
        [self.addUsers.usernames removeObject:self.tableData[indexPath.row]];
    }
}


#pragma mark - UISearchBarDelegate



- (BOOL)searchBarShouldEndEditing:(UISearchBar *)mySearchBar {
    return YES;
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)mySearchBar {
    [mySearchBar resignFirstResponder];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self.searchResults removeAllObjects];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    
    self.searchResults = [NSMutableArray arrayWithArray: [self.tableData filteredArrayUsingPredicate:resultPredicate]];
}


-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}


-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

/*
- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    NSLog(@"begin search");
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    searchBar.showsCancelButton = NO;
}
 */

/*
- (void)setActive:(BOOL)visible animated:(BOOL)animated
{
    NSLog(@"working");
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [searchDisplayController.searchContentsController.navigationController setNavigationBarHidden:YES animated:NO];
    
    [searchDisplayController setActive:visible animated:animated];
    
    [searchDisplayController.searchContentsController.navigationController setNavigationBarHidden:NO animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    searchBar.showsCancelButton = NO;
}
 */

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    tableView.backgroundColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.scrollEnabled = YES;
    tableView.bounces = NO;
    tableView.rowHeight = 43.0;
    tableView.allowsMultipleSelection = YES;
    if ([tableView respondsToSelector:@selector(setTintColor:)])
        [tableView setTintColor:[UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]];
}

/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self headerView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [[self headerView] bounds].size.height;
}
 */


@end
