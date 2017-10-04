//
//  Appointment.m
//  Dr Ateet
//
//  Created by Shashank Patel on 22/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "Appointment.h"

@implementation Appointment

+ (void)fetchClashingAppointmentsBackgroundWithBlock:(nullable ArrayResultBlock)block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"Authorization"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:GET_CLASHING_APPOINTMENTS];
    
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"GET"
                                                          URLString:URLString
                                                         parameters:nil
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
            
            [appointments sortUsingComparator:^NSComparisonResult(Appointment *obj1, Appointment *obj2) {
                return [obj1.appointmentDate compare:obj2.appointmentDate];
            }];
            
            if(block)block(appointments, nil);
        }
    }];
    [dataTask resume];
}

+ (void)fetchAppointmentsForDate:(NSDate*)date inBackgroundWithBlock:(nullable ArrayResultBlock)block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"Authorization"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:GET_APPOINTMENTS];
    
    static NSDateFormatter *dateFormatter;
    
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    
    NSDictionary *params = @{@"appointment_date" : [dateFormatter stringFromDate:date]};
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
            
            [appointments sortUsingComparator:^NSComparisonResult(Appointment *obj1, Appointment *obj2) {
                return [obj1.appointmentDate compare:obj2.appointmentDate];
            }];
            
            if(block)block(appointments, nil);
        }
    }];
    [dataTask resume];
}

+ (void)fetchAppointmentsForPatientInBackgroundWithBlock:(nullable ArrayResultBlock)block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"Authorization"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:PATIENT_APPOINTMENTS];

    NSDictionary *params = @{@"users_id" : [CUser currentUser].objectId,
                             @"patient_id" : [CUser currentUser][@"patient_id"]};
    
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
            
            [appointments sortUsingComparator:^NSComparisonResult(Appointment *obj1, Appointment *obj2) {
                return [obj1.appointmentDate compare:obj2.appointmentDate];
            }];
            
            if(block)block(appointments, nil);
        }
    }];
    [dataTask resume];
}

+ (id)appointmentFromDictionary:(NSDictionary*)dict{
    Appointment *anAppointment = [[Appointment alloc] initWithDictionary:dict];
    return anAppointment;
}

- (void)deleteInBackgroundWithBlock:(nullable BooleanResultBlock)block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"Authorization"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:CANCEL_APPOINTMENT];
    
    NSDictionary *params = @{@"id" : self.objectId,
                             @"canceled_reason" : @"",
                             @"is_canceled_by_patient" : @([[CUser currentUser] isPatient])};
    
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"POST"
                                                          URLString:URLString
                                                         parameters:params
                                                              error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            if(block)block(NO, error);
        } else {
            
            if(block)block(YES, nil);
        }
    }];
    [dataTask resume];
}

- (void)updateInBackgroundWithBlock:(nullable BooleanResultBlock)block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"Authorization"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:UPDATE_APPOINTMENT];
    
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"POST"
                                                          URLString:URLString
                                                         parameters:self[@"update"]
                                                              error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [error printHTMLError];
            if(block)block(NO, error);
        } else {
            
            if(block)block(YES, nil);
        }
    }];
    [dataTask resume];
}

- (void)markDoneInBackgroundWithBlock:(nullable BooleanResultBlock)block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"Authorization"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:MARK_DONE_APPOINTMENT];
    NSDictionary *params = @{@"id" : self.objectId};
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"POST"
                                                          URLString:URLString
                                                         parameters:params
                                                              error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [error printHTMLError];
            if(block)block(NO, error);
        } else {
            
            if(block)block(YES, nil);
        }
    }];
    [dataTask resume];
}

- (BOOL)allowConsultation{
    if ([[CUser currentUser] isDoctor]) {
        return YES;
    }
    
    if (![[self[@"clinic_name"] lowercaseString] isEqualToString:@"online"]) {
        return NO;
    }
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.appointmentDate];
    if (interval > 0 &&  fabs(interval) < (30 * 60)) {
        return YES;
    }
    
    if (interval < 0 &&  fabs(interval) < (10 * 60)) {
        return YES;
    }
    
    return NO;
}

static NSDateFormatter *inFormatter, *outFormatter, *appointmentDF;

- (NSString*)endTime{
    NSString *endTimeString = self[@"end_time"];
    
    if(!inFormatter){
        inFormatter = [NSDateFormatter new];
        inFormatter.dateFormat = @"H:m:s";
        
        outFormatter = [NSDateFormatter new];
        outFormatter.dateFormat = @"hh:mm a";
        
    }
    
    NSDate *endTime = [inFormatter dateFromString:endTimeString];
    return [outFormatter stringFromDate:endTime];
}

- (NSString*)startTime{
    NSString *startTimeString = self[@"start_time"];
    
    if(!inFormatter){
        inFormatter = [NSDateFormatter new];
        inFormatter.dateFormat = @"H:m:s";
        
        outFormatter = [NSDateFormatter new];
        outFormatter.dateFormat = @"hh:mm a";
    }
    
    NSDate *startTime = [inFormatter dateFromString:startTimeString];
    return [outFormatter stringFromDate:startTime];
}

- (NSString*)appointmentDateString{
    if(!appointmentDF){
        appointmentDF = [NSDateFormatter new];
    }
    NSDate *appointmentDate = [self appointmentDate];
    appointmentDF.dateFormat = @"dd LLL, yyyy";
    return [appointmentDF stringFromDate:appointmentDate];
}

- (NSDate*)appointmentDate{
    if(!appointmentDF){
        appointmentDF = [NSDateFormatter new];
    }
    appointmentDF.dateFormat = @"yyyy-MM-dd hh:mm a";
    NSString *appointmentDateString = [NSString stringWithFormat:@"%@ %@",
                                       self[@"appointment_date"],
                                       [self startTime]];
    return [appointmentDF dateFromString:appointmentDateString];
}

- (BOOL)hasPassed{
    return [self.appointmentEndDate compare:[NSDate date]] == NSOrderedAscending;
}

- (NSDate*)appointmentEndDate{
    if(!appointmentDF){
        appointmentDF = [NSDateFormatter new];
        
    }
    appointmentDF.dateFormat = @"yyyy-MM-dd hh:mm a";
    NSString *appointmentDateString = [NSString stringWithFormat:@"%@ %@",
                                       self[@"appointment_date"],
                                       [self endTime]];
    return [appointmentDF dateFromString:appointmentDateString];
}


@end
