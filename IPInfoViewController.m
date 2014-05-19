//
//  IPInfoViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 28/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPInfoViewController.h"
#import "MFSideMenu.h"

@interface IPInfoViewController ()

@end

@implementation IPInfoViewController

@synthesize infoView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc {
    self.navigationController.sideMenu.menuStateEventBlock = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // this isn't needed on the rootViewController of the navigation controller
    [self.navigationController.sideMenu setupSideMenuBarButtonItem];
    self.title = @"Info";
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.frame = CGRectMake(160.0, 160.0, 40.0, 40.0);
    activityIndicator.center = self.view.center;
    activityIndicator.color = [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0];
    activityIndicator.hidesWhenStopped = YES;
    [infoView addSubview:activityIndicator];
    [infoView bringSubviewToFront:activityIndicator];
    [activityIndicator startAnimating];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *urlAddress = @"http://storage.inplayrs.com/html/HowToPlay.html";
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [infoView loadRequest:requestObj];
}


- (void)webViewDidFinishLoad:(UIWebView *)wv
{
    [activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error
{
    [activityIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
