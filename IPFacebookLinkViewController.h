//
//  IPFacebookLinkViewController.h
//  Inplayrs
//
//  Created by David Beesley on 02/10/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>


@interface IPFacebookLinkViewController : UIViewController

@property (weak, nonatomic) IBOutlet FBLoginView *loginLinkView;
@property (weak, nonatomic) NSString *fbID;
@property (weak, nonatomic) NSString *fbUsername;
@property (weak, nonatomic) NSString *fbEmail;
@property (strong, nonatomic) NSString *fbName;

@end

