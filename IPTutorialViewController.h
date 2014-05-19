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
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

- (IBAction)leftPressed:(id)sender;
- (IBAction)rightPressed:(id)sender;



@end
