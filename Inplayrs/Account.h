//
//  Account.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Account : NSObject

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *username;


-(id)initWithEmail:(NSString *)email username:(NSString *)username;


@end
