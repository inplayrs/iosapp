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

enum Category {
    FOOTBALL=10,
    TENNIS=11,
    SNOOKER=12,
    MOTORRACING=13,
    CRICKET=14,
    GOLF=15,
    RUGBY=16,
    BASEBALL=20,
    BASKETBALL=21,
    ICEHOCKEY=22,
    AMERICANFOOTBALL=23,
    FINANCE=30,
    REALITYTV=31,
    AWARDS=32
};

@implementation IPLobbyItemCell

@synthesize nameLabel, timeLabel, inplayIcon, categoryIcon, row;

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
            // UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-bar-hitstate.png"]];
            // self.backgroundView = imageView;
            UIImageView *imageView;
            if (row % 2)
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-bar-2-hitstate.png"]];
            else
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-bar-1-hitstate.png"]];
            self.backgroundView = imageView;
            // self.backgroundView = nil;
            // self.backgroundColor = [UIColor colorWithRed:234/255.0 green:208/255.0 blue:23/255.0 alpha:1.0];
            /*
        } else {
            UIImageView *imageViewSelected = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-main-row-hit-state.png"]];
            self.selectedBackgroundView = imageViewSelected;
        }
             */
        if (self.competitionState == COMPLETED) {
            self.timeLabel.textColor = [UIColor colorWithRed:151.0/255.0 green:151.0/255.0 blue:155.0/255.0 alpha:1.0];
            self.nameLabel.textColor = [UIColor colorWithRed:151.0/255.0 green:151.0/255.0 blue:155.0/255.0 alpha:1.0];
        } else {
            self.timeLabel.textColor = [UIColor colorWithRed:32.0/255.0 green:35.0/255.0 blue:45.0/255.0 alpha:1.0];
            self.nameLabel.textColor = [UIColor colorWithRed:32.0/255.0 green:35.0/255.0 blue:45.0/255.0 alpha:1.0];
        }
        switch (self.competitionCategory) {
            case (FOOTBALL): {
                UIImage *highlighted = [UIImage imageNamed:@"football-hit.png"];
                [self.categoryIcon setImage:highlighted];
                break;
            }
            case (BASKETBALL): {
                UIImage *highlighted = [UIImage imageNamed:@"basketball-hit.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
            case (TENNIS): {
                UIImage *highlighted = [UIImage imageNamed:@"tennis-hit.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
            case (GOLF): {
                UIImage *highlighted = [UIImage imageNamed:@"golf-hit.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
            case (SNOOKER): {
                UIImage *highlighted = [UIImage imageNamed:@"snooker-hit.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
            case (MOTORRACING): {
                UIImage *highlighted = [UIImage imageNamed:@"motor-racing-hit.png"];
                [self.categoryIcon setImage:highlighted];
                break;
            }
            case (CRICKET): {
                UIImage *highlighted = [UIImage imageNamed:@"cricket-hit.png"];
                [self.categoryIcon  setHighlightedImage:highlighted];
                break;
            }
            case (RUGBY): {
                UIImage *highlighted = [UIImage imageNamed:@"rugby-hit.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
            case (BASEBALL): {
                UIImage *highlighted = [UIImage imageNamed:@"baseball-hit.png"];
                [self.categoryIcon  setHighlightedImage:highlighted];
                break;
            }
            case (ICEHOCKEY): {
                UIImage *highlighted = [UIImage imageNamed:@"ice-hockey-hit.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
            case (AMERICANFOOTBALL): {
                UIImage *highlighted = [UIImage imageNamed:@"american-football-hit.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
            case (FINANCE): {
                UIImage *highlighted = [UIImage imageNamed:@"finance-hit.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
            case (REALITYTV): {
                UIImage *highlighted = [UIImage imageNamed:@"reality-tv-hit.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
            case (AWARDS): {
                UIImage *highlighted = [UIImage imageNamed:@"awards-hit.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
            default: {
                UIImage *highlighted = [UIImage imageNamed:@"football-hit.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
        }
    } else {
       // if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            // UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-main-row.png"]];
        UIImageView *imageView;
        if (row % 2)
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-bar-2.png"]];
        else
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-bar-1.png"]];
        self.backgroundView = imageView;
            // self.backgroundColor = [UIColor clearColor];
        /*
        } else {
            self.selectedBackgroundView = nil;
        }
         */
        if (self.competitionState == COMPLETED) {
            self.timeLabel.textColor = [UIColor colorWithRed:151.0/255.0 green:151.0/255.0 blue:155.0/255.0 alpha:1.0];
            self.nameLabel.textColor = [UIColor colorWithRed:151.0/255.0 green:151.0/255.0 blue:155.0/255.0 alpha:1.0];
        } else {
            self.timeLabel.textColor = [UIColor colorWithRed:32.0/255.0 green:35.0/255.0 blue:45.0/255.0 alpha:1.0];
            self.nameLabel.textColor = [UIColor colorWithRed:32.0/255.0 green:35.0/255.0 blue:45.0/255.0 alpha:1.0];
        }
        switch (self.competitionCategory) {
            case (FOOTBALL): {
                UIImage *highlighted = [UIImage imageNamed:@"football.png"];
                [self.categoryIcon setImage:highlighted];
                break;
            }
            case (BASKETBALL): {
                UIImage *highlighted = [UIImage imageNamed:@"basketball.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
            case (TENNIS): {
                UIImage *highlighted = [UIImage imageNamed:@"tennis.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
            case (GOLF): {
                UIImage *highlighted = [UIImage imageNamed:@"golf.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
            case (SNOOKER): {
                UIImage *highlighted = [UIImage imageNamed:@"snooker.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
            case (MOTORRACING): {
                UIImage *highlighted = [UIImage imageNamed:@"motor-racing.png"];
                [self.categoryIcon setImage:highlighted];
                break;
            }
            case (CRICKET): {
                UIImage *highlighted = [UIImage imageNamed:@"cricket.png"];
                [self.categoryIcon  setHighlightedImage:highlighted];
                break;
            }
            case (RUGBY): {
                UIImage *highlighted = [UIImage imageNamed:@"rugby.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
            case (BASEBALL): {
                UIImage *highlighted = [UIImage imageNamed:@"baseball.png"];
                [self.categoryIcon  setHighlightedImage:highlighted];
                break;
            }
            case (ICEHOCKEY): {
                UIImage *highlighted = [UIImage imageNamed:@"ice-hockey.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
            case (AMERICANFOOTBALL): {
                UIImage *highlighted = [UIImage imageNamed:@"american-football.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
            case (FINANCE): {
                UIImage *highlighted = [UIImage imageNamed:@"finance.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
            case (REALITYTV): {
                UIImage *highlighted = [UIImage imageNamed:@"reality-tv.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
            case (AWARDS): {
                UIImage *highlighted = [UIImage imageNamed:@"awards.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
            default: {
                UIImage *highlighted = [UIImage imageNamed:@"football.png"];
                [self.categoryIcon  setImage:highlighted];
                break;
            }
        }

    }
}


@end
