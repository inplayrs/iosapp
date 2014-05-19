//
//  FriendProtocols.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 15/01/2014.
//  Copyright (c) 2014 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@protocol FBGraphUserExtraFields <FBGraphUser>

@property (nonatomic, retain) NSArray *devices;

@end
