//
//  IPTutorialViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 28/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPTutorialViewController : UIViewController
{
    int imageIndex;
}

@property (weak, nonatomic) IBOutlet UIImageView *tutorialImageView;
@property (nonatomic, copy) NSMutableArray *topImages;
@property (weak, nonatomic) IBOutlet UIButton *globalButton;
@property (weak, nonatomic) IBOutlet UIButton *fangroupButton;
@property (weak, nonatomic) IBOutlet UIButton *h2hButton;
- (IBAction)globalPressed:(id)sender;
- (IBAction)fangroupPressed:(id)sender;
- (IBAction)h2hPressed:(id)sender;


@end
