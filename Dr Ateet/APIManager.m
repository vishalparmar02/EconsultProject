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
            if([currentAPI[key] isKindOfClass:[NSNull class]]){
                self[key] = @0;
            }
            [self setCurrent];
        }
    }
}

- (void)updateInBackground{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    NSString *isDebug = @"false";
    NSString *bundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
#ifdef RELEASE
    NSLog(@"I am release");
#endif
#ifdef DEBUG
    if (DEBUG) {
        NSLog(@"I am debug");
        isDebug = @"true";
        bundleID = [bundleID stringByAppendingString:@".debug"];
    }
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
                            NSLog(@"api:%@", api.description);
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
        [self performSelectorInBackground:@selector(checkUpdate) withObject:nil];
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

- (BOOL)videoConsultationEnabled{
    return [self[@"f_video_consult"] boolValue];
}

- (BOOL)appointmentsEnabled{
    return [self[@"f_appointment"] boolValue];
}

- (BOOL)patientReportsEnabled{
    return [self[@"f_patient_report"] boolValue];
}


- (void)checkUpdate{
    
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSDictionary *params = @{@"device_type" : @"iOS",
                             @"version_name" : version};
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFHTTPRequestSerializer *reqSerializer = [AFHTTPRequestSerializer serializer];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:CHECK_UPDATE];
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"POST"
                                                          URLString:URLString
                                                         parameters:params
                                                              error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [error printHTMLError];
        } else {
            if([responseObject[@"is_mandatory"] boolValue]){
                NSString *urlString = @"https://itunes.apple.com/app/dr-ateet-sharma/id1305665664";
                if ([responseObject[@"url"] isKindOfClass:[NSString class]] &&
                    [responseObject[@"url"] length]) {
                    urlString = responseObject[@"url"];
                }
                [self forceUpdate:urlString];
            }
        }
    }];
    [dataTask resume];
}

- (void)forceUpdate:(NSString*)urlString{
    [UIAlertController showAlertInViewController:ApplicationDelegate.window.rootViewController
                                       withTitle:@"Please update your app"
                                         message:@"Current version is no more supported. Please tap 'Update App' button to continue"
                               cancelButtonTitle:nil
                          destructiveButtonTitle:nil
                               otherButtonTitles:@[@"Update App"]
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                                        }];
}

@end
