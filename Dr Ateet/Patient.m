//
//  Patient.m
//  Dr Ateet
//
//  Created by Shashank Patel on 22/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "Patient.h"
#import "Appointment.h"

@implementation Patient


+ (void)fetchPatientsInBackgroundWithBlock:(nullable ArrayResultBlock)block
{
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:GET_PATIENTS];
    NSLog(@"URLString: %@", URLString);
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"GET"
                                                          URLString:URLString
                                                         parameters:nil
                                                              error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            if(block)block(nil, error);
        } else {
            NSMutableArray *patients = [NSMutableArray array];
            NSArray *patientsArray = responseObject[@"data"];
            for (NSDictionary *patientDict in patientsArray) {
                [patients addObject:[Patient patientFromDictionary:patientDict]];
            }
            if(block)block(patients, nil);
        }
    }];
    [dataTask resume];
}



+ (void)searchPatientsFor:(NSString*)search inBackgroundWithBlock:(nullable ArrayResultBlock)block{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:SEARCH_PATIENTS];
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"POST"
                                                          URLString:URLString
                                                         parameters:@{@"search_text" : search}
                                                              error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            if(block)block(nil, error);
        } else {
            NSMutableArray *patients = [NSMutableArray array];
            NSArray *patientsArray = responseObject[@"data"];
            for (NSDictionary *patientDict in patientsArray) {
                [patients addObject:[Patient patientFromDictionary:patientDict]];
            }
            if(block)block(patients, nil);
        }
    }];
    [dataTask resume];
}

+ (void)addPatient:(NSDictionary*)dict inBackgroundWithBlock:(nullable DictionaryResultBlock)block{
    
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:ADD_PATIENT];
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"POST"
                                                          URLString:URLString
                                                         parameters:dict
                                                              error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [error printHTMLError];
            if(block)block(nil, error);
        } else {
            block(responseObject, nil);
        }
    }];
    [dataTask resume];
}

- (void)fetchBookedAppointmentsInBackgroundWithBlock:(nullable ArrayResultBlock)block{
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:GET_BOOKED_APPOINTMENTS];
    
    NSDictionary *params = @{@"patient_id" : self.objectId};
    
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"POST"
                                                          URLString:URLString
                                                         parameters:params
                                                              error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            if(block)block(nil, error);
        } else {
            NSMutableArray *appointments = [NSMutableArray array];
            NSArray *appointmentsArray = responseObject[@"data"];
            for (NSDictionary *appointmentDict in appointmentsArray) {
                [appointments addObject:[Appointment appointmentFromDictionary:appointmentDict]];
            }
            if(block)block(appointments, nil);
        }
    }];
    [dataTask resume];
}


+ (id)patientFromDictionary:(NSDictionary*)dict
{
    Patient *aPatient = [[Patient alloc] initWithDictionary:dict];
    return aPatient;
}

- (NSString*)objectId{
    if (![[super objectId] length])
    {
        return self[@"patient_id"];
    }
    
    return [super objectId];
}

- (NSString *)fullName{
    NSString *fullName = self[@"name"];
    if (!fullName.length) {
        fullName = [NSString stringWithFormat:@"%@ %@", self[@"first_name"], self[@"last_name"]];
    }
    
    return fullName.capitalizedString;
}

- (NSURL*)imageURL{
    
    return [NSURL URLWithString:self[@"profile_pic"]];
}

- (BOOL)isEqual:(Patient*)other{
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        return [self.objectId isEqualToString:other.objectId];
    }
}

- (NSUInteger)hash{
    return self.objectId.integerValue;
}

- (NSComparisonResult)compare:(Patient*)other{
    return [self.fullName.lowercaseString compare:other.fullName.lowercaseString];
}

- (BOOL)matches:(NSString*)matchString{
    return [[self fullName] rangeOfString:matchString options:NSCaseInsensitiveSearch].location != NSNotFound
    || [self[@"mobile_number"] rangeOfString:matchString options:NSCaseInsensitiveSearch].location != NSNotFound
    || matchString.length == 0;
}

@end
