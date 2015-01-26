//
//  IPTrophyViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 07/11/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface IPTrophyViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *trophyCollection;
@property (nonatomic, copy) NSMutableArray *trophies;
@property (nonatomic) NSString *externalUsername;
@property (nonatomic) NSString *externalFBID;
@property (nonatomic) NSString *externalTitle;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;
@property (weak, nonatomic) IBOutlet UIImageView *noProfileImage;

@end
