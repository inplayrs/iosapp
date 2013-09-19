//
//  IPWinnersViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IPWinnersViewController : UITableViewController

@property (nonatomic, copy) NSMutableArray *winnersList;

- (void)getMyWinnersList:(id)sender;


@end
