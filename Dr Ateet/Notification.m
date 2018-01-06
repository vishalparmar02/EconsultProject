//
//  Notification.m
//  Dr Ateet
//
//  Created by Shashank Patel on 04/01/18.
//  Copyright © 2018 Shashank Patel. All rights reserved.
//

#import "Notification.h"

@implementation Notification

+ (id)notificationFromDictionary:(NSDictionary*)dict{
    Notification *aNotification = [[Notification alloc] initWithDictionary:dict];
    return aNotification;
}

+ (void)fetchNotificationsInBackgroundWithBlock:(ArrayResultBlock)block{
    NSString *endPoint = [NSString stringWithFormat:GET_NOTIFICATIONS, [CUser currentUser].objectId];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:endPoint];
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"GET"
                                                          URLString:URLString
                                                         parameters:nil
                                                              error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            if(block)block(nil, error);
        } else {
            NSMutableArray *notifications = [NSMutableArray array];
            NSArray *notificationArray = responseObject[@"data"];
            for (NSDictionary *notificationDict in notificationArray) {
                [notifications addObject:[Notification notificationFromDictionary:notificationDict]];
            }
            if(block)block(notifications, nil);
        }
    }];
    [dataTask resume];
}

@end
