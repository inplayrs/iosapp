//
//  IPGameItemCell.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 31/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IPGameItemCell : UITableViewCell

- (IBAction)changeSelection:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *periodLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectionButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *inplayIcon;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) id controller;
@property (weak, nonatomic) UITableView *tableView;


@end
