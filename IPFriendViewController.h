//
//  IPFriendViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>


@class IPCreateViewController;
@class IPFriendPoolViewController;
@class IPAddFriendsViewController;

@interface IPFriendViewController : UITableViewController <UIAlertViewDelegate>
{
    IBOutlet UIView *footerView;
}


@property (nonatomic, copy) NSMutableArray *friendPools;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (strong, nonatomic) IPCreateViewController *createViewController;
@property (strong, nonatomic) IPFriendPoolViewController *friendPoolViewController;
@property (strong, nonatomic) IPAddFriendsViewController *addFriendsViewController;
@property (strong, nonatomic) NSMutableDictionary *controllerList;


- (UIView *)footerView;
- (IBAction)createPool:(id)sender;
- (void)getMyPools:(id)sender;
- (void) addFriends:(NSNotification *)notification;


@end
