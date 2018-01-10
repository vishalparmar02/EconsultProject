//
//  NSDictionary+Status.m
//  user
//
//  Created by Shashank Patel on 12/12/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "NSDictionary+Status.h"

@implementation NSDictionary (Status)

- (BOOL)isSuccess{
    return ([self[@"status"] isKindOfClass:[NSString class]] && [self[@"status"] isEqualToString:@"success"]) || [self[@"status"] integerValue] == 1;
}

@end
