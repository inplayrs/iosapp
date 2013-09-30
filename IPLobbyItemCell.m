//
//  IPLobbyItemCell.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 23/02/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPLobbyItemCell.h"

enum State {
    INACTIVE=-2,
    PREPLAY=-1,
    TRANSITION=0,
    INPLAY=1,
    COMPLETED=2,
    SUSPENDED=3,
    NEVERINPLAY=4
};

@implementation IPLobbyItemCell

@synthesize nameLabel, timeLabel, inplayIcon, categoryIcon;

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
    
    // UIImageView *imageViewSelected = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-main-row-hit-state.png"]];
    if (selected) {
        // if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-main-row-hit-state.png"]];
            self.backgroundView = imageView;
            // self.backgroundView = nil;
            // self.backgroundColor = [UIColor colorWithRed:234/255.0 green:208/255.0 blue:23/255.0 alpha:1.0];
            /*
        } else {
            UIImageView *imageViewSelected = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-main-row-hit-state.png"]];
            self.selectedBackgroundView = imageViewSelected;
        }
             */
        self.timeLabel.textColor = [UIColor colorWithRed:45.0/255.0 green:45.0/255.0 blue:45.0/255.0 alpha:1.0];
        self.nameLabel.textColor = [UIColor colorWithRed:45.0/255.0 green:45.0/255.0 blue:45.0/255.0 alpha:1.0];
    } else {
       // if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-main-row.png"]];
            self.backgroundView = imageView;
            // self.backgroundColor = [UIColor clearColor];
        /*
        } else {
            self.selectedBackgroundView = nil;
        }
         */
        if (self.competitionState == COMPLETED) {
            self.timeLabel.textColor = [UIColor colorWithRed:45.0/255.0 green:45.0/255.0 blue:45.0/255.0 alpha:1.0];
            self.nameLabel.textColor = [UIColor colorWithRed:45.0/255.0 green:45.0/255.0 blue:45.0/255.0 alpha:1.0];
        } else {
            self.timeLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
            self.nameLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        }
    }
}


@end
