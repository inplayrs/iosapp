//
//  IPFriendPoolViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPFriendPoolViewController.h"
#import "IPStatsViewController.h"
#import "IPAddFriendsViewController.h"
#import "RestKit.h"
#import "PoolMember.h"
#import "IPAppDelegate.h"
#import "Error.h"
#import "Flurry.h"
#import "TSMessage.h"

#define LARGESTRANK 2000000000

@interface IPFriendPoolViewController ()

@end

@implementation IPFriendPoolViewController

@synthesize memberList, addButton, leaveButton, poolName, statsViewController, addFriendsViewController, controllerList, poolID;


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

    memberList = [[NSMutableArray alloc] init];
    self.title = poolName;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-only.png"]];
    statsViewController = nil;
    addFriendsViewController = nil;
    self.controllerList = [[NSMutableDictionary alloc] init];
    self.tableView.allowsSelection = YES;
    
    /*
    UIImage *backButtonNormal = [UIImage imageNamed:@"back-button.png"];
    UIImage *backButtonHighlighted = [UIImage imageNamed:@"back-button-hit-state.png"];
    CGRect frameimg = CGRectMake(0, 0, backButtonNormal.size.width, backButtonNormal.size.height);
    UIButton *backButton = [[UIButton alloc] initWithFrame:frameimg];
    [backButton setBackgroundImage:backButtonNormal forState:UIControlStateNormal];
    [backButton setBackgroundImage:backButtonHighlighted forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem =[[UIBarButtonItem alloc] initWithCustomView:backButton];
   
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -10;
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, barButtonItem, nil]];
    } else {
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }
     */
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getMemberList:self];
}

- (void) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)footerView
{
    if (!footerView) {
        [[NSBundle mainBundle] loadNibNamed:@"IPFriendPoolFooterView" owner:self options:nil];
        UIImage *image = [UIImage imageNamed:@"submit-button.png"];
        UIImage *image2 = [UIImage imageNamed:@"submit-button-hit-state.png"];
        UIImage *image3 = [UIImage imageNamed:@"submit-button-disabled.png"];
        [self.addButton setBackgroundImage:image forState:UIControlStateNormal];
        [self.addButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
        [self.addButton setBackgroundImage:image3 forState:UIControlStateDisabled];
        [self.leaveButton setBackgroundImage:image forState:UIControlStateNormal];
        [self.leaveButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
        [self.leaveButton setBackgroundImage:image3 forState:UIControlStateDisabled];
        self.addButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
        self.leaveButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
            self.addButton.titleEdgeInsets = titleInsets;
            self.leaveButton.titleEdgeInsets = titleInsets;
        }
    }
    
    return footerView;
}

- (void)getMemberList:(id)sender
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"pool/members?pool_id=%d", self.poolID];
    [objectManager getObjectsAtPath:path parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         [memberList removeAllObjects];
         NSArray* temp = [result array];
         for (int i=0; i<temp.count; i++) {
             PoolMember *poolMember = [temp objectAtIndex:i];
             if (!poolMember.username)
                 poolMember.username = @"Unknown";
             if (!poolMember.winnings)
                 poolMember.winnings = @"-";
             if (!poolMember.rank)
                 poolMember.rank = 1;
             [memberList addObject:poolMember];
         }
         if ([memberList count] == 0) {
             PoolMember *poolMember = [[PoolMember alloc] initWithUsername:@"No Friends joined yet" rank:0 winnings:@"-" facebookID:@"0"];
             [memberList addObject:poolMember];
         } else {
             NSSortDescriptor *rankSorter = [[NSSortDescriptor alloc] initWithKey:@"rank" ascending:YES];
             NSSortDescriptor *nameSorter = [[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
             [memberList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:rankSorter, nameSorter, nil]];
         }
         [self.tableView reloadData];
     } failure:nil];
}

- (IBAction)addFriends:(id)sender {
    if (!self.addFriendsViewController) {
        self.addFriendsViewController = [[IPAddFriendsViewController alloc] initWithNibName:@"IPAddFriendsViewController" bundle:nil];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        else
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    }
    if (self.addFriendsViewController) {
        self.addFriendsViewController.poolID = self.poolID;
        [self.navigationController pushViewController:self.addFriendsViewController animated:YES];
    }
}

- (IBAction)leavePool:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to leave pool?  This is not reversible!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
    {
        // NSLog(@"cancel");
    }
    else
    {
        self.leaveButton.enabled = NO;
        self.addButton.enabled = NO;
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        NSString *path = [NSString stringWithFormat:@"pool/leave?pool_id=%d", self.poolID];
        [objectManager postObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Leave",
                                        @"type", @"Success", @"result", nil];
            [Flurry logEvent:@"FRIEND" withParameters:dictionary];
            [TSMessage showNotificationInViewController:self
                                                  title:@"Leave Successful"
                                               subtitle:@"You are no longer in this pool."
                                                  image:nil
                                                   type:TSMessageNotificationTypeSuccess
                                               duration:TSMessageNotificationDurationAutomatic
                                               callback:nil
                                            buttonTitle:nil
                                         buttonCallback:nil
                                             atPosition:TSMessageNotificationPositionTop
                                    canBeDismisedByUser:YES];
            self.leaveButton.enabled = YES;
            self.addButton.enabled = YES;
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(RKObjectRequestOperation *operation, NSError *error){
            self.leaveButton.enabled = YES;
            self.addButton.enabled = YES;
            NSArray *errorMessages = [[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey];
            Error *myerror = [errorMessages objectAtIndex:0];
            if (!myerror.message)
                myerror.message = @"Please try again later!";
            NSString *errorString = [NSString stringWithFormat:@"%d", (int)myerror.code];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Leave",
                                        @"type", @"Fail", @"result", errorString, @"error", nil];
            [Flurry logEvent:@"FRIEND" withParameters:dictionary];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Failed" message:myerror.message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [memberList count];
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
        static NSString *CellIdentifier = @"membersCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        PoolMember *poolMember;
        poolMember = [memberList objectAtIndex:indexPath.row];
    
        NSString *rankString;
        if ((poolMember.rank == -1) || (poolMember.rank == 0) || (poolMember.rank == LARGESTRANK))
            rankString = @"-";
        else
            rankString = [NSString stringWithFormat:@"%d", (int)poolMember.rank];
    
        NSString *members = [NSString stringWithFormat:@"%@    %@", rankString, poolMember.username];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        // UIImageView *imageViewSelected = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-row-hit-state.png"]];
        // [cell setSelectedBackgroundView:imageViewSelected];
        cell.textLabel.text = members;
        cell.detailTextLabel.text = [@"$" stringByAppendingString:poolMember.winnings];
        // UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-row.png"]];
        // [cell setBackgroundView:imageView];
        if (indexPath.row % 2) {
            cell.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:62/255.0 alpha:1];
            cell.contentView.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:62/255.0 alpha:1];
        } else {
            cell.backgroundColor = [UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1];
            cell.contentView.backgroundColor = [UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1];
        }
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:14.0];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:14.0];
    
        if (poolMember.rank == 1) {
            cell.textLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:13.0];
            cell.detailTextLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:13.0];
        }
    
        IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([appDelegate.user isEqualToString:poolMember.username]) {
            cell.textLabel.textColor = [UIColor colorWithRed:189.0/255.0 green:233.0/255.0 blue:51.0/255.0 alpha:1.0];
        }
    
        return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PoolMember *poolMember = [memberList objectAtIndex:indexPath.row];
    if ([controllerList objectForKey:poolMember.username] == nil) {
        statsViewController = [[IPStatsViewController alloc] initWithNibName:@"IPStatsViewController" bundle:nil];
        statsViewController.externalUsername = poolMember.username;
        if (poolMember.facebookID)
            statsViewController.externalFBID = poolMember.facebookID;
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil];
        [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        else
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        [controllerList setObject:statsViewController forKey:poolMember.username];
    }
    if ([controllerList objectForKey:poolMember.username]) {
        [self.navigationController pushViewController:[controllerList objectForKey:poolMember.username] animated:YES];
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
