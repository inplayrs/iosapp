//
//  Banner.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Game;

@interface Banner : NSObject

@property (nonatomic) NSInteger bannerPosition;
@property (nonatomic, copy) NSURL *bannerImageURL;
@property (nonatomic, copy) Game *game;


-(id)initWithPosition:(NSInteger)bannerPosition bannerImageURL:(NSURL *)bannerImageURL game:(Game *)game;


@end
