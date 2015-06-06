//
//  Photo.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "Photo.h"

@implementation Photo


-(id)initWithPhotoID:(NSInteger)photoID
{
    self = [super init];
    if (self) {
        _photoID = photoID;
        _userID = 0;
        _caption = @"";
        _likes = 0;

        return self;
    }
    return nil;
}



@end
