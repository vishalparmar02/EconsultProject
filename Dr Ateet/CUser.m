//
//  CUser.m
//  Chilap
//
//  Created by Shashank Patel on 14/04/16.
//  Copyright © 2017 Chilap. All rights reserved.
//

#import "CUser.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import <Base64/MF_Base64Additions.h>
#import "MenuController.h"
#import "PubNubManager.h"
#import "Patient.h"


@interface CUser ()

@end

@implementation CUser

- (NSString*)objectId{
    return [internalObject[@"users_id"] stringValue];
}

- (NSString*)mobile{
    return self[@"mobile"];
}

- (NSString*)fullName{
    return [NSString stringWithFormat:@"%@ %@", self[@"first_name"], self[@"last_name"]];
}

- (NSString*)authHeader{
//    NSString *authEncoded = [[NSString stringWithFormat:@"%@:%@", self[@"mobile"], self[@"authrization"]] base64String];
    
//    NSString *authEncoded = [@"9586856996:15a7e757-93e7-4845-ae1a-fe41655a8428" base64String];
    return self[@"api_token"];
}

- (void)setObject:(id)object forKey:(NSString *)key{
    updateObject[key] = object;
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key{
    updateObject[key] = object;
}


static CUser *currentUser;


+ (CUser*)currentUser
{
    
    if (currentUser)
    {
        return currentUser;
    }
    
    NSDictionary *currentUserDict = [defaults_object(CURRENT_USER_KEY) JSONObject];
    if(currentUserDict){
        currentUser = [[CUser alloc] initWithDictionary:currentUserDict];
        [currentUser setCurrent];
        [currentUser fetchProfileInBackground];
        return currentUser;
    }
    
    return nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict{
    if (self = [super initWithDictionary:dict]) {
        
    }
    return self;
}

+ (void)logOut{
    
    defaults_remove(CURRENT_USER_KEY);
    defaults_save();
    currentUser = nil;
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    
    [PubNubManager updateChannels];
}


+ (void)registerMobile:(nonnull NSString *)phone
               country:(NSString*)country
 inBackgroundWithBlock:(nullable BooleanResultBlock)block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSDictionary *params = @{@"mobile_number" : phone,
                             @"country_code" : country};
    NSLog(API_BASE_URL);
    NSString *URLString             = [API_BASE_URL stringByAppendingPathComponent:REGISTER_PHONE_END_POINT];
    NSMutableURLRequest *request    = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                    URLString:URLString
                                                                                   parameters:params
                                                                                        error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [error printHTMLError];
            block(NO, error);
        } else {
            block(YES, nil);
        }
    }];
    [dataTask resume];
}



+ (void)verifyMobile:(nonnull NSString *)phone country:(NSString*)country
                 OTP:(NSString*)OTP inBackgroundWithBlock:(nullable UserResultBlock)block{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSDictionary *params = @{@"mobile_number" : phone,
                             @"otp" : OTP};
    
    
    NSString *URLString             = [API_BASE_URL stringByAppendingPathComponent:VERIFY_PHONE_END_POINT];
    NSMutableURLRequest *request    = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                    URLString:URLString
                                                                                   parameters:params
                                                                                        error:nil];

    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            block(nil, error);
        } else {
            if ([responseObject isSuccess]) {
                CUser *user = [[CUser alloc] initWithDictionary:responseObject[@"data"]];
                [user setCurrent];
                block(user, error);
            }else{
                block(nil, [NSError errorWithDomain:NSURLErrorDomain
                                               code:401 userInfo:responseObject]);
            }
            
        }
    }];
    [dataTask resume];
}

+ (void)fetchDoctorProfileInBackgroundWithBlock:(DictionaryResultBlock)block{
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    
    
    NSString *URLString             = [API_BASE_URL stringByAppendingPathComponent:DOCTOR_PROFILE_END_POINT];
    NSMutableURLRequest *request    = [reqSerializer requestWithMethod:@"GET"
                                                             URLString:URLString
                                                            parameters:nil
                                                                 error:nil];
    
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            block(nil, error);
        }else {
            block(responseObject[@"data"], error);
        }
    }];
    [dataTask resume];
}

- (void)fetchProfileInBackground{
    return;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    
    [reqSerializer setValue:self.authHeader forHTTPHeaderField:@"Authorization"];
    
    NSString *URLString             = [API_BASE_URL stringByAppendingPathComponent:DOCTOR_PROFILE_END_POINT];
    NSMutableURLRequest *request    = [reqSerializer requestWithMethod:@"GET"
                                                             URLString:URLString
                                                            parameters:nil
                                                                 error:nil];
    
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            
        }else {
            self[@"profile"] = responseObject;
            [self setCurrent];
            [self updateTokenInBackground];
        }
    }];
    [dataTask resume];
}


- (void)updateTokenInBackground{
    if ([defaults_object(@"one_signal_user_id") isKindOfClass:[NSString class]] &&
        [defaults_object(@"one_signal_user_id") length]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
        
        [reqSerializer setValue:self.authHeader forHTTPHeaderField:@"Authorization"];
        NSString *endPoint              = [NSString stringWithFormat:UPDATE_TOKEN_END_POINT, defaults_object(@"one_signal_user_id")];
        NSString *URLString             = [API_BASE_URL stringByAppendingPathComponent:endPoint];
        URLString                       = [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSMutableURLRequest *request    = [reqSerializer requestWithMethod:@"PUT"
                                                                 URLString:URLString
                                                                parameters:nil
                                                                     error:nil];
        
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                
            }else {
                
            }
        }];
        [dataTask resume];
    }
}


- (void)setCurrent{
    for (NSString *key in updateObject.allKeys) {
        internalObject[key] = updateObject[key];
    }
    updateObject = [[NSMutableDictionary alloc] init];
    defaults_set_object(CURRENT_USER_KEY, [internalObject JSONString]);
}


- (void)saveInBackgroundWithBlock:(nullable BooleanResultBlock)block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    
    [reqSerializer setValue:self.authHeader forHTTPHeaderField:@"Authorization"];
    
    NSString *URLString             = [API_BASE_URL stringByAppendingPathComponent:DOCTOR_PROFILE_END_POINT];
    NSMutableURLRequest *request    = [reqSerializer requestWithMethod:@"PUT"
                                                             URLString:URLString
                                                            parameters:self[@"profile"]
                                                                 error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (block) block(NO, error);
        }else {
            [self setCurrent];
            if (block) block(YES, nil);
        }
    }];
    [dataTask resume];
}

- (void)saveInBackground{
    [self saveInBackgroundWithBlock:nil];
}

- (NSString*)description{
    return [NSString stringWithFormat:@"Internal:%@ \n Update: %@", [internalObject description], [updateObject description]];
}

- (NSURL*)profileImageURL{
    return [NSURL URLWithString:self[@"profile_pic"]];
}

- (NSString*)firstName{
    id firstName = self[@"profile"][@"firstName"];
    return [firstName isKindOfClass:[NSString class]] ? firstName : @"";
}

- (NSString*)lastName{
    id lastName = self[@"profile"][@"lastName"];
    return [lastName isKindOfClass:[NSString class]] ? lastName : @"";
}

- (void)saveFirstName:(NSString*)fName lastName:(NSString*)lName InBackgroundWithBlock:(BooleanResultBlock)block{
    NSMutableDictionary *updateProfile = [NSMutableDictionary dictionary];
    updateProfile[@"firstName"] = fName;
    updateProfile[@"lastName"]  = lName;
    
    [CUser currentUser][@"profile"] = updateProfile;
    
    [[CUser currentUser] saveInBackgroundWithBlock:block];
}

- (BOOL)isPatient{
    return [self[@"role_id"] integerValue] == 3;
}

- (BOOL)isStaff{
    return [self[@"role_id"] integerValue] == 2;
}

- (BOOL)isDoctor{
    return [self[@"role_id"] integerValue] == 1;
}

- (void)updateInBackgroundWithBlock:(nullable BooleanResultBlock)block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSString *endPoint = [self isPatient] ? EDIT_PATIENT_PROFILE : EDIT_DOCTOR_PROFILE;
    
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
    
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:endPoint];
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"POST"
                                                          URLString:URLString
                                                         parameters:self[@"update"]
                                                              error:nil];
    
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        [updateObject removeObjectForKey:@"update"];
        if (error) {
            [error printHTMLError];
            if(block)block(nil, error);
        } else {
            if(block)block(YES, nil);
        }
    }];
    [dataTask resume];
}


- (void)updateProfileImageInBackgroundWithBlock:(nullable BooleanResultBlock)block{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
    NSLog(@"%@",[CUser currentUser].authHeader);
    
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:UPDATE_PROFILE_PIC];
    NSDictionary *params = @{@"users_id" : [CUser currentUser].objectId};
    NSMutableURLRequest *request = [reqSerializer multipartFormRequestWithMethod:@"POST"
                                                                       URLString:URLString
                                                                      parameters:params
                                                       constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                                                           NSData *imageData = UIImageJPEGRepresentation(self.image, 0.5);
                                                           [formData appendPartWithFileData:imageData
                                                                                       name:@"profile_pic"
                                                                                   fileName:@"image.jpg"
                                                                                   mimeType:@"image/jpeg"];
                                                       } error:nil];
    
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [error printHTMLError];
            if(block)block(nil, error);
        } else {
            self[@"profile_pic"] = responseObject[@"profile_pic"];
            [self setCurrent];
            [[MenuController controller] reload];
            if(block)block(YES, nil);
        }
    }];
    [dataTask resume];
}


- (void)fetchMyPatientsInBackgroundWithBlock:(nullable ArrayResultBlock)block{
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSString *endPoint = [NSString stringWithFormat:GET_MY_PATIENTS, self.objectId];
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:endPoint];
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"GET"
                                                          URLString:URLString
                                                         parameters:nil
                                                              error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error)
                                      {
        if (error) {
            NSLog(@"Error: %@", error);
            if(block)block(nil, error);
        } else {
            NSMutableArray *patients = [NSMutableArray array];
            NSArray *patientsArray = responseObject[@"data"];
            [patients addObject:[[CUser currentUser] patient]];
            for (NSDictionary *patientDict in patientsArray) {
                [patients addObject:[Patient patientFromDictionary:patientDict]];
            }
            
            if(block)block(patients, nil);
        }
    }];
    [dataTask resume];
}


- (void)fetchMyStaffInBackgroundWithBlock:(nullable ArrayResultBlock)block
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:GET_STAFF];
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"GET"
                                                          URLString:URLString
                                                         parameters:nil
                                                              error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            if(block)block(nil, error);
        } else {
            NSMutableArray *staff = [NSMutableArray array];
            NSArray *staffArray = responseObject[@"data"];
            for (NSDictionary *staffDict in staffArray) {
                [staff addObject:[[CUser alloc] initWithDictionary:staffDict]];
            }
            if(block)block(staff, nil);
        }
    }];
    [dataTask resume];
}

- (void)deleteStaffInBackgroundWithBlock:(nullable BooleanResultBlock)block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSString *endPoint = [NSString stringWithFormat:DELETE_STAFF, self.objectId];
    NSString *URLString             = [API_BASE_URL stringByAppendingPathComponent:endPoint];
    NSMutableURLRequest *request    = [[AFJSONRequestSerializer serializer] requestWithMethod:@"DELETE"
                                                                                    URLString:URLString
                                                                                   parameters:nil
                                                                                        error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            block(NO, error);
        } else {
            block(YES, nil);
        }
    }];
    [dataTask resume];
}



- (void)addStaff:(NSDictionary*) staff withBlock:(nullable BooleanResultBlock)block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSString *URLString             = [API_BASE_URL stringByAppendingPathComponent:ADD_STAFF];
    NSMutableURLRequest *request    = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                    URLString:URLString
                                                                                   parameters:staff
                                                                                        error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [error printHTMLError];
            block(NO, error);
        } else {
            block(YES, nil);
        }
    }];
    [dataTask resume];
}

- (Patient*)patient{
    
    
    NSString *myFirstName = [NSString stringWithFormat:@"Self - %@",self[@"first_name"]];
    return [Patient patientFromDictionary:@{@"id" : self[@"patient_id"],
                                            @"mobile_number" : self.mobile,
                                            @"patient_id" : self[@"patient_id"],
                                            @"first_name" : myFirstName,
                                            @"last_name" : self[@"last_name"]}];
    
    
    
    
}

- (NSComparisonResult)compare:(CUser*)other
{
    
    return [self.fullName.lowercaseString compare:other.fullName.lowercaseString];
}

@end
