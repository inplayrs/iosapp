//
//  DraggableViewBackground.m
//  testing swiping
//
//  Created by Richard Kim on 8/23/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//

#import "DraggableViewBackground.h"
#import "Flurry.h"
#import "Error.h"
#import "TSMessage.h"
#import "RestKit.h"
#import "Photo.h"
#import "Game.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define CONFIRM_FLAG 1

@implementation DraggableViewBackground{
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    
    // UIButton* menuButton;
    // UIButton* messageButton;
    UIButton* checkButton;
    UIButton* xButton;
    UIButton* globalButton;
    UIButton* flagButton;
    UIButton* uploadButton;
    UIImageView* startScreen;
    UIButton* addPhotoButton;
    UILabel* addPhotoLabel;
}
//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 10; //%%% max number of cards loaded at any given time, must be greater than 1
static const float CARD_HEIGHT = 250; //%%% height of the draggable card
static const float CARD_WIDTH = 250; //%%% width of the draggable card

// @synthesize exampleCardLabels; //%%% all the labels I'm using as example data at the moment
@synthesize allCards;//%%% all the cards
@synthesize delegateBackground, photoImages, game;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [super layoutSubviews];
        [self setupView];
        // exampleCardLabels = [[NSArray alloc]initWithObjects:@"first",@"second",@"third",@"fourth",@"last", nil]; //%%% placeholder for card-specific information
        photoImages = [[NSMutableArray alloc] init];
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
    }
    return self;
}

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
         [self loadCards];
     } failure:^(RKObjectRequestOperation *operation, NSError *error){
         NSLog(@"failure");
     }];
}

//%%% sets up the extra buttons on the screen
-(void)setupView
{
// #warning customize all of this.  These are just place holders to make it look pretty
    // self.backgroundColor = [UIColor colorWithRed:.92 green:.93 blue:.95 alpha:1];
    self.backgroundColor = [UIColor darkGrayColor];
    /*
    menuButton = [[UIButton alloc]initWithFrame:CGRectMake(17, 34, 22, 15)];
    [menuButton setImage:[UIImage imageNamed:@"menuButton"] forState:UIControlStateNormal];
    messageButton = [[UIButton alloc]initWithFrame:CGRectMake(284, 34, 18, 18)];
    [messageButton setImage:[UIImage imageNamed:@"messageButton"] forState:UIControlStateNormal];
     */
    xButton = [[UIButton alloc]initWithFrame:CGRectMake(60, 230, 60, 60)];
    [xButton setImage:[UIImage imageNamed:@"dislike-button"] forState:UIControlStateNormal];
    [xButton addTarget:self action:@selector(swipeLeft) forControlEvents:UIControlEventTouchUpInside];
    checkButton = [[UIButton alloc]initWithFrame:CGRectMake(200, 230, 60, 60)];
    [checkButton setImage:[UIImage imageNamed:@"like-button"] forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(swipeRight) forControlEvents:UIControlEventTouchUpInside];
    
    uploadButton = [[UIButton alloc]initWithFrame:CGRectMake(240, 280, 60, 80)];
    [uploadButton setImage:[UIImage imageNamed:@"upload-button"] forState:UIControlStateNormal];
    [uploadButton setTitle:@"Upload" forState:UIControlStateNormal];
    uploadButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:12.0];
    [uploadButton addTarget:self action:@selector(uploadPressedPhoto) forControlEvents:UIControlEventTouchUpInside];
    CGFloat spacing = 6.0;
    CGSize imageSize = uploadButton.imageView.image.size;
    uploadButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    CGSize titleSize = [uploadButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: uploadButton.titleLabel.font}];
    uploadButton.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    
    globalButton = [[UIButton alloc]initWithFrame:CGRectMake(20, 280, 60, 80)];
    [globalButton setTitle:@"Global" forState:UIControlStateNormal];
    globalButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:12.0];
    [globalButton setImage:[UIImage imageNamed:@"global-icon"] forState:UIControlStateNormal];
    [globalButton addTarget:self action:@selector(globalPressedPhoto) forControlEvents:UIControlEventTouchUpInside];
    imageSize = globalButton.imageView.image.size;
    globalButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    titleSize = [globalButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: globalButton.titleLabel.font}];
    globalButton.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    
    flagButton = [[UIButton alloc]initWithFrame:CGRectMake(140, 280, 60, 80)];
    [flagButton setTitle:@"Flag" forState:UIControlStateNormal];
    [flagButton setImage:[UIImage imageNamed:@"red-card-icon"] forState:UIControlStateNormal];
    flagButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:12.0];
    [flagButton addTarget:self action:@selector(flagPressedPhoto) forControlEvents:UIControlEventTouchUpInside];
    imageSize = flagButton.imageView.image.size;
    flagButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    titleSize = [flagButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: flagButton.titleLabel.font}];
    flagButton.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    
    [self addSubview:xButton];
    [self addSubview:checkButton];
    [self addSubview:uploadButton];
    [self addSubview:globalButton];
    [self addSubview:flagButton];
    startScreen = [[UIImageView alloc]initWithFrame:CGRectMake((self.frame.size.width - CARD_WIDTH)/2, -40, CARD_WIDTH, CARD_HEIGHT)];
    startScreen.backgroundColor = [UIColor blackColor];
    addPhotoButton = [[UIButton alloc]initWithFrame:CGRectMake(135, 60, 50, 50)];
    [addPhotoButton setImage:[UIImage imageNamed:@"add-photo-button"] forState:UIControlStateNormal];
    [addPhotoButton addTarget:self action:@selector(uploadPressedPhoto) forControlEvents:UIControlEventTouchUpInside];
    addPhotoLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 140, 160, 30)];
    addPhotoLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:16.0];
    addPhotoLabel.textColor = [UIColor whiteColor];
    addPhotoLabel.textAlignment = NSTextAlignmentCenter;
    [addPhotoLabel setText:@"NO MORE PHOTOS"];
    
    [self addSubview:startScreen];
    [self addSubview:addPhotoButton];
    [self addSubview:addPhotoLabel];
    
    [checkButton setHidden:YES];
    [xButton setHidden:YES];
}

-(void)globalPressedPhoto {
    [delegateBackground globalCalled];
}

-(void)uploadPressedPhoto {
    [delegateBackground uploadCalled];
}

-(void)flagPressedPhoto {
    if ([loadedCards count] == 0)
        return;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flag" message:@"Are you sure you want to flag this photo as inappropriate?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    alert.tag = CONFIRM_FLAG;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case CONFIRM_FLAG:
            switch (buttonIndex) {
                case 0: // cancel
                {
                    // NSLog(@"cancelled by the user");
                }
                    break;
                case 1: // confirm
                {
                    DraggableView *c = [loadedCards firstObject];
                    RKObjectManager *objectManager = [RKObjectManager sharedManager];
  
                    NSString *path = [NSString stringWithFormat:@"game/photo/flag?photo_id=%ld", (long)c.photoID];
                    [objectManager postObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flagged" message:@"This photo has now been flagged for review!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    } failure:^(RKObjectRequestOperation *operation, NSError *error){
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Already Flagged" message:@"You or someone else has already flagged this for review." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }];

                }
                    break;
            }
    }
}



// #warning include own card customization here!
//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    // DraggableView *draggableView = [[DraggableView alloc]initWithFrame:CGRectMake((self.frame.size.width - CARD_WIDTH)/2, (self.frame.size.height - CARD_HEIGHT)/2, CARD_WIDTH, CARD_HEIGHT)];
    DraggableView *draggableView = [[DraggableView alloc]initWithFrame:CGRectMake((self.frame.size.width - CARD_WIDTH)/2, -40, CARD_WIDTH, CARD_HEIGHT)];
    // draggableView.information.text = [exampleCardLabels objectAtIndex:index];
    Photo *photo = [photoImages objectAtIndex:index];
    [draggableView.information setImageWithURL:photo.url];
    draggableView.caption.text = photo.caption;
    draggableView.photoID = photo.photoID;
    draggableView.delegate = self;
    return draggableView;
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    if([photoImages count] > 0) {
        NSInteger numLoadedCardsCap =(([photoImages count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[photoImages count]);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
        
        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
        for (int i = 0; i<[photoImages count]; i++) {
            DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
            [allCards addObject:newCard];
            
            if (i<numLoadedCardsCap) {
                //%%% adds a small number of cards to be loaded
                [loadedCards addObject:newCard];
            }
        }
        
        //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
        // are showing at once and clogging a ton of data
        for (int i = 0; i<[loadedCards count]; i++) {
            if (i>0) {
                [self insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
            } else {
                [self addSubview:[loadedCards objectAtIndex:i]];
            }
            cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
        }
        [checkButton setHidden:NO];
        [xButton setHidden:NO];
    }
}


-(void)cardSwipedRight:(UIView *)card
{
    //do whatever you want with the card that was swiped
    DraggableView *c = (DraggableView *)card;
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSLog(@"liked photoID=%ld", (long)c.photoID);
    NSString *path = [NSString stringWithFormat:@"game/photo/like?photo_id=%ld&like=true", (long)c.photoID];
    [objectManager postObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
        
        if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
            [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
            cardsLoadedIndex++;//%%% loaded a card, so have to increment count
            [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
        }
        if ([loadedCards count] == 0) {
            [xButton setHidden:YES];
            [checkButton setHidden:YES];
        }
    } failure:nil];
    
}


//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card
{
    //do whatever you want with the card that was swiped
    DraggableView *c = (DraggableView *)card;
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSLog(@"liked photoID=%ld", (long)c.photoID);
    NSString *path = [NSString stringWithFormat:@"game/photo/like?photo_id=%ld&like=false", (long)c.photoID];
    [objectManager postObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
        
        if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
            [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
            cardsLoadedIndex++;//%%% loaded a card, so have to increment count
            [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
        }
        if ([loadedCards count] == 0) {
            [xButton setHidden:YES];
            [checkButton setHidden:YES];
        }
    } failure:nil];

}

//%%% when you hit the right button, this is called and substitutes the swipe
-(void)swipeRight
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
}

//%%% when you hit the left button, this is called and substitutes the swipe
-(void)swipeLeft
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView leftClickAction];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
