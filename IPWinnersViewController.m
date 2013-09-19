//
//  IPWinnersViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPWinnersViewController.h"
#import "MFSideMenu.h"
#import "RestKit.h"
#import "CompetitionWinners.h"
#import "IPAppDelegate.h"
#import "Error.h"


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

@interface IPWinnersViewController ()

@end

@implementation IPWinnersViewController

@synthesize winnersList;

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
    
    winnersList = [[NSMutableArray alloc] init];
    self.title = @"Winners";
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-only.png"]];
    
    // this isn't needed on the rootViewController of the navigation controller
    [self.navigationController.sideMenu setupSideMenuBarButtonItem];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getMyWinnersList:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getMyWinnersList:(id)sender
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager getObjectsAtPath:@"competition/winners" parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [winnersList removeAllObjects];
        NSArray* temp = [result array];
        for (int i=0; i<temp.count; i++) {
            CompetitionWinners *competitionWinners = [temp objectAtIndex:i];
            if (!competitionWinners.name)
                competitionWinners.name = @"Unassigned";
            [winnersList addObject:competitionWinners];
        }
        [winnersList sortUsingSelector:@selector(compareWithDate:)];
        [self.tableView reloadData];
    } failure:nil];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [winnersList count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"winnersCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
   
    CompetitionWinners *competitionWinners = [winnersList objectAtIndex:indexPath.row];
    NSString *competition = [competitionWinners.name stringByAppendingString:@":  "];
    NSString *winners = @"";
    if ([competitionWinners.winners count] > 0) {
        if ([competitionWinners.winners objectAtIndex:0])
            winners = [competitionWinners.winners objectAtIndex:0];
    }
    for (int i=1; i<[competitionWinners.winners count]; i++) {
        NSString *string = [competitionWinners.winners objectAtIndex:i];
        winners = [winners stringByAppendingFormat:@", %@", string];
    }
    competition = [competition stringByAppendingString:winners];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-row.png"]];
    [cell setBackgroundView:imageView];
    cell.textLabel.text = competition;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    // cell.textLabel.textColor = [UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"Avalon-Demi" size:14.0];
    
    switch (competitionWinners.category) {
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



@end
