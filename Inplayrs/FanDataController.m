//
//  FanDataController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 24/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "FanDataController.h"


@interface FanDataController ()
- (void)initializeDefaultDataList;
@end

@implementation FanDataController

- (void)initializeDefaultDataList {
    
    NSMutableArray *fangroupList = [[NSMutableArray alloc] init];
    self.fangroupList = fangroupList;
    
    NSMutableArray *myFanList = [[NSMutableArray alloc] init];
    self.myFanList = myFanList;
    
    NSMutableArray *competitionList = [[NSMutableArray alloc] init];
    self.competitionList = competitionList;
}


- (void)setFangroupList:(NSMutableArray *)newList {
    if (_fangroupList != newList) {
        _fangroupList = [newList mutableCopy];
    }
}

- (void)setMyFanList:(NSMutableArray *)newList {
    if (_myFanList != newList) {
        _myFanList = [newList mutableCopy];
    }
}

- (void)setCompetitionList:(NSMutableArray *)newList {
    if (_competitionList != newList) {
        _competitionList = [newList mutableCopy];
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
