//
//  AddUsers.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "AddUsers.h"

@implementation AddUsers

- (void)initializeDefaultDataList {
    
    NSMutableArray *facebookIDs = [[NSMutableArray alloc] init];
    self.facebookIDs = facebookIDs;
    
    NSMutableArray *usernames = [[NSMutableArray alloc] init];
    self.usernames = usernames;
    
}


- (void)setFacebookIDs:(NSMutableArray *)newList {
    if (_facebookIDs != newList) {
        _facebookIDs = [newList mutableCopy];
    }
}


- (void)setUsernames:(NSMutableArray *)newList {
    if (_usernames != newList) {
        _usernames = [newList mutableCopy];
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
