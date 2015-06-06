//
//  IPPhotoViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 28/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DraggableViewBackground.h"

@class Game;
@class IPUploadPhotoViewController;
@class IPPhotoLeaderboardViewController;

@interface IPPhotoViewController : UIViewController <DraggableViewBackgroundDelegate>
{
    int imageIndex;
}

//methods called in DraggableViewBackground
-(void)globalCalled;
-(void)uploadCalled;

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (nonatomic, copy) NSMutableArray *photoImages;
@property (strong, nonatomic) Game *game;

@property (weak, nonatomic) IBOutlet UIButton *globalButton;
@property (weak, nonatomic) IBOutlet UIButton *dislikeButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) IPUploadPhotoViewController *uploadPhotoViewController;
@property (strong, nonatomic) IPPhotoLeaderboardViewController *photoLeaderboardViewController;

- (IBAction)globalPressed:(id)sender;
- (IBAction)dislikePressed:(id)sender;
- (IBAction)likePressed:(id)sender;
- (IBAction)uploadPressed:(id)sender;




@end
