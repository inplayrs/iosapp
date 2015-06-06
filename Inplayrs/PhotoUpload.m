//
//  PhotoUpload.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "PhotoUpload.h"

@implementation PhotoUpload


-(id)initWithPhotoID:(NSInteger)photoID
{
    self = [super init];
    if (self) {
        _photoID = photoID;
        _photoKey = @"";

        return self;
    }
    return nil;
}



@end
