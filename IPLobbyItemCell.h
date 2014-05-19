//
//  IPLobbyItemCell.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 23/02/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPLobbyItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *inplayIcon;
@property (weak, nonatomic) IBOutlet UIImageView *categoryIcon;
@property (nonatomic) NSInteger competitionState;
@property (nonatomic) NSInteger competitionCategory;
@property (nonatomic) NSInteger row;

@end
