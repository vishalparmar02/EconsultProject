//
//  NetworkManager.h
//  Triffic
//
//  Created by Shashank Patel on 31/01/18.
//  Copyright © 2017 Triffic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

+ (void)callBaseURL:(NSString*)baseURL
           endPoint:(NSString*)endPoint
            headers:(NSDictionary*)headers
           withDict:(NSDictionary*)dict
             method:(NSString*)method
               JSON:(BOOL)isJSON
            success:(void (^)(id  _Nonnull responseObject))success
            failure:(void (^)(id  _Nonnull responseObject, NSError * _Nonnull error))failure;

+ (void)callBaseURL:(NSString*)baseURL
           endPoint:(NSString*)endPoint
           withDict:(NSDictionary*)dict
             method:(NSString*)method
               JSON:(BOOL)isJSON
            success:(void (^)(id  _Nonnull responseObject))success
            failure:(void (^)(id  _Nonnull responseObject, NSError * _Nonnull error))failure;

+ (void)callEndPoint:(NSString*)URLString
            withDict:(NSDictionary*)dict
              method:(NSString*)method
                JSON:(BOOL)isJSON
             success:(void (^)(id  responseObject))success
             failure:(void (^)(id  responseObject, NSError * error))failure;

+ (void)getEndPoint:(NSString*)URLString
            success:(void (^)(id  responseObject))success
            failure:(void (^)(id  responseObject, NSError * error))failure;

+ (void)postEndPoint:(NSString*)endPoint
          parameters:(NSDictionary*)parameters
             success:(void (^)(id  responseObject))success
             failure:(void (^)(id  responseObject, NSError * error))failure;

+ (void)patchEndPoint:(NSString*)endPoint
           parameters:(NSDictionary*)parameters
              success:(void (^)(id  responseObject))success
              failure:(void (^)(id  responseObject, NSError * _Nonnull error))failure;

+ (void)deleteEndPoint:(NSString*)endPoint
            parameters:(NSDictionary*)parameters
               success:(void (^)(id  responseObject))success
               failure:(void (^)(id  responseObject, NSError * _Nonnull error))failure;

@end
