//
//  NSDictionary+JSON.m
//  pro
//
//  Created by Shashank Patel on 16/09/16.
//  Copyright © 2016 iOS. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)

- (NSString*)JSONString{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:0
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end
