//
//  Account.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "Account.h"

@implementation Account


-(id)initWithEmail:(NSString *)email
{
    self = [super init];
    if (self) {
        _email = email;
        return self;
    }
    return nil;
}


@end
