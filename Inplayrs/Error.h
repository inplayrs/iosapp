//
//  Error.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Error : NSObject

@property (nonatomic) NSInteger code;
@property (nonatomic, copy) NSString *message;


-(id)initWithCode:(NSInteger)code message:(NSString *)message;


@end
