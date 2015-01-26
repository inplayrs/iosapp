//
//  IPTrophyViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 07/11/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPTrophyViewController.h"
#import "MFSideMenu.h"
#import "RestKit.h"
#import "Flurry.h"
#import "Trophy.h"
#import "IPAppDelegate.h"

@interface IPTrophyViewController ()

@end

@implementation IPTrophyViewController

@synthesize trophyCollection, trophies, externalUsername, externalFBID, externalTitle, titleLabel, usernameLabel, noProfileImage;

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
	self.title = @"Trophies";
    [self.navigationController.sideMenu setupSideMenuBarButtonItem];
    
    self.usernameLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:16.0];
    self.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:16.0];
    // self.view.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:62/255.0 alpha:1];
    // [self.trophyCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"IPTrophyCell"];
    UINib *cellNib = [UINib nibWithNibName:@"IPTrophyCell" bundle:nil];
    [trophyCollection registerNib:cellNib forCellWithReuseIdentifier:@"IPTrophyCell"];
    trophies = [[NSMutableArray alloc] init];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (externalUsername) {
        if ((FBSession.activeSession.isOpen) && (externalFBID)) {
            self.userProfileImage.profileID = externalFBID;
            self.userProfileImage.layer.cornerRadius = 30.0;
            [self.noProfileImage setHidden:YES];
            [self.userProfileImage setHidden:NO];
        } else {
            UIImage *image = [UIImage imageNamed: @"stats-avatar.png"];
            [self.userProfileImage setHidden:YES];
            [self.noProfileImage setImage:image];
            [self.noProfileImage setHidden:NO];
        }
        self.usernameLabel.text = externalUsername;
        self.titleLabel.text = externalTitle;
        [self getTrophies:externalUsername];
    } else if (appDelegate.loggedin) {
        self.usernameLabel.text = appDelegate.user;
        self.titleLabel.text = externalTitle;
        if (FBSession.activeSession.isOpen) {
            [[FBRequest requestForMe] startWithCompletionHandler:
             ^(FBRequestConnection *connection,
               NSDictionary<FBGraphUser> *user,
               NSError *error) {
                 if (!error) {
                     // self.userProfileImage.profileID = user.id;
                     self.userProfileImage.profileID = [user objectForKey:@"id"];
                     self.userProfileImage.layer.cornerRadius = 30.0;
                 }
             }];
            [self.noProfileImage setHidden:YES];
            [self.userProfileImage setHidden:NO];
        } else {
            UIImage *image = [UIImage imageNamed: @"stats-avatar.png"];
            [self.userProfileImage setHidden:YES];
            [self.noProfileImage setImage:image];
            [self.noProfileImage setHidden:NO];
        }
        [self getTrophies:appDelegate.user];
    } else {
        self.usernameLabel.text = @"";
        self.titleLabel.text = @"";
        self.userProfileImage.profileID = nil;
        UIImage *image = [UIImage imageNamed: @"stats-avatar.png"];
        [self.noProfileImage setImage:image];
        [self.noProfileImage setHidden:NO];
        [self.userProfileImage setHidden:YES];
    }
}


- (void)getTrophies:(NSString *)username
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"user/trophies?username=%@", username];
    [objectManager getObjectsAtPath:path parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         [trophies removeAllObjects];
         NSArray* temp = [result array];
         for (int i=0; i<temp.count; i++) {
             Trophy *trophy = [temp objectAtIndex:i];
             if (!trophy.name)
                 trophy.name = @"";
             [trophies addObject:trophy];
         }
     [self.trophyCollection reloadData];
     } failure:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [trophies count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"IPTrophyCell" forIndexPath:indexPath];
    // static NSString *cellIdentifier = @"IPTrophyCell";
    // UICollectionViewCell *cell = [trophyCollection dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // cell.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:62/255.0 alpha:1];
    // cell.backgroundColor = [UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1];;
    
    if ([trophies count] > 0) {
        Trophy *trophy = [trophies objectAtIndex:indexPath.row];
        UIImageView *image = (UIImageView *)[cell viewWithTag:100];
        UILabel *title = (UILabel *)[cell viewWithTag:200];
    
        if (trophy.achieved) {
            switch (trophy.trophyID) {
                case (1): {
                    [image setImage:[UIImage imageNamed:@"global-win-complete.png"]];
                    break;
                }
                case (2): {
                    [image setImage:[UIImage imageNamed:@"friend-win-complete.png"]];
                    break;
                }
                case (3): {
                    [image setImage:[UIImage imageNamed:@"head-to-head-complete.png"]];
                    break;
                }
                case (4): {
                    [image setImage:[UIImage imageNamed:@"banked-3-times-complete.png"]];
                    break;
                }
                case (5): {
                    [image setImage:[UIImage imageNamed:@"competition-win-complete.png"]];
                    break;
                }
                case (6): {
                    [image setImage:[UIImage imageNamed:@"10-games-complete.png"]];
                    break;
                }
                case (7): {
                    [image setImage:[UIImage imageNamed:@"perfect-game-complete.png"]];
                    break;
                }
                case (8): {
                    [image setImage:[UIImage imageNamed:@"50-games-complete.png"]];
                    break;
                }
                case (9): {
                    [image setImage:[UIImage imageNamed:@"invited-5-people-complete.png"]];
                    break;
                }
            }
            [title setText:trophy.name];
            [title setTextColor:[UIColor whiteColor]];
        } else {
            switch (trophy.trophyID) {
                case (1): {
                    [image setImage:[UIImage imageNamed:@"global-win.png"]];
                    break;
                }
                case (2): {
                    [image setImage:[UIImage imageNamed:@"friend-win.png"]];
                    break;
                }
                case (3): {
                    [image setImage:[UIImage imageNamed:@"head-to-head.png"]];
                    break;
                }
                case (4): {
                    [image setImage:[UIImage imageNamed:@"banked-3-times.png"]];
                    break;
                }
                case (5): {
                    [image setImage:[UIImage imageNamed:@"competition-win.png"]];
                    break;
                }
                case (6): {
                    [image setImage:[UIImage imageNamed:@"10-games.png"]];
                    break;
                }
                case (7): {
                    [image setImage:[UIImage imageNamed:@"perfect-game.png"]];
                    break;
                }
                case (8): {
                    [image setImage:[UIImage imageNamed:@"50-games.png"]];
                    break;
                }
                case (9): {
                    [image setImage:[UIImage imageNamed:@"invited-5-people.png"]];
                    break;
                }
            }
            [title setText:trophy.name];
            [title setTextColor:[UIColor darkGrayColor]];
        }
    
        [title setText:trophy.name];
    }
    return cell;
}
     
#pragma mark – UICollectionViewDelegateFlowLayout
     
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize retval = CGSizeMake(100, 100);
    return retval;
}

- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
     


@end
