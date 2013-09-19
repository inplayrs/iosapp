//
//  Error.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "Error.h"

@implementation Error


-(id)initWithCode:(NSInteger)code message:(NSString *)message
{
    self = [super init];
    if (self) {
        _code = code;
        _message = message;
        return self;
    }
    return nil;
}


@end
