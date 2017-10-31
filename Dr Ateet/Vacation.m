//
//  Vacation.m
//  Dr Ateet
//
//  Created by Shashank Patel on 31/10/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "Vacation.h"

@implementation Vacation

+ (void)fetchVacationsInBackgroundWithBlock:(nullable ArrayResultBlock)block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"Authorization"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:GET_VACATIONS];
    
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"GET"
                                                          URLString:URLString
                                                         parameters:nil
                                                              error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [error printHTMLError];
            if(block)block(nil, error);
        } else {
            NSMutableArray *vacations = [NSMutableArray array];
            NSArray *vacationArray = responseObject[@"data"];
            for (NSDictionary *aVacDict in vacationArray) {
                [vacations addObject:[[Vacation alloc] initWithDictionary:aVacDict]];
            }
            if(block)block(vacations, nil);
        }
    }];
    [dataTask resume];
}

@end
