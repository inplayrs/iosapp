//
//  IPTutorialViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 28/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPTutorialViewController.h"
#import "MFSideMenu.h"
#import "Flurry.h"

#define IS_WIDESCREEN ( [ [ UIScreen mainScreen ] bounds ].size.height == 568 )

@interface IPTutorialViewController ()

@end

@implementation IPTutorialViewController

@synthesize tutorialImageView, topImages, globalButton, fangroupButton, h2hButton, leftButton, rightButton;

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
    [self.navigationController.sideMenu setupSideMenuBarButtonItem];
    self.title = @"Tutorial";
    
    UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeImage:)];
    [swipeLeftGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [tutorialImageView addGestureRecognizer:swipeLeftGestureRecognizer];
    UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeImage:)];
    [swipeRightGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [tutorialImageView addGestureRecognizer:swipeRightGestureRecognizer];
    
    topImages = [[NSMutableArray alloc] init];
    if (IS_WIDESCREEN) {
        UIImage *image1 = [UIImage imageNamed:@"screen_1@568.png"];
        UIImage *image2 = [UIImage imageNamed:@"screen_2@568.png"];
        UIImage *image3 = [UIImage imageNamed:@"screen_3@568.png"];
        UIImage *image4 = [UIImage imageNamed:@"screen_6@568.png"];
        UIImage *image5 = [UIImage imageNamed:@"screen_7@568.png"];
        [topImages addObject:image1];
        [topImages addObject:image2];
        [topImages addObject:image3];
        [topImages addObject:image4];
        [topImages addObject:image5];
        tutorialImageView.frame = CGRectMake(0, 0, 320, 504);
        tutorialImageView.image = image1;
    } else {
        UIImage *image1 = [UIImage imageNamed:@"screen_1.png"];
        UIImage *image2 = [UIImage imageNamed:@"screen_2.png"];
        UIImage *image3 = [UIImage imageNamed:@"screen_3.png"];
        UIImage *image4 = [UIImage imageNamed:@"screen_6.png"];
        UIImage *image5 = [UIImage imageNamed:@"screen_7.png"];
        [topImages addObject:image1];
        [topImages addObject:image2];
        [topImages addObject:image3];
        [topImages addObject:image4];
        [topImages addObject:image5];
        tutorialImageView.image = image1;
    }
    
    imageIndex = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [Flurry logEvent:@"TUTORIAL"];
}

- (void) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)handleSwipeImage:(UIGestureRecognizer*)recognizer
{
    UISwipeGestureRecognizerDirection direction = [(UISwipeGestureRecognizer *)recognizer direction];
    switch (direction) {
        case UISwipeGestureRecognizerDirectionLeft: {
            if (imageIndex == [topImages count] -1)
                return;
            imageIndex++;
            break;
        }
        case UISwipeGestureRecognizerDirectionRight: {
            if (imageIndex == 0)
                return;
            imageIndex--;
            break;
        }
        default:
            break;
    }
    imageIndex = (imageIndex < 0) ? ([topImages count] -1):
    imageIndex % [topImages count];
    tutorialImageView.image = [topImages objectAtIndex:imageIndex];
    // UIImageView *imageView = [[UIImageView alloc] initWithImage:[topImages objectAtIndex:imageIndex]];
    // [UIView transitionFromView:tutorialImageView toView:tutorialImageView duration:1.0 options:UIViewAnimationOptionCurveEaseInOut completion:NULL];
}


- (IBAction)globalPressed:(id)sender {
    switch (imageIndex) {
        case 0:
        case 1:
        case 3:
            return;
        case 2: {
            if (IS_WIDESCREEN) {
                UIImage *image = [UIImage imageNamed:@"screen_3@568.png"];
                tutorialImageView.image = image;
            } else {
                UIImage *image = [UIImage imageNamed:@"screen_3.png"];
                tutorialImageView.image = image;
            }
            return;
        }
        case 4: {
            if (IS_WIDESCREEN) {
                UIImage *image = [UIImage imageNamed:@"screen_7@568.png"];
                tutorialImageView.image = image;
            } else {
                UIImage *image = [UIImage imageNamed:@"screen_7.png"];
                tutorialImageView.image = image;
            }
            return;
        }
    }
}

- (IBAction)fangroupPressed:(id)sender {
    switch (imageIndex) {
        case 0:
        case 1:
        case 3:
            return;
        case 2: {
            if (IS_WIDESCREEN) {
                UIImage *image = [UIImage imageNamed:@"screen_4@568.png"];
                tutorialImageView.image = image;
            } else {
                UIImage *image = [UIImage imageNamed:@"screen_4.png"];
                tutorialImageView.image = image;
            }
            return;
        }
        case 4: {
            if (IS_WIDESCREEN) {
                UIImage *image = [UIImage imageNamed:@"screen_8@568.png"];
                tutorialImageView.image = image;
            } else {
                UIImage *image = [UIImage imageNamed:@"screen_8.png"];
                tutorialImageView.image = image;
            }
            return;
        }
    }
}

- (IBAction)h2hPressed:(id)sender {
    switch (imageIndex) {
        case 0:
        case 1:
        case 3:
            return;
        case 2: {
            if (IS_WIDESCREEN) {
                UIImage *image = [UIImage imageNamed:@"screen_5@568.png"];
                tutorialImageView.image = image;
            } else {
                UIImage *image = [UIImage imageNamed:@"screen_5.png"];
                tutorialImageView.image = image;
            }
            return;
        }
        case 4: {
            if (IS_WIDESCREEN) {
                UIImage *image = [UIImage imageNamed:@"screen_9@568.png"];
                tutorialImageView.image = image;
            } else {
                UIImage *image = [UIImage imageNamed:@"screen_9.png"];
                tutorialImageView.image = image;
            }
            return;
        }
    }
}

- (IBAction)leftPressed:(id)sender {
    if (imageIndex == 0)
        return;
    imageIndex--;
    
    imageIndex = (imageIndex < 0) ? ([topImages count] -1):
    imageIndex % [topImages count];
    tutorialImageView.image = [topImages objectAtIndex:imageIndex];
}

- (IBAction)rightPressed:(id)sender {
    if (imageIndex == [topImages count] -1)
        return;
    imageIndex++;
    
    imageIndex = (imageIndex < 0) ? ([topImages count] -1):
    imageIndex % [topImages count];
    tutorialImageView.image = [topImages objectAtIndex:imageIndex];
}
@end
