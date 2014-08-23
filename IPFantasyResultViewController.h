//
//  IPFantasyResultViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPFantasyResultViewController : UITableViewController
{
    IBOutlet UIView *headerView;
    
}

- (UIView *)headerView;

@property (nonatomic, copy) NSMutableArray *periodOptions;
@property (nonatomic, copy) NSString *title;
@property (nonatomic) NSInteger total;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *points;
@property (weak, nonatomic) IBOutlet UILabel *result;
@property (weak, nonatomic) IBOutlet UILabel *totalPoints;


@end
