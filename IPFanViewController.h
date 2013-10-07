//
//  IPFanViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FanDataController;
@class Game;

@interface IPFanViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIAlertViewDelegate>
{
    IBOutlet UIView *footerView;
    UIView *myView;
}


@property (strong, nonatomic) FanDataController *dataController;
@property (weak, nonatomic) IBOutlet UIButton *competitionButton;
@property (weak, nonatomic) IBOutlet UIButton *fangroupButton;
@property (nonatomic) NSInteger selectedCompetitionID;
@property (nonatomic) NSInteger selectedFangroupID;
@property (nonatomic) NSInteger selectedCompetitionRow;
@property (nonatomic) NSInteger selectedFangroupRow;
@property (strong, nonatomic) Game *game;


- (UIView *)footerView;
- (IBAction)submitCompetition:(id)sender;
- (IBAction)submitFangroup:(id)sender;
- (void)getCompetitions:(id)sender;
- (void)getMyFanList:(id)sender;
- (void)getFangroups:(NSInteger)competitionID;
- (void)postFangroup;
- (void)refresh:(id)sender;


@end
