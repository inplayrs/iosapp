//
//  PhotoLeaderboardDataController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "PhotoLeaderboardDataController.h"


@interface PhotoLeaderboardDataController ()
- (void)initializeDefaultDataList;
@end

@implementation PhotoLeaderboardDataController


- (void)initializeDefaultDataList {
    NSMutableArray *photoGameLeaderboard = [[NSMutableArray alloc] init];
    self.photoGameLeaderboard = photoGameLeaderboard;
   
}


- (void)setPhotoGameLeaderboard:(NSMutableArray *)newList {
    if (_photoGameLeaderboard != newList) {
        _photoGameLeaderboard = [newList mutableCopy];
    }
}

- (id)init {
    if (self = [super init]) {
        [self initializeDefaultDataList];
        return self;
    }
    return nil;
}


@end
