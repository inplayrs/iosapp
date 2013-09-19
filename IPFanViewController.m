//
//  IPFanViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPFanViewController.h"
#import "MFSideMenu.h"
#import "FanDataController.h"
#import "RestKit.h"
#import "Competition.h"
#import "Fangroup.h"
#import "Fan.h"
#import "IPAppDelegate.h"
#import "Error.h"
#import "Game.h"

#define COMPETITIONS 1
#define FANGROUPS 2
#define SELECTBUTTON 0

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

@interface IPFanViewController ()

@end

@implementation IPFanViewController

@synthesize fangroupButton, competitionButton, selectedCompetitionID, selectedCompetitionRow, selectedFangroupID, selectedFangroupRow;

- (void) dealloc {
    self.navigationController.sideMenu.menuStateEventBlock = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setGame:(Game *) newGame
{
    if (_game != newGame) {
        _game = newGame;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataController = [[FanDataController alloc] init];
    self.title = @"Fan";
    
    // this isn't needed on the rootViewController of the navigation controller
    [self.navigationController.sideMenu setupSideMenuBarButtonItem];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-only.png"]];
    
    self.selectedCompetitionID = -1;
    self.selectedFangroupID = -1;
    self.selectedCompetitionRow = -1;
    self.selectedFangroupRow = -1;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.fangroupButton setEnabled:NO];
    [self getMyFanList:self];
    
    if (self.game) {
        [self.competitionButton setTitle:self.game.competitionName forState:UIControlStateNormal];
        self.selectedCompetitionID = self.game.competitionID;
        [self getFangroups:self.selectedCompetitionID];
        [self.competitionButton setEnabled:NO];
    } else {
        [self.competitionButton setTitle:@"PICK COMPETITION" forState:UIControlStateNormal];
        [self getCompetitions:self];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (UIView *)footerView
{
    if (!footerView) {
        [[NSBundle mainBundle] loadNibNamed:@"IPFanFooterView" owner:self options:nil];
        UIImage *image = [UIImage imageNamed:@"submit-button.png"];
        UIImage *image2 = [UIImage imageNamed:@"submit-button-hit-state.png"];
        UIImage *image3 = [UIImage imageNamed:@"grey-button.png"];
        [self.competitionButton setBackgroundImage:image forState:UIControlStateNormal];
        [self.competitionButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
        [self.competitionButton setBackgroundImage:image3 forState:UIControlStateDisabled];
        [self.fangroupButton setBackgroundImage:image forState:UIControlStateNormal];
        [self.fangroupButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
        [self.fangroupButton setBackgroundImage:image3 forState:UIControlStateDisabled];
        self.competitionButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
        self.fangroupButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
    }
    
    return footerView;
}


- (void)getMyFanList:(id)sender
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager getObjectsAtPath:@"user/fangroups" parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [self.dataController.myFanList removeAllObjects];
        NSArray* temp = [result array];
        for (int i=0; i<temp.count; i++) {
            Fan *fan = [temp objectAtIndex:i];
            if (!fan.competitionName)
                fan.competitionName = @"Unassigned";
            if (!fan.fangroupName)
                fan.fangroupName = @"Unassigned";
            [self.dataController.myFanList addObject:fan];
        }
        [self.dataController.myFanList sortUsingSelector:@selector(compareWithName:)];
        [self refresh:self];
    } failure:nil];
}

- (void)getCompetitions:(id)sender
{
    [self.competitionButton setEnabled:NO];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager getObjectsAtPath:@"competition/list" parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [self.dataController.competitionList removeAllObjects];
        NSArray* temp = [result array];
        for (int i=0; i<temp.count; i++) {
            Competition *competition = [temp objectAtIndex:i];
            if (competition.name)
                [self.dataController.competitionList addObject:competition];
        }
        [self.dataController.competitionList sortUsingSelector:@selector(compareWithName:)];
        [self.competitionButton setEnabled:YES];
    } failure:nil];
}

- (void)getFangroups:(NSInteger)competitionID
{
    [self.fangroupButton setEnabled:NO];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"competition/fangroups?comp_id=%d", competitionID];
    [objectManager getObjectsAtPath:path parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [self.dataController.fangroupList removeAllObjects];
        NSArray* temp = [result array];
        for (int i=0; i<temp.count; i++) {
            Fangroup *fangroup = [temp objectAtIndex:i];
            if ((!fangroup.name) || ([fangroup.name isEqualToString:@"Monkey FG"])) {
                // dont add
            } else {
                [self.dataController.fangroupList addObject:fangroup];
            }
        }
        [self.dataController.fangroupList sortUsingSelector:@selector(compareWithName:)];
        [self.fangroupButton setEnabled:YES];
     } failure:nil];
}

- (void)postFangroup
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"user/fan?comp_id=%d&fangroup_id=%d", self.selectedCompetitionID, self.selectedFangroupID];
    [objectManager postObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [self getMyFanList:self];
        [self.dataController.fangroupList removeAllObjects];
        self.selectedFangroupRow = -1;
        self.selectedCompetitionRow = -1;
        if (self.game) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fangroup Successful" message:@"You have selected your fangroup for the duration of the competition." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.fangroupButton setEnabled:NO];
            [self.competitionButton setEnabled:YES];
            [self.competitionButton setTitle:@"PICK COMPETITION" forState:UIControlStateNormal];
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        [self.dataController.fangroupList removeAllObjects];
        self.selectedFangroupRow = -1;
        self.selectedCompetitionRow = -1;
        if (!self.game) {
            [self.fangroupButton setEnabled:NO];
            [self.competitionButton setEnabled:YES];
            [self.competitionButton setTitle:@"PICK COMPETITION" forState:UIControlStateNormal];
        }
        NSArray *errorMessages = [[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey];
        Error *myerror = [errorMessages objectAtIndex:0];
        if (!myerror.message)
            myerror.message = @"Please try again later!";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Failed" message:myerror.message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];


}


-(void)refresh:(id)sender
{
    [self.tableView reloadData];
    
}


#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == COMPETITIONS) {
        return [self.dataController.competitionList count];
    } else {
        return [self.dataController.fangroupList count];
    }

}


- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (pickerView.tag == COMPETITIONS) {
        Competition *competition = [self.dataController.competitionList objectAtIndex:row];
        if (row == 0) {
            self.selectedCompetitionID = competition.competitionID;
            self.selectedCompetitionRow = 0;
        }
        return competition.name;
    } else {
        Fangroup *fangroup = [self.dataController.fangroupList objectAtIndex:row];
        if (row == 0) {
            self.selectedFangroupID = fangroup.fangroupID;
            self.selectedFangroupRow = 0;
        }
        return fangroup.name;
    }
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    if (pickerView.tag == COMPETITIONS) {
        Competition* competition = [self.dataController.competitionList objectAtIndex:row];
        self.selectedCompetitionID = competition.competitionID;
        self.selectedCompetitionRow = row;
    } else {
        Fangroup* fangroup = [self.dataController.fangroupList objectAtIndex:row];
        self.selectedFangroupID = fangroup.fangroupID;
        self.selectedFangroupRow = row;
    }
}

/*
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
    }
    tView.font = [UIFont systemFontOfSize:18];
    if (component == 0) {
        Competition *competition = [self.dataController.competitionList objectAtIndex:row];
        NSLog(@"%@", competition.name);
        tView.text = competition.name;
    } else {
        tView.text = [self.dataController.fanGroupList objectAtIndex:row];
    }
    return tView;
    
}
*/


- (IBAction)submitCompetition:(id)sender {
    
    if ([self.dataController.competitionList count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Competitions" message:@"No competitions available, please check your network connection!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self     cancelButtonTitle:@"CANCEL" destructiveButtonTitle:nil otherButtonTitles:@"SELECT", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = COMPETITIONS;
    
    
    UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 150, 320, 320)];
    picker.showsSelectionIndicator=YES;
    picker.dataSource = self;
    picker.delegate = self;
    picker.tag = COMPETITIONS;
    
    
    [actionSheet addSubview:picker];
    [picker selectRow:0 inComponent:0 animated:NO];
    [actionSheet showInView:self.view];
    [actionSheet setBounds:CGRectMake(0, 0, 320, 580)];
    
}

                            
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == COMPETITIONS)
    {
        if (buttonIndex == SELECTBUTTON) {
            Competition *competition = [self.dataController.competitionList objectAtIndex:self.selectedCompetitionRow];
            [self.competitionButton setTitle:competition.name forState:UIControlStateNormal];
            // [self.fangroupButton setEnabled:YES];
            [self getFangroups:self.selectedCompetitionID];
            [self.competitionButton setEnabled:NO];
        }
    } else if (actionSheet.tag == FANGROUPS) {
        if (buttonIndex == SELECTBUTTON) {
            IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
            if (appDelegate.loggedin == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login required" message:@"Please login first!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
        
            [self postFangroup];
        }
         /*
        [self.fangroupButton setEnabled:NO];
        [self.competitionButton setEnabled:YES];
        [self.competitionButton setTitle:@"PICK COMPETITION" forState:UIControlStateNormal];
        
        Competition *competition = [self.dataController.competitionList objectAtIndex:selectedCompetitionRow];
        Fangroup *fangroup = [self.dataController.fangroupList objectAtIndex:selectedFangroupRow];
        Boolean found = NO;
        
        for (int i=0; i < [self.dataController.myFanList count]; i++) {
            Fan *fan = [self.dataController.myFanList objectAtIndex:i];
            if ([fan.competitionName isEqualToString:competition.name]) {
                fan.fangroupName = fangroup.name;
                fan.fangroupID = fangroup.fangroupID;
                [self.dataController.myFanList replaceObjectAtIndex:i withObject:fan];
                found = YES;
                break;
            }
        }
        if (!found) {
            Fan *fan = [[Fan alloc] initWithCompetitionName:competition.name fangroupName:fangroup.name fangroupID:fangroup.fangroupID];
            [self.dataController.myFanList addObject:fan];
        }
        
        [self.tableView reloadData];
        [self.dataController.fangroupList removeAllObjects];
        self.selectedFangroupRow = -1;
        self.selectedCompetitionRow = -1;
        */
    }
}

- (IBAction)submitFangroup:(id)sender {
    
    if ([self.dataController.fangroupList count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Fan Groups" message:@"No fan groups available for this competition!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        if (!self.game) {
            [self.fangroupButton setEnabled:NO];
            [self.competitionButton setEnabled:YES];
            [self.competitionButton setTitle:@"PICK COMPETITION" forState:UIControlStateNormal];
        }
        return;
    }
        
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self     cancelButtonTitle:@"CANCEL" destructiveButtonTitle:nil otherButtonTitles:@"SELECT", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = FANGROUPS;
    
    
    UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 150, 320, 320)];
    picker.showsSelectionIndicator=YES;
    picker.dataSource = self;
    picker.delegate = self;
    picker.tag = FANGROUPS;
    
    
    [actionSheet addSubview:picker];
    [picker selectRow:0 inComponent:0 animated:NO];
    [actionSheet showInView:self.view];
    [actionSheet setBounds:CGRectMake(0, 0, 320, 580)];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.dataController.myFanList count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"fanCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
   
    Fan *fan = [self.dataController.myFanList objectAtIndex:indexPath.row];
    NSString *string = [fan.competitionName stringByAppendingString:@": "];
    string = [string stringByAppendingString:fan.fangroupName];
    
    // UIImageView *imageViewSelected = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-row-hit-state.png"]];
    // [cell setSelectedBackgroundView:imageViewSelected];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-row.png"]];
    [cell setBackgroundView:imageView];
   
    cell.textLabel.text = string;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    // cell.textLabel.highlightedTextColor = [UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:14.0];
    switch (fan.category) {
        case (FOOTBALL): {
            UIImage *image = [UIImage imageNamed: @"football.png"];
            cell.imageView.image = image;
            break;
        }
        case (BASKETBALL): {
            UIImage *image = [UIImage imageNamed: @"basketball.png"];
            cell.imageView.image = image;
            break;
        }
        case (TENNIS): {
            UIImage *image = [UIImage imageNamed: @"tennis.png"];
            cell.imageView.image = image;
            break;
        }
        case (GOLF): {
            UIImage *image = [UIImage imageNamed: @"golf.png"];
            cell.imageView.image = image;
            break;
        }
        case (SNOOKER): {
            UIImage *image = [UIImage imageNamed: @"snooker.png"];
            cell.imageView.image = image;
            break;
        }
        case (MOTORRACING): {
            UIImage *image = [UIImage imageNamed: @"motor-racing.png"];
            cell.imageView.image = image;
            break;
        }
        case (CRICKET): {
            UIImage *image = [UIImage imageNamed: @"cricket.png"];
            cell.imageView.image = image;
            break;
        }
        case (RUGBY): {
            UIImage *image = [UIImage imageNamed: @"rugby.png"];
            cell.imageView.image = image;
            break;
        }
        case (BASEBALL): {
            UIImage *image = [UIImage imageNamed: @"baseball.png"];
            cell.imageView.image = image;
            break;
        }
        case (ICEHOCKEY): {
            UIImage *image = [UIImage imageNamed: @"ice-hockey.png"];
            cell.imageView.image = image;
            break;
        }
        case (AMERICANFOOTBALL): {
            UIImage *image = [UIImage imageNamed: @"american-football.png"];
            cell.imageView.image = image;
            break;
        }
        case (FINANCE): {
            UIImage *image = [UIImage imageNamed: @"finance.png"];
            cell.imageView.image = image;
            break;
        }
        case (REALITYTV): {
            UIImage *image = [UIImage imageNamed: @"reality-tv.png"];
            cell.imageView.image = image;
            break;
        }
        case (AWARDS): {
            UIImage *image = [UIImage imageNamed: @"awards.png"];
            cell.imageView.image = image;
            break;
        }
        default: {
            UIImage *image = [UIImage imageNamed: @"football.png"];
            cell.imageView.image = image;
            break;
        }
    }
    
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [self footerView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return [[self footerView] bounds].size.height;
}


@end
