//
//  IPLeaderboardItemCell.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 31/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPLeaderboardItemCell.h"

@implementation IPLeaderboardItemCell

@synthesize rankLabel, nameLabel, pointsLabel, winningsLabel, row;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (row % 2) {
        self.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:62/255.0 alpha:1];
        self.contentView.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:62/255.0 alpha:1];
    } else {
        self.backgroundColor = [UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1];
        self.contentView.backgroundColor = [UIColor colorWithRed:32/255.0 green:35/255.0 blue:45/255.0 alpha:1];
    }
    
}


@end
