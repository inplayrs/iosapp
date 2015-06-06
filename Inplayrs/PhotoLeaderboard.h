//
//  PhotoLeaderboard.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoLeaderboard : NSObject

@property (nonatomic) NSInteger rank;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *fbID;
@property (nonatomic) NSInteger photoID;
@property (nonatomic) NSInteger likes;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic) NSInteger winnings;


-(id)initWithRank:(NSInteger)rank name:(NSString *)name fbID:(NSString *)fbID photoID:(NSInteger)photoID likes:(NSInteger)likes url:(NSURL *)url caption:(NSString *)caption winnings:(NSInteger)winnings;


@end
