//
//  IPPhotoLeaderboardItemCell.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 31/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IPPhotoLeaderboardItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *winningsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (nonatomic) NSInteger row;




@end
