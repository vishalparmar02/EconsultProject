//
//  NSString+JSON.m
//  pro
//
//  Created by Shashank Patel on 16/09/16.
//  Copyright © 2016 iOS. All rights reserved.
//

#import "NSString+JSON.h"

@implementation NSString (JSON)

- (id)JSONObject{
    NSError *jsonError;
    NSData *objectData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingAllowFragments
                                                           error:&jsonError];
}

@end
