//
//  IPLobbyChildCell.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 23/02/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPLobbyChildCell.h"

@implementation IPLobbyChildCell

@synthesize nameLabel, timeLabel, inplayIcon, enteredIcon;

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
    /*
    UIImageView *imageViewSelected = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-sub-row-hit-gray.png"]];
    if (selected) {
        self.selectedBackgroundView = imageViewSelected;
    }
     */
    if (selected) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-sub-row-hit-gray.png"]];
        self.backgroundView = imageView;
    } else {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-sub-row.png"]];
        self.backgroundView = imageView;

    }
}


@end
