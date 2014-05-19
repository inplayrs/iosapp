//
//  IPFriendPoolViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IPAddFriendsViewController;
@class IPStatsViewController;

@interface IPFriendPoolViewController : UITableViewController
{
    IBOutlet UIView *footerView;
}


- (UIView *)footerView;
- (void)getMemberList:(id)sender;
- (IBAction)addFriends:(id)sender;
- (IBAction)leavePool:(id)sender;


@property (nonatomic) NSString *poolName;
@property (nonatomic) NSInteger poolID;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *leaveButton;
@property (nonatomic, copy) NSMutableArray *memberList;
@property (strong, nonatomic) IPAddFriendsViewController *addFriendsViewController;
@property (strong, nonatomic) IPStatsViewController *statsViewController;
@property (strong, nonatomic) NSMutableDictionary *controllerList;


@end
