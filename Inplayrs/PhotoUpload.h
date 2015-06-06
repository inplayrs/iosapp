//
//  PhotoUpload.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoUpload : NSObject

@property (nonatomic) NSInteger photoID;
@property (nonatomic, copy) NSString *photoKey;


-(id)initWithPhotoID:(NSInteger)photoID;

@end
