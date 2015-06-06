//
//  IPPhotoViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 28/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPPhotoViewController.h"
#import "IPUploadPhotoViewController.h"
#import "Flurry.h"
#import "Error.h"
#import "TSMessage.h"
#import "RestKit.h"
#import "IPPhotoLeaderboardViewController.h"
#import "IPMultiLoginViewController.h"
#import "IPTutorialViewController.h"
#import "Game.h"
#import "Photo.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DraggableViewBackground.h"
#import "IPAppDelegate.h"

#define IS_WIDESCREEN ( [ [ UIScreen mainScreen ] bounds ].size.height == 568 )

@interface IPPhotoViewController ()

@end

@implementation IPPhotoViewController

@synthesize photoImages, photoImageView, likeButton, dislikeButton, globalButton, uploadButton, uploadPhotoViewController, photoLeaderboardViewController;

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
    Game *theGame = self.game;
    self.title = theGame.name;
    uploadPhotoViewController = nil;
    photoLeaderboardViewController = nil;
    
    
    UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeImage:)];
    [swipeLeftGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [photoImageView addGestureRecognizer:swipeLeftGestureRecognizer];
    UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeImage:)];
    [swipeRightGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [photoImageView addGestureRecognizer:swipeRightGestureRecognizer];
    
    photoImages = [[NSMutableArray alloc] init];
    imageIndex = 0;
    
    /*
    if (IS_WIDESCREEN) {
        UIImage *image1 = [UIImage imageNamed:@"goal.png"];
        [photoImages addObject:image1];
        // photoImageView.frame = CGRectMake(0, 0, 280, 280);
        photoImageView.image = image1;
    } else {
        UIImage *image1 = [UIImage imageNamed:@"goal.png"];
        [photoImages addObject:image1];
        photoImageView.image = image1;
    }
     */
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    /*
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.navigationController.navigationBar.translucent = YES;
    }
     */
    NSString *stateString = [NSString stringWithFormat:@"%d", (int)self.game.state];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.game.name,
                                @"gameName", stateString, @"state", nil];
    [Flurry logEvent:@"GAME" withParameters:dictionary];
    IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.loggedin == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign In required" message:@"Please register or login first!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    } else {
        DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc]initWithFrame:self.view.frame];
        draggableBackground.game = self.game;
        draggableBackground.delegateBackground = self;
        [self.view addSubview:draggableBackground];
        [draggableBackground getPhotos];
    }
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
    if ([photoImages count] < 2)
        return;
    UISwipeGestureRecognizerDirection direction = [(UISwipeGestureRecognizer *)recognizer direction];
    switch (direction) {
        case UISwipeGestureRecognizerDirectionLeft: {
            if (imageIndex == [photoImages count] -1)
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
    imageIndex = (int) ((imageIndex < 0) ? ([photoImages count] -1):
    imageIndex % [photoImages count]);
    // photoImageView.image = [photoImages objectAtIndex:imageIndex];
    Photo *photo = [photoImages objectAtIndex:imageIndex];
    if (photo) {
        [photoImageView setImageWithURL:photo.url];
    }
}


/*
-(void)getPhotos
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"game/photos?game_id=%ld", (long)self.game.gameID];
    [objectManager getObjectsAtPath:path parameters:nil success:
        ^(RKObjectRequestOperation *operation, RKMappingResult *result) {
            NSArray* temp = [result array];
            for (int i=0; i<temp.count; i++) {
                Photo *photo = [temp objectAtIndex:i];
                if (!photo.caption)
                    photo.caption = @"";
                [photoImages addObject:photo];
            }
            if ([photoImages count] > 0) {
                Photo *photo = [photoImages objectAtIndex:0];
                [photoImageView setImageWithURL:photo.url];
            }
             
        } failure:^(RKObjectRequestOperation *operation, NSError *error){
            NSLog(@"failure");
        }];
}
 */


- (IBAction)globalPressed:(id)sender {

}


- (IBAction)dislikePressed:(id)sender {
    if ([photoImages count] == 0)
        return;
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    Photo* photo = [photoImages objectAtIndex:imageIndex];
    NSString *path = [NSString stringWithFormat:@"game/photo/like?photo_id=%ld&like=false", (long)photo.photoID];
    [objectManager postObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        // update setActive
        // delete temp image file
        // get another 20 if no more, show empty if not
    } failure:nil];
}

- (IBAction)likePressed:(id)sender {
    if ([photoImages count] == 0)
        return;
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    Photo* photo = [photoImages objectAtIndex:imageIndex];
    NSString *path = [NSString stringWithFormat:@"game/photo/like?photo_id=%ld&like=true", (long)photo.photoID];
    [objectManager postObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        // update setActive
        // delete temp image file
        // get another 20 if no more, show empty if not
    } failure:nil];
}


- (IBAction)uploadPressed:(id)sender {
    if (!self.uploadPhotoViewController) {
        self.uploadPhotoViewController = [[IPUploadPhotoViewController alloc] initWithNibName:@"IPUploadPhotoViewController" bundle:nil];
        uploadPhotoViewController.game = self.game;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        else
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    }
    if (self.uploadPhotoViewController) {
        [self.navigationController pushViewController:self.uploadPhotoViewController animated:YES];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Upload",
                                    @"type", @"Attempt", @"result", nil];
        [Flurry logEvent:@"PHOTO" withParameters:dictionary];
    }
}


- (void)uploadCalled {
    if (!self.uploadPhotoViewController) {
        self.uploadPhotoViewController = [[IPUploadPhotoViewController alloc] initWithNibName:@"IPUploadPhotoViewController" bundle:nil];
        uploadPhotoViewController.game = self.game;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        else
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    }
    if (self.uploadPhotoViewController) {
        [self.navigationController pushViewController:self.uploadPhotoViewController animated:YES];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Upload",
                                    @"type", @"Attempt", @"result", nil];
        [Flurry logEvent:@"PHOTO" withParameters:dictionary];
    }
}

- (void)globalCalled {
    if (!self.photoLeaderboardViewController) {
        self.photoLeaderboardViewController = [[IPPhotoLeaderboardViewController alloc] initWithNibName:@"IPPhotoLeaderboardViewController" bundle:nil];
        photoLeaderboardViewController.game = self.game;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
        else
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    }
    if (self.photoLeaderboardViewController) {
        [self.navigationController pushViewController:self.photoLeaderboardViewController animated:YES];
    }
}

@end
