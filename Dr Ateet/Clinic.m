//
//  Clinic.m
//  Dr Ateet
//
//  Created by Shashank Patel on 08/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "Clinic.h"

@implementation Clinic

+ (id)clinicFromDictionary:(NSDictionary*)dict{
    Clinic *clinic = [[Clinic alloc] initWithDictionary:dict];
    return clinic;
}

- (instancetype)initWithDictionary:(NSDictionary*)dict{
//    NSLog(dict.description);
    if (self = [super initWithDictionary:dict]) {
    }
    return self;
}

+ (void)fetchClinicsInBackgroundWithBlock:(nullable ArrayResultBlock)block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSLog(API_URL);
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:GET_CLINICS];
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"GET"
                                                          URLString:URLString
                                                         parameters:nil
                                                              error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            if(block)block(nil, error);
        } else {
            NSMutableArray *clinics = [NSMutableArray array];
            Clinic *onlineClinic = [Clinic clinicFromDictionary:@{@"clinic_name" : @"Online",
                                                                  @"id" : @-1}];
            [clinics addObject:onlineClinic];
            for (NSDictionary *clinicDict in responseObject[@"clinics"]) {
                [clinics addObject:[Clinic clinicFromDictionary:clinicDict]];
            }
            if(block)block(clinics, nil);
        }
    }];
    [dataTask resume];
}

- (void)saveInBackgroundWithBlock:(nullable BooleanResultBlock)block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:ADD_CLINICS];
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"POST"
                                                          URLString:URLString
                                                         parameters:self[@"save"]
                                                              error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [error printHTMLError];
            if(block)block(nil, error);
        } else {
            if(block)block(YES, nil);
        }
    }];
    [dataTask resume];
}

- (void)updateInBackgroundWithBlock:(nullable BooleanResultBlock)block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSString *endPoint = [NSString stringWithFormat:UPDATE_CLINICS, self.objectId];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
    
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:endPoint];
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"PUT"
                                                          URLString:URLString
                                                         parameters:self[@"update"]
                                                              error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [error printHTMLError];
            if(block)block(nil, error);
        } else {
            if(block)block(YES, nil);
        }
    }];
    [dataTask resume];
}

- (void)deleteInBackgroundWithBlock:(nullable BooleanResultBlock)block{
    NSString *endPoint = [NSString stringWithFormat:DELETE_CLINIC, self.objectId, @"0"];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:endPoint];
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"DELETE"
                                                          URLString:URLString
                                                         parameters:self[@"update"]
                                                              error:nil];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [error printHTMLError];
            if(block)block(nil, error);
        } else {
            if ([responseObject[@"total"] integerValue]) {
                NSError *error = [NSError errorWithDomain:@"Conflict"
                                                     code:501
                                                 userInfo:responseObject];
                if(block)block(NO, error);
            }else{
                if(block)block(YES, nil);
            }
        }
    }];
    [dataTask resume];
}

- (void)forceDeleteInBackgroundWithBlock:(nullable BooleanResultBlock)block{
    NSString *endPoint = [NSString stringWithFormat:DELETE_CLINIC, self.objectId, @"1"];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:endPoint];
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"DELETE"
                                                          URLString:URLString
                                                         parameters:self[@"update"]
                                                              error:nil];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [error printHTMLError];
            if(block)block(nil, error);
        } else {
            if ([responseObject[@"total"] integerValue]) {
                NSError *error = [NSError errorWithDomain:@"Conflict"
                                                     code:501
                                                 userInfo:responseObject];
                if(block)block(NO, error);
            }else{
                if(block)block(YES, nil);
            }
        }
    }];
    [dataTask resume];
}

@end
