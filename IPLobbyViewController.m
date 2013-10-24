//
//  IPLobbyViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 22/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPLobbyViewController.h"
#import "MFSideMenu.h"
#import "IPGameViewController.h"
#import "IPLobbyItemCell.h"
#import "IPLobbyChildCell.h"
#import "Game.h"
#import "RestKit.h"
#import "IPAppDelegate.h"
#import "IPRegisterViewController.h"
#import "Competition.h"
#import "Banner.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "IPLoginFBViewController.h" // facebook session login


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

@interface IPLobbyViewController ()

@end

@implementation IPLobbyViewController

@synthesize controllerList, detailViewController, registerViewController, topItems, subItems, bannerImages, bannerItems, tempTopItems, tempSubItems, bannerButton, FaceBookRegisterViewController;


- (void) dealloc {
    self.navigationController.sideMenu.menuStateEventBlock = nil;
}

/*
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.dataController = [[LobbyDataController alloc] init];
}
*/


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        // self.tableView.delegate = self;
    }
    return self;
}

- (UIView *)headerView
{
    if (!headerView) {
        [[NSBundle mainBundle] loadNibNamed:@"IPBannerView" owner:self options:nil];
        UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeHeader:)];
        [swipeLeftGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
        [headerView addGestureRecognizer:swipeLeftGestureRecognizer];
        UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeHeader:)];
        [swipeRightGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
        [headerView addGestureRecognizer:swipeRightGestureRecognizer];
    }
    
    return headerView;
}

- (void)handleSwipeHeader:(UIGestureRecognizer*)recognizer
{
    if (([bannerItems count] < 2) || (self.gamesLoading))
        return;
    [timer invalidate];
    UISwipeGestureRecognizerDirection direction = [(UISwipeGestureRecognizer *)recognizer direction];
    switch (direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            imageIndex++;
            break;
        case UISwipeGestureRecognizerDirectionRight:
            imageIndex--;
            break;
        default:
            break;
    }
    imageIndex = (imageIndex < 0) ? ([bannerItems count] -1): imageIndex % [bannerItems count];
    Banner* banner = [bannerItems objectAtIndex:imageIndex];
    // UIImage* image = [UIImage imageNamed: @"inplayrs-banner.png"];
    if (banner) {
        [bannerButton setBackgroundImageWithURL:banner.bannerImageURL forState:UIControlStateNormal];
        [bannerButton setEnabled:YES];
    }
    /*
    imageIndex = (imageIndex < 0) ? ([bannerImages count] -1):
    imageIndex % [bannerImages count];
    bannerImageView.image = [bannerImages objectAtIndex:imageIndex];
     */
    timer = [NSTimer scheduledTimerWithTimeInterval:5.00 target:self selector:@selector(changeBanner:) userInfo:nil repeats:YES];
}

- (void)changeBanner:(id)sender
{
    if (self.gamesLoading)
        return;
    if ([bannerItems count] == 0) {
        UIImage* image = [UIImage imageNamed: @"inplayrs-banner.png"];
        [bannerButton setBackgroundImage:image forState:UIControlStateNormal];
        [bannerButton setEnabled:NO];
        return;
    }
        
    /*
    if (imageIndex < 0) {
        bannerImageView.image = [UIImage imageNamed:@"inplayrs-banner.png"];
        return;
    }
     */
    imageIndex++;
    imageIndex = (imageIndex < 0) ? ([bannerItems count] -1): imageIndex % [bannerItems count];
    Banner* banner = [bannerItems objectAtIndex:imageIndex];
    // UIImage* image = [UIImage imageNamed: @"inplayrs-banner.png"];
    if (banner) {
        [bannerButton setBackgroundImageWithURL:banner.bannerImageURL forState:UIControlStateNormal];
        [bannerButton setEnabled:YES];
    }
    /*
    imageIndex = (imageIndex < 0) ? ([bannerImages count] -1):
    imageIndex % [bannerImages count];
    bannerImageView.image = [bannerImages objectAtIndex:imageIndex];
     */
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // self.dataController = [[LobbyDataController alloc] init];
    self.title = @"Lobby";
    detailViewController = nil;
    registerViewController = nil;
    
    // this isn't needed on the rootViewController of the navigation controller
    // [self.navigationController.sideMenu setupSideMenuBarButtonItem];
    
    UINib *nib = [UINib nibWithNibName:@"IPLobbyItemCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"IPLobbyItemCell"];
    UINib *childNib = [UINib nibWithNibName:@"IPLobbyChildCell" bundle:nil];
    [[self tableView] registerNib:childNib forCellReuseIdentifier:@"IPLobbyChildCell"];
    [self.tableView setAlwaysBounceVertical:YES];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-only.png"]];
    // self.edgesForExtendedLayout = UIRectEdgeNone;
    // self.extendedLayoutIncludesOpaqueBars = YES;
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    self.controllerList = [[NSMutableDictionary alloc] init];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh" attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0]}];
    refresh.tintColor = [UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0];
    [refresh addTarget:self
                action:@selector(refreshView:)
                forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    self.gamesLoading = YES;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *savedUser = [prefs objectForKey:@"user"];
    if (savedUser) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:savedUser style:UIBarButtonItemStylePlain target:self action:nil];
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0];
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0],UITextAttributeFont,nil];
        [self.navigationItem.rightBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [self.navigationItem.rightBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateDisabled];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Register" style:UIBarButtonItemStylePlain target:self action:@selector(loginPressed:)];
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0];
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0],UITextAttributeFont,nil];
        [self.navigationItem.rightBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    
    topItems = [[NSMutableArray alloc] init];
    subItems = [[NSMutableArray alloc] init];
    tempTopItems = [[NSMutableArray alloc] init];
    tempSubItems = [[NSMutableArray alloc] init];
    bannerItems = [[NSMutableArray alloc] init];
    bannerImages = [[NSMutableArray alloc] init];
    currentExpandedIndex = -1;
    imageIndex = -1;
    
    [self.tableView setTableHeaderView:[self headerView]];
    
    [NSTimer scheduledTimerWithTimeInterval:.06 target:self selector:@selector(getCompetitions:) userInfo:nil repeats:NO];
    // timer = [NSTimer scheduledTimerWithTimeInterval:5.00 target:self selector:@selector(changeBanner:) userInfo:nil repeats:YES];
    // [self getGames:self];
    // [self viewDidAppear:YES];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.loggedin) {
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0];
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0],UITextAttributeFont,nil];
        [self.navigationItem.rightBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [self.navigationItem.rightBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateDisabled];
        [self.navigationItem.rightBarButtonItem setTitle:appDelegate.user];
        [self.navigationItem.rightBarButtonItem setAction:nil];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0]];
    } else {
        [self.navigationItem.rightBarButtonItem setTitle:@"Register"];
        [self.navigationItem.rightBarButtonItem setAction:@selector(loginPressed:)];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        if (appDelegate.refreshLobby)
            [self.controllerList removeAllObjects];
    }
    
    if ((appDelegate.refreshLobby) && (self.gamesLoading == NO)) {
        self.gamesLoading = YES;
        [self getCompetitions:self];
    } else if (self.gamesLoading == NO) {
        [self.tableView reloadData];
        //if (topRowSelected)
        //    [self.tableView selectRowAtIndexPath:topRowSelected animated:NO scrollPosition:UITableViewScrollPositionNone];
        if (!timer)
            timer = [NSTimer scheduledTimerWithTimeInterval:5.00 target:self selector:@selector(changeBanner:) userInfo:nil repeats:YES];
    }
}


- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [timer invalidate];
    timer = nil;
}


// facebook session login//

- (void) loginPressed:(id)sender {
    if (!self.FaceBookRegisterViewController) {
        self.FaceBookRegisterViewController = [[IPLoginFBViewController alloc] initWithNibName:@"IPLoginFBViewController"bundle:nil];
    }
    if (self.FaceBookRegisterViewController)
        [self.navigationController pushViewController:self.FaceBookRegisterViewController animated:YES];
}

/* OLD LOGIN VC
- (void) loginPressed:(id)sender {
    if (!self.registerViewController) {
        self.registerViewController = [[IPRegisterViewController alloc] initWithNibName:@"IPMultiLoginViewController" bundle:nil];
    }
    if (self.registerViewController)
        [self.navigationController pushViewController:self.registerViewController animated:YES];
}
*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)getCompetitions:(id)sender
{
    self.gamesRequested = 0;
    self.gamesResponded = 0;
    NSMutableArray *completedItems = [[NSMutableArray alloc] init];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager getObjectsAtPath:@"competition/list" parameters:nil success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
         NSArray* temp = [result array];
         NSDateFormatter *startingDateFormat = [[NSDateFormatter alloc] init];
         NSDateFormatter *endingDateFormat = [[NSDateFormatter alloc] init];
         [startingDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
         [endingDateFormat setDateFormat:@"MM-dd HH:mm"];
         [startingDateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
         [endingDateFormat setTimeZone:[NSTimeZone systemTimeZone]];
         NSMutableArray *defaultSubItems = [[NSMutableArray alloc] init];
         Game *game = [[Game alloc] initWithGameID:0 name:@"Loading..." startDate:@"" state:COMPLETED category:FOOTBALL type:20 entered:NO];
         [defaultSubItems addObject:game];
         [bannerItems removeAllObjects];
         [bannerImages removeAllObjects];
         [tempTopItems removeAllObjects];
         [tempSubItems removeAllObjects];
         for (int i=0; i<temp.count; i++) {
             Competition *competition = [temp objectAtIndex:i];
             if (!competition.name)
                 competition.name = @"";
             if (!competition.startDate) {
                 competition.startDate = @"";
             } else {
                 NSDate *date = [startingDateFormat dateFromString:competition.startDate];
                 competition.startDate = [endingDateFormat stringFromDate:date];
             }
             if (competition.state == COMPLETED)
                 [completedItems addObject:competition];
             else
                 [tempTopItems addObject:competition];
             [tempSubItems addObject:defaultSubItems];
         }
         [completedItems sortUsingSelector:@selector(compareWithDate:)];
         [tempTopItems sortUsingSelector:@selector(compareWithDate:)];
         [tempTopItems addObjectsFromArray:completedItems];
         
         for (int i=0; i<[tempTopItems count]; i++) {
             Competition *competition = [tempTopItems objectAtIndex:i];
             [self getGames:competition.competitionID order:i competitionName:competition.name];
         }
         NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
         [formatter setDateFormat:@"MM-dd HH:mm"];
         NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                                  [formatter stringFromDate:[NSDate date]]];
         self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0]}];
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        // NSLog(@"Failed with error: %@", [error localizedDescription]);
        self.gamesLoading = NO;
        [self.refreshControl endRefreshing];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No connection" message:@"Please check your network connection and pull down to refresh!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}


- (void)getGames:(NSInteger)competitionID order:(NSUInteger)order competitionName:(NSString *)competitionName
{
    NSMutableArray *inplayItems = [[NSMutableArray alloc] init];
    NSMutableArray *completedItems = [[NSMutableArray alloc] init];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"competition/games?comp_id=%d", competitionID];
    self.gamesRequested++;
    [objectManager getObjectsAtPath:path parameters:nil success:
    ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSArray* temp = [result array];
        NSDateFormatter *startingDateFormat = [[NSDateFormatter alloc] init];
        NSDateFormatter *endingDateFormat = [[NSDateFormatter alloc] init];
        [startingDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [endingDateFormat setDateFormat:@"MM-dd HH:mm"];
        [startingDateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [endingDateFormat setTimeZone:[NSTimeZone systemTimeZone]];
        for (int i=0; i<temp.count; i++) {
            Game *game = [temp objectAtIndex:i];
            // data checking and formatting
            if (!game.name)
                game.name = @"";
            if (!game.startDate) {
                game.startDate = @"";
            } else {
                NSDate *date = [startingDateFormat dateFromString:game.startDate];
                game.startDate = [endingDateFormat stringFromDate:date];
            }
            game.competitionID = competitionID;
            game.competitionName = competitionName;
            if (game.state == COMPLETED)
                [completedItems addObject:game];
            else
                [inplayItems addObject:game];
            if (game.bannerPosition > 0) {
                Banner *banner = [[Banner alloc] initWithPosition:game.bannerPosition bannerImageURL:game.bannerImageURL game:game];
                [bannerItems addObject:banner];
            }
        }
        [inplayItems sortUsingSelector:@selector(compareWithGame:)];
        [completedItems sortUsingSelector:@selector(compareWithGameReverse:)];
        [inplayItems addObjectsFromArray:completedItems];
        [tempSubItems replaceObjectAtIndex:order withObject:inplayItems];
        // NSLog (@"tempSubitem num =%d, count=%d", order, [[tempSubItems objectAtIndex:order] count]);
        self.gamesResponded++;
        if (self.gamesRequested == self.gamesResponded) {
            [topItems removeAllObjects];
            [subItems removeAllObjects];
            [topItems addObjectsFromArray:tempTopItems];
            [subItems addObjectsFromArray:tempSubItems];
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
            
            NSSortDescriptor *rankSorter = [[NSSortDescriptor alloc] initWithKey:@"bannerPosition" ascending:YES];
            [bannerItems sortUsingDescriptors:[NSArray arrayWithObject:rankSorter]];
            /*
            for (int i=0; i<[bannerItems count]; i++) {
                Banner *banner = [bannerItems objectAtIndex:i];
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:banner.bannerImageURL]]];
                if (image)
                    [bannerImages addObject:image];
            }
            imageIndex = ([bannerImages count]-1);
             */
            self.gamesLoading = NO;
            imageIndex = -1;
            // [self changeBanner:self];
            if (!timer)
                timer = [NSTimer scheduledTimerWithTimeInterval:5.00 target:self selector:@selector(changeBanner:) userInfo:nil repeats:YES];
            IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.refreshLobby = NO;
        }

    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        self.gamesLoading = NO;
        [self.refreshControl endRefreshing];
    }];
    
    
}


-(void)refreshView:(UIRefreshControl *)refresh
{
    if (!self.gamesLoading) {
        self.gamesLoading = YES;
        [self getCompetitions:self];
    } else {
        [self.refreshControl endRefreshing];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [topItems count] + ((currentExpandedIndex > -1) ? [[subItems objectAtIndex:currentExpandedIndex] count] : 0);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BOOL isChild =
    currentExpandedIndex > -1
    && indexPath.row > currentExpandedIndex
    && indexPath.row <= currentExpandedIndex + [[subItems objectAtIndex:currentExpandedIndex] count];
    
    
    if (isChild) {
        IPLobbyChildCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IPLobbyChildCell"];
        cell.nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
        cell.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
        Game *gameAtIndex = [[subItems objectAtIndex:currentExpandedIndex] objectAtIndex:indexPath.row - currentExpandedIndex - 1];
        [[cell nameLabel] setText:gameAtIndex.name];
        cell.nameLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        if (gameAtIndex.state == INPLAY) {
            UIImage *image = [UIImage imageNamed: @"green_dot.png"];
            [[cell inplayIcon] setImage:image];
            [[cell inplayIcon] setHidden:NO];
            [[cell timeLabel] setText:@""];
        } else if ((gameAtIndex.state == PREPLAY) || (gameAtIndex.state == SUSPENDED)) {
            [[cell timeLabel] setText:gameAtIndex.startDate];
            cell.timeLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
            [[cell inplayIcon] setHidden:YES];
        } else if (gameAtIndex.state == COMPLETED) {
            [[cell timeLabel] setText:@"DONE"];
            // cell.timeLabel.textColor = [UIColor darkGrayColor];
            // cell.nameLabel.textColor = [UIColor darkGrayColor];
            cell.timeLabel.textColor = [UIColor colorWithRed:45.0/255.0 green:45.0/255.0 blue:45.0/255.0 alpha:1.0];
            cell.nameLabel.textColor = [UIColor colorWithRed:45.0/255.0 green:45.0/255.0 blue:45.0/255.0 alpha:1.0];
            [[cell inplayIcon] setHidden:YES];
            // IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
            // appDelegate.refreshLobby = YES;
        } else {
            [[cell timeLabel] setText:@""];
            [[cell inplayIcon] setHidden:YES];
        }
        if (gameAtIndex.entered) {
            UIImage *checkImage = [UIImage imageNamed: @"entered-tick.png"];
            [[cell enteredIcon] setImage:checkImage];
            [[cell enteredIcon] setHidden:NO];
        } else {
            [[cell enteredIcon] setHidden:YES];
        }
        cell.nameLabel.backgroundColor = [UIColor clearColor];
        cell.timeLabel.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-sub-row.png"]];
        // UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-row.png"]];
        cell.backgroundView = imageView;
        // cell.selectedBackgroundView = nil;
        
        return cell;
    } else {
        IPLobbyItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IPLobbyItemCell"];
        cell.nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
        cell.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
        int topIndex = (currentExpandedIndex > -1 && indexPath.row > currentExpandedIndex)
        ? indexPath.row - [[subItems objectAtIndex:currentExpandedIndex] count]
        : indexPath.row;
        Competition *competition = [topItems objectAtIndex:topIndex];
        [cell setCompetitionState:competition.state];
        [[cell nameLabel] setText:competition.name];
        cell.nameLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        if (competition.state == INPLAY) {
            UIImage *image = [UIImage imageNamed: @"green_dot.png"];
            [[cell inplayIcon] setImage:image];
            [[cell inplayIcon] setHidden:NO];
            [[cell timeLabel] setText:@""];
        } else if ((competition.state == PREPLAY) || (competition.state == SUSPENDED)) {
            [[cell timeLabel] setText:competition.startDate];
            cell.timeLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
            [[cell inplayIcon] setHidden:YES];
        } else if (competition.state == COMPLETED) {
            [[cell timeLabel] setText:@"DONE"];
            cell.timeLabel.textColor = [UIColor colorWithRed:45.0/255.0 green:45.0/255.0 blue:45.0/255.0 alpha:1.0];
            cell.nameLabel.textColor = [UIColor colorWithRed:45.0/255.0 green:45.0/255.0 blue:45.0/255.0 alpha:1.0];
            [[cell inplayIcon] setHidden:YES];
            // IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
            // appDelegate.refreshLobby = YES;
        } else {
            [[cell timeLabel] setText:@""];
            [[cell inplayIcon] setHidden:YES];
        }
        
        cell.nameLabel.backgroundColor = [UIColor clearColor];
        cell.timeLabel.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lobby-main-row.png"]];
        cell.backgroundView = imageView;
        // cell.selectedBackgroundView = nil;
        
        switch (competition.category) {
            case (FOOTBALL): {
                UIImage *image = [UIImage imageNamed: @"football.png"];
                [[cell categoryIcon] setImage:image];
                break;
            }
            case (BASKETBALL): {
                UIImage *image = [UIImage imageNamed: @"basketball.png"];
                [[cell categoryIcon] setImage:image];
                break;
            }
            case (TENNIS): {
                UIImage *image = [UIImage imageNamed: @"tennis.png"];
                [[cell categoryIcon] setImage:image];
                break;
            }
            case (GOLF): {
                UIImage *image = [UIImage imageNamed: @"golf.png"];
                [[cell categoryIcon] setImage:image];
                break;
            }
            case (SNOOKER): {
                UIImage *image = [UIImage imageNamed: @"snooker.png"];
                [[cell categoryIcon] setImage:image];
                break;
            }
            case (MOTORRACING): {
                UIImage *image = [UIImage imageNamed: @"motor-racing.png"];
                [[cell categoryIcon] setImage:image];
                break;
            }
            case (CRICKET): {
                UIImage *image = [UIImage imageNamed: @"cricket.png"];
                [[cell categoryIcon] setImage:image];
                break;
            }
            case (RUGBY): {
                UIImage *image = [UIImage imageNamed: @"rugby.png"];
                [[cell categoryIcon] setImage:image];
                break;
            }
            case (BASEBALL): {
                UIImage *image = [UIImage imageNamed: @"baseball.png"];
                [[cell categoryIcon] setImage:image];
                break;
            }
            case (ICEHOCKEY): {
                UIImage *image = [UIImage imageNamed: @"ice-hockey.png"];
                [[cell categoryIcon] setImage:image];
                break;
            }
            case (AMERICANFOOTBALL): {
                UIImage *image = [UIImage imageNamed: @"american-football.png"];
                [[cell categoryIcon] setImage:image];
                break;
            }
            case (FINANCE): {
                UIImage *image = [UIImage imageNamed: @"finance.png"];
                [[cell categoryIcon] setImage:image];
                break;
            }
            case (REALITYTV): {
                UIImage *image = [UIImage imageNamed: @"reality-tv.png"];
                [[cell categoryIcon] setImage:image];
                break;
            }
            case (AWARDS): {
                UIImage *image = [UIImage imageNamed: @"awards.png"];
                [[cell categoryIcon] setImage:image];
                break;
            }
            default: {
                UIImage *image = [UIImage imageNamed: @"football.png"];
                [[cell categoryIcon] setImage:image];
                break;
            }
        }
        
        return cell;
    }
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isChild =
    currentExpandedIndex > -1
    && indexPath.row > currentExpandedIndex
    && indexPath.row <= currentExpandedIndex + [[subItems objectAtIndex:currentExpandedIndex] count];
    
    if (isChild) {
        Game *game = [[subItems objectAtIndex:currentExpandedIndex] objectAtIndex:(indexPath.row - currentExpandedIndex - 1)];
        
        
        if ([controllerList objectForKey:game.name] == nil) {
            detailViewController = [[IPGameViewController alloc] initWithNibName:@"IPGameViewController" bundle:nil];
            detailViewController.game = game;
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil];
            [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
            [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0]];
            [controllerList setObject:detailViewController forKey:game.name];
            
        }
        
        if ([controllerList objectForKey:game.name] == nil) {
            NSLog (@"something wrong");
        } else {
            [self.navigationController pushViewController:[controllerList objectForKey:game.name] animated:YES];
        }
        return;
    }
    
    [self.tableView beginUpdates];
    
    if (currentExpandedIndex == indexPath.row) {
        [self collapseSubItemsAtIndex:currentExpandedIndex];
        currentExpandedIndex = -1;
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        
        BOOL shouldCollapse = currentExpandedIndex > -1;
        
        if (shouldCollapse) {
            [self collapseSubItemsAtIndex:currentExpandedIndex];
            // [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        }
        
        currentExpandedIndex = (shouldCollapse && indexPath.row > currentExpandedIndex) ? indexPath.row - [[subItems objectAtIndex:currentExpandedIndex] count] : indexPath.row;
        
        [self expandItemAtIndex:currentExpandedIndex];
        // topRowSelected = indexPath;
    }
    
    [self.tableView endUpdates];
    
    // check if last row to scroll again
    if (indexPath.row == [topItems count] - 1) {
        int newIndex = [self.tableView numberOfRowsInSection:0] - 1;
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:newIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    
}

- (void)expandItemAtIndex:(int)index {
    NSMutableArray *indexPaths = [NSMutableArray new];
    NSArray *currentSubItems = [subItems objectAtIndex:index];
    int insertPos = index + 1;
    for (int i = 0; i < [currentSubItems count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:insertPos++ inSection:0]];
    }
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)collapseSubItemsAtIndex:(int)index {
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (int i = index + 1; i <= index + [[subItems objectAtIndex:index] count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self headerView];

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [[self headerView] bounds].size.height;

}
*/

- (IBAction)clickBanner:(id)sender
{
    if ((imageIndex < 0) || (self.gamesLoading))
        return;
    Banner *banner = [bannerItems objectAtIndex:imageIndex];
    Game *game = banner.game;
    
    
    if ([controllerList objectForKey:game.name] == nil) {
        detailViewController = [[IPGameViewController alloc] initWithNibName:@"IPGameViewController" bundle:nil];
        detailViewController.game = game;
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil];
        [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0]];
        [controllerList setObject:detailViewController forKey:game.name];
        
    }
    
    if ([controllerList objectForKey:game.name]) {
        [self.navigationController pushViewController:[controllerList objectForKey:game.name] animated:YES];
    }
}



@end
