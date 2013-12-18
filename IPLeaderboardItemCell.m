//
//  IPLeaderboardItemCell.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 31/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPLeaderboardItemCell.h"

@implementation IPLeaderboardItemCell

@synthesize rankLabel, nameLabel, pointsLabel, winningsLabel, entryImage;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


@end
