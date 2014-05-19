//
//  Motd.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Motd : NSObject

@property (nonatomic, copy) NSString *message;


-(id)initWithMessage:(NSString *)message;


@end
