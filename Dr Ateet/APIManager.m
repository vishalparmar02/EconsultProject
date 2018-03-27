//
//  APIManager.m
//  Dr Ateet
//
//  Created by Shashank Patel on 27/03/18.
//  Copyright © 2018 Shashank Patel. All rights reserved.
//

#import "APIManager.h"
#import "NetworkManager.h"

#define AdminBaseURL                @"https://admin.jshealthtech.com"
#define AdminEndPoint               @"api/config"
#define API_MANAGER_KEY             @"api_manager_key"

@implementation APIManager

+ (void)load{
    [self sharedManager];
}

+ (instancetype)sharedManager{
    static dispatch_once_t onceToken;
    static APIManager *mAPIManager;
    dispatch_once(&onceToken, ^{
        mAPIManager = [[APIManager alloc] init];
    });
    return mAPIManager;
}

- (instancetype)init{
    if (self = [super init]) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [self initLocally];
        [self updateInBackground];
    }
    return self;
}

- (void)initLocally{
    NSDictionary *currentAPI = [defaults_object(API_MANAGER_KEY) JSONObject];
    if(currentAPI){
        for (NSString *key in currentAPI.allKeys) {
            self[key] = currentAPI[key];
            [self setCurrent];
        }
    }
}

- (void)updateInBackground{
    NSString *isDebug = @"false";
    NSString *bundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
#ifdef DEBUG
    isDebug = @"true";
    bundleID = [bundleID stringByAppendingString:@".debug"];
#endif
    NSDictionary *headers = @{@"debug" : isDebug,
                              @"platform" : @"iPhone",
                              @"application-id" : bundleID
                              };
    [NetworkManager callBaseURL:AdminBaseURL
                       endPoint:AdminEndPoint
                        headers:headers
                       withDict:nil
                         method:@"GET"
                           JSON:YES
                        success:^(id  _Nonnull responseObject) {
                            self.ready = YES;
                            NSDictionary *api = responseObject[@"data"];
                            for (NSString *key in api.allKeys) {
                                self[key] = api[key];
                                [self setCurrent];
                            }
                            [self checkValidity];
                        } failure:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
                            [self checkValidity];
                        }];
}

- (void)checkValidity{
    if ([self baseURL].length &&
        [self pubnubPublishKey].length &&
        [self pubnubSubscribeKey].length &&
        [self paymentURL].length) {
        self.ready = YES;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }else{
        self.ready = NO;
    }
}

- (void)setCurrent{
    for (NSString *key in updateObject.allKeys) {
        internalObject[key] = updateObject[key];
    }
    updateObject = [[NSMutableDictionary alloc] init];
    defaults_set_object(API_MANAGER_KEY, [internalObject JSONString]);
}

- (NSString*)baseURL{
    return [self[@"base_url"] stringByAppendingPathComponent:@"/api/v2"];
}

- (NSString*)pubnubPublishKey{
    return self[@"pubnub_publish_key"];
}

- (NSString*)pubnubSubscribeKey{
    return self[@"pubnub_subscribe_key"];
}

- (NSString*)paymentURL{
    return [NSString stringWithFormat:@"%@%%@", self[@"payment_url"]];
}


@end
