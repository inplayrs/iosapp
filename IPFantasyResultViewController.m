//
//  IPFantasyResultViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPFantasyResultViewController.h"
#import "MFSideMenu.h"
#import "RestKit.h"
#import "PeriodOptions.h"
#import "IPFantasyResultCell.h"


@interface IPFantasyResultViewController ()

@end

@implementation IPFantasyResultViewController

@synthesize periodOptions, title, total, name, points, result, totalPoints;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = title;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-only.png"]];
    
    UINib *nib = [UINib nibWithNibName:@"IPFantasyResultCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"IPFantasyResultCell"];
    
    // this isn't needed on the rootViewController of the navigation controller
    [self.navigationController.sideMenu setupSideMenuBarButtonItem];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIView *)headerView
{
    if (!headerView) {
        [[NSBundle mainBundle] loadNibNamed:@"IPFantasyResultHeaderView" owner:self options:nil];
        name.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        points.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        result.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        totalPoints.font = [UIFont fontWithName:@"Avalon-Demi" size:12.0];
        name.textColor = [UIColor colorWithRed:189/255.0 green:233/255.0 blue:51/255.0 alpha:1];
        points.textColor = [UIColor colorWithRed:189/255.0 green:233/255.0 blue:51/255.0 alpha:1];
        result.textColor = [UIColor colorWithRed:189/255.0 green:233/255.0 blue:51/255.0 alpha:1];
        totalPoints.textColor = [UIColor colorWithRed:189/255.0 green:233/255.0 blue:51/255.0 alpha:1];
    }
    
    return headerView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [periodOptions count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PeriodOptions *periodOption = [periodOptions objectAtIndex:indexPath.row];
    IPFantasyResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IPFantasyResultCell"];

    UIImageView *imageView;
    if (indexPath.row % 2)
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-bar-2.png"]];
    else
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-bar-1.png"]];
    cell.backgroundView = imageView;
    [[cell name] setText:periodOption.name];
    [[cell points] setText:[NSString stringWithFormat:@"%d", (int)periodOption.points]];
    [[cell result] setText:[NSString stringWithFormat:@"%d", (int)periodOption.result]];
    total = periodOption.result * periodOption.points;
    [[cell total] setText:[NSString stringWithFormat:@"%d", (int)total]];
    cell.name.font = [UIFont fontWithName:@"Avalon-Demi" size:16.0];
    cell.points.font = [UIFont fontWithName:@"Avalon-Book" size:12.0];
    cell.result.font = [UIFont fontWithName:@"Avalon-Book" size:12.0];
    cell.total.font = [UIFont fontWithName:@"Avalon-Book" size:12.0];
    cell.name.textColor = [UIColor colorWithRed:32.0/255.0 green:35.0/255.0 blue:45.0/255.0 alpha:1.0];
    cell.points.textColor = [UIColor colorWithRed:32.0/255.0 green:35.0/255.0 blue:45.0/255.0 alpha:1.0];
    cell.result.textColor = [UIColor colorWithRed:32.0/255.0 green:35.0/255.0 blue:45.0/255.0 alpha:1.0];
    cell.total.textColor = [UIColor colorWithRed:32.0/255.0 green:35.0/255.0 blue:45.0/255.0 alpha:1.0];
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self headerView];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [[self headerView] bounds].size.height;
}



@end
