//
//  IPNewInfoViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPNewInfoViewController.h"
#import "IPSettingsViewController.h"
#import "IPInfoViewController.h"
#import "MFSideMenu.h"
#import "Flurry.h"
#import "iRate.h"



@interface IPNewInfoViewController ()

@end

@implementation IPNewInfoViewController

@synthesize rateAppButton, emailFriendsButton, settingsButton, infoButton, settingsViewController, infoViewController;

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
    self.title = @"Info";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"screen-football-b.png"]];
    // this isn't needed on the rootViewController of the navigation controller
    [self.navigationController.sideMenu setupSideMenuBarButtonItem];
    
    UIImage *image = [UIImage imageNamed:@"login-button-normal.png"];
    UIImage *image2 = [UIImage imageNamed:@"login-button-hit.png"];
    UIImage *image3 = [UIImage imageNamed:@"login-button-disabled.png"];
    [self.rateAppButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.rateAppButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
    [self.rateAppButton setBackgroundImage:image3 forState:UIControlStateDisabled];
    self.rateAppButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
    [self.emailFriendsButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.emailFriendsButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
    [self.emailFriendsButton setBackgroundImage:image3 forState:UIControlStateDisabled];
    self.emailFriendsButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
    [self.settingsButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.settingsButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
    [self.settingsButton setBackgroundImage:image3 forState:UIControlStateDisabled];
    self.settingsButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
    [self.infoButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.infoButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
    [self.infoButton setBackgroundImage:image3 forState:UIControlStateDisabled];
    self.infoButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        self.rateAppButton.titleEdgeInsets = titleInsets;
        self.emailFriendsButton.titleEdgeInsets = titleInsets;
        self.settingsButton.titleEdgeInsets = titleInsets;
        self.infoButton.titleEdgeInsets = titleInsets;
    }
    
    settingsViewController = nil;
    infoViewController = nil;
    
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

- (IBAction)rateApp:(id)sender {
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"RateApp",
                                @"row", nil];
    [Flurry logEvent:@"MENU" withParameters:dictionary];
    [[iRate sharedInstance] openRatingsPageInAppStore];
}

- (IBAction)emailFriends:(id)sender {
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"EmailFriends",
                                @"row", nil];
    [Flurry logEvent:@"MENU" withParameters:dictionary];
    // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto: ?subject=Inplayrs&body=I'm playing Inplayrs, check it out at: http://www.inplayrs.com"]];

    NSString *recipients = @"mailto: ?subject=Inplayrs";
    NSString *body = @"&body=I'm playing Inplayrs, check it out at: http://www.inplayrs.com";
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
    
}


- (IBAction)launchSettings:(id)sender {
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Settings",
                                @"row", nil];
    [Flurry logEvent:@"MENU" withParameters:dictionary];
    if (!self.settingsViewController) {
        self.settingsViewController = [[IPSettingsViewController alloc] initWithNibName:@"IPSettingsViewController" bundle:nil];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        else
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    }
    if (self.settingsViewController)
        [self.navigationController pushViewController:self.settingsViewController animated:YES];
}

- (IBAction)launchInfo:(id)sender {
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"MoreInfo",
                                @"row", nil];
    [Flurry logEvent:@"MENU" withParameters:dictionary];
    if (!self.infoViewController) {
        self.infoViewController = [[IPInfoViewController alloc] initWithNibName:@"IPInfoViewController" bundle:nil];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        else
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    }
    if (self.infoViewController)
        [self.navigationController pushViewController:self.infoViewController animated:YES];
}




@end
