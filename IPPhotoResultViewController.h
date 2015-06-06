//
//  IPPhotoResultViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 28/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IPPhotoResultViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;

@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) NSString *username;


@end
