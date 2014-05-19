//
//  Motd.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "Motd.h"

@implementation Motd


-(id)initWithMessage:(NSString *)message
{
    self = [super init];
    if (self) {
        _message = message;
        return self;
    }
    return nil;
}


@end
