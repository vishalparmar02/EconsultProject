//
//  NetworkManager.m
//  Triffic
//
//  Created by Shashank Patel on 31/01/18.
//  Copyright © 2017 Triffic. All rights reserved.
//

#import "NetworkManager.h"
#import "AFNetworking.h"
#import "APIManager.h"

@implementation NetworkManager

+ (void)callBaseURL:(NSString*)baseURL
           endPoint:(NSString*)endPoint
            headers:(NSDictionary*)headers
            withDict:(NSDictionary*)dict
              method:(NSString*)method
                JSON:(BOOL)isJSON
             success:(void (^)(id  _Nonnull responseObject))success
             failure:(void (^)(id  _Nonnull responseObject, NSError * _Nonnull error))failure{
  NSString *URLString = [baseURL stringByAppendingPathComponent:endPoint];
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
  AFHTTPRequestSerializer *serializer = isJSON ? [AFJSONRequestSerializer serializer] : [AFHTTPRequestSerializer serializer];
  
  NSMutableURLRequest *request = [serializer requestWithMethod:method
                                                     URLString:URLString
                                                    parameters:dict
                                                         error:nil];
    for (NSString *headerField in headers) {
        [request setValue:headers[headerField] forHTTPHeaderField:headerField];
    }
  
  NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      failure(responseObject, error);
      NSLog(@"Error: %@ : %@", URLString, error.description);
    }else{
      success(responseObject);
    }
  }];
  [dataTask resume];
}

+ (void)callBaseURL:(NSString*)baseURL
           endPoint:(NSString*)endPoint
           withDict:(NSDictionary*)dict
             method:(NSString*)method
               JSON:(BOOL)isJSON
            success:(void (^)(id  _Nonnull responseObject))success
            failure:(void (^)(id  _Nonnull responseObject, NSError * _Nonnull error))failure{
    [self callBaseURL:baseURL
             endPoint:endPoint
              headers:nil
             withDict:dict
               method:method
                 JSON:isJSON
              success:success
              failure:failure];
}

+ (void)callEndPoint:(NSString*)endPoint
            withDict:(NSDictionary*)dict
              method:(NSString*)method
                JSON:(BOOL)isJSON
             success:(void (^)(id  _Nonnull responseObject))success
             failure:(void (^)(id  _Nonnull responseObject, NSError * _Nonnull error))failure{
    [self callBaseURL:[[APIManager sharedManager] baseURL]
           endPoint:endPoint
           withDict:dict
             method:method
               JSON:isJSON
            success:success
            failure:failure];
}

+ (void)getEndPoint:(NSString*)endPoint
            headers:(NSDictionary*)headers
            success:(void (^)(id  responseObject))success
            failure:(void (^)(id  responseObject, NSError * _Nonnull error))failure{
    [self callEndPoint:endPoint withDict:nil method:@"GET" JSON:YES success:success failure:failure];
}

+ (void)getEndPoint:(NSString*)endPoint
            success:(void (^)(id  responseObject))success
            failure:(void (^)(id  responseObject, NSError * _Nonnull error))failure{
    [self callEndPoint:endPoint withDict:nil method:@"GET" JSON:YES success:success failure:failure];
}

+ (void)postEndPoint:(NSString*)endPoint
          parameters:(NSDictionary*)parameters
            success:(void (^)(id  responseObject))success
            failure:(void (^)(id  responseObject, NSError * _Nonnull error))failure{
    [self callEndPoint:endPoint withDict:parameters method:@"POST" JSON:YES success:success failure:failure];
}

+ (void)patchEndPoint:(NSString*)endPoint
           parameters:(NSDictionary*)parameters
              success:(void (^)(id  responseObject))success
              failure:(void (^)(id  responseObject, NSError * _Nonnull error))failure{
    [self callEndPoint:endPoint withDict:parameters method:@"PATCH" JSON:YES success:success failure:failure];
}

+ (void)deleteEndPoint:(NSString*)endPoint
            parameters:(NSDictionary*)parameters
               success:(void (^)(id  responseObject))success
               failure:(void (^)(id  responseObject, NSError * _Nonnull error))failure{
    [self callEndPoint:endPoint withDict:parameters method:@"DELETE" JSON:YES success:success failure:failure];
}

@end
