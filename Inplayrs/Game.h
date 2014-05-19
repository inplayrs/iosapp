//
//  Game.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Game : NSObject

@property (nonatomic) NSInteger gameID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *startDate;
@property (nonatomic) NSInteger state;
@property (nonatomic) NSInteger category;
@property (nonatomic) NSInteger type;
@property (nonatomic) BOOL entered;
@property (nonatomic) NSInteger bannerPosition;
@property (nonatomic, copy) NSURL *bannerImageURL;
@property (nonatomic) NSInteger competitionID;
@property (nonatomic, copy) NSString *competitionName;
@property (nonatomic) NSInteger inplayType;

-(id)initWithGameID:(NSInteger)gameID name:(NSString *)name startDate:(NSString *)startDate state:(NSInteger)state category:(NSInteger)category type:(NSInteger)type entered:(BOOL)entered inplayType:(NSInteger)inplayType competitionID:(NSInteger)competitionID;

- (NSComparisonResult) compareWithGame:(Game*) anotherGame;

- (NSComparisonResult) compareWithName:(Game*) anotherGame;

- (NSComparisonResult) compareWithGameReverse:(Game*) anotherGame;

@end
