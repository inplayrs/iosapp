//
//  GCHelper.h
//  Inplayrs
//
//  Created by David Beesley on 02/10/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FacebookSDK/FacebookSDK.h>

@interface FPViewController : UIViewController<FBFriendPickerDelegate>

- (IBAction)pickFriendsButtonClick:(id)sender;

@end
