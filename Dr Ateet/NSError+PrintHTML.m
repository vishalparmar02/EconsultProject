//
//  NSError+PrintHTML.m
//  user
//
//  Created by Shashank Patel on 10/01/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "NSError+PrintHTML.h"

@implementation NSError (PrintHTML)

- (void)printHTMLError{
    NSData *data = self.userInfo[@"com.alamofire.serialization.response.error.data"];
    NSString *errorString = [[NSString alloc] initWithData:data
                                                  encoding:NSUTF8StringEncoding];
    NSLog(@"Error: %@", errorString);
}

@end
