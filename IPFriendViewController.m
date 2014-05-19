//
//  IPFriendViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPFriendViewController.h"
#import "IPFriendPoolViewController.h"
#import "MFSideMenu.h"
#import "RestKit.h"
#import "FriendPool.h"
#import "IPAddFriendsViewController.h"
#import "IPCreateViewController.h"
#import "IPAppDelegate.h"


@interface IPFriendViewController ()

@end

@implementation IPFriendViewController

@synthesize createButton, createViewController,controllerList, friendPoolViewController, friendPools, addFriendsViewController;

- (void) dealloc {
    self.navigationController.sideMenu.menuStateEventBlock = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(addFriends:)
                                                     name:@"AddFriends"
                                                   object:nil];
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    friendPools = [[NSMutableArray alloc] init];
    self.title = @"Friend Pools";
    createViewController = nil;
    friendPoolViewController = nil;
    addFriendsViewController = nil;
    self.controllerList = [[NSMutableDictionary alloc] init];
    
    // this isn't needed on the rootViewController of the navigation controller
    [self.navigationController.sideMenu setupSideMenuBarButtonItem];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-only.png"]];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getMyPools:self];
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


- (UIView *)footerView
{
    if (!footerView) {
        [[NSBundle mainBundle] loadNibNamed:@"IPFriendFooterView" owner:self options:nil];
        UIImage *image = [UIImage imageNamed:@"submit-button.png"];
        UIImage *image2 = [UIImage imageNamed:@"submit-button-hit-state.png"];
        UIImage *image3 = [UIImage imageNamed:@"submit-button-disabled.png"];
        [self.createButton setBackgroundImage:image forState:UIControlStateNormal];
        [self.createButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
        [self.createButton setBackgroundImage:image3 forState:UIControlStateDisabled];
        self.createButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
            self.createButton.titleEdgeInsets = titleInsets;
        }
    }
    
    return footerView;
}

- (IBAction)createPool:(id)sender {
    IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.loggedin == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login required" message:@"Please login first!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (!self.createViewController) {
        self.createViewController = [[IPCreateViewController alloc] initWithNibName:@"IPCreateViewController" bundle:nil];
        // self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    }
    if (self.createViewController) {
        // [self.navigationController pushViewController:self.createViewController animated:YES];
        [self.navigationController presentViewController:self.createViewController animated:YES completion:nil];
    }
}


- (void) addFriends:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    FriendPool *friendPool = [userInfo objectForKey:@"friendPool"];
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    if (!self.addFriendsViewController) {
        self.addFriendsViewController = [[IPAddFriendsViewController alloc] initWithNibName:@"IPAddFriendsViewController" bundle:nil];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        else
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    }
    if (self.addFriendsViewController) {
        self.addFriendsViewController.poolID = friendPool.poolID;
        [self.navigationController pushViewController:self.addFriendsViewController animated:YES];
    }
}


- (void)getMyPools:(id)sender
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager getObjectsAtPath:@"pool/mypools" parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [friendPools removeAllObjects];
        NSArray* temp = [result array];
        for (int i=0; i<temp.count; i++) {
            FriendPool *friendPool = [temp objectAtIndex:i];
            if (!friendPool.name)
                friendPool.name = @"Unknown";
            if (!friendPool.numPlayers)
                friendPool.numPlayers = @"0";
            [friendPools addObject:friendPool];
        }
        if ([friendPools count] == 0) {
            FriendPool *friendPool = [[FriendPool alloc] initWithPoolID:0 name:@"No Friend Pools yet" numPlayers:@"0"];
            [friendPools addObject:friendPool];
        } else {
            [friendPools sortUsingSelector:@selector(compareWithName:)];
        }
        [self.tableView reloadData];
    } failure:nil];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [friendPools count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2) {
        cell.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:62/255.0 alpha:1];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"friendPoolCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    FriendPool *friendPool = [friendPools objectAtIndex:indexPath.row];
    if (friendPool.poolID == 0) {
        self.tableView.allowsSelection = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = @" ";
    } else {
        self.tableView.allowsSelection = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = friendPool.numPlayers;
    }
    
    if (indexPath.row % 2) {
        cell.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:62/255.0 alpha:1];
        cell.contentView.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:62/255.0 alpha:1];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1];
        cell.contentView.backgroundColor = [UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1];
    }
   
    cell.textLabel.text = friendPool.name;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.highlightedTextColor = [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:14.0];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.highlightedTextColor = [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:14.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendPool *friendPoolAtIndex = [friendPools objectAtIndex:indexPath.row];
    if ([controllerList objectForKey:friendPoolAtIndex.name] == nil) {
        friendPoolViewController = [[IPFriendPoolViewController alloc] initWithNibName:@"IPFriendPoolViewController" bundle:nil];
        friendPoolViewController.poolName = friendPoolAtIndex.name;
        friendPoolViewController.poolID = friendPoolAtIndex.poolID;
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil];
        [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        else
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        [controllerList setObject:friendPoolViewController forKey:friendPoolAtIndex.name];
    }
    if ([controllerList objectForKey:friendPoolAtIndex.name]) {
        [self.navigationController pushViewController:[controllerList objectForKey:friendPoolAtIndex.name] animated:YES];
    }
    return;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [self footerView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return [[self footerView] bounds].size.height;
}


@end
