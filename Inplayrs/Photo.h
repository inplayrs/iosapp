//
//  Photo.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject

@property (nonatomic) NSInteger photoID;
@property (nonatomic) NSInteger userID;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic) NSInteger likes;


-(id)initWithPhotoID:(NSInteger)photoID;

@end
