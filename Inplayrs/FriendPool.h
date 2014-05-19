//
//  FriendPool.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendPool : NSObject


@property (nonatomic) NSInteger poolID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *numPlayers;


-(id)initWithPoolID:(NSInteger)poolID name:(NSString *)name numPlayers:(NSString *)numPlayers;

- (NSComparisonResult) compareWithName:(FriendPool*) anotherFriendPool;

@end
