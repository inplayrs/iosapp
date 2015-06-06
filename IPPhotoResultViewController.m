//
//  IPPhotoResultViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 28/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPPhotoResultViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface IPPhotoResultViewController ()

@end

@implementation IPPhotoResultViewController

@synthesize url, caption, username, captionLabel, photoImageView;

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
    self.title = username;
    captionLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:12.0];
    captionLabel.text = caption;
    [photoImageView setImageWithURL:url];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
