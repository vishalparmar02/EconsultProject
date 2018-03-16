//
//  Appointment.m
//  Dr Ateet
//
//  Created by Shashank Patel on 22/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "Appointment.h"
#import "CallController.h"
#import "PubNubManager.h"

@implementation Appointment

+ (void)fetchClashingAppointmentsBackgroundWithBlock:(nullable ArrayResultBlock)block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
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
                Appointment *appointment = [Appointment appointmentFromDictionary:appointmentDict];
                if (![appointment hasPassed]) {
                    [appointments addObject:appointment];
                }
                
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
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
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
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
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
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:CANCEL_APPOINTMENT];
    
    NSDictionary *params = @{@"id" : self.objectId,
                             @"canceled_reason" : self[@"reason"],
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
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
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
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
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
    
    if (interval < 0 &&  fabs(interval) < (5 * 60)) {
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

- (NSString*)todayDateString{
    if(!appointmentDF){
        appointmentDF = [NSDateFormatter new];
    }
    NSDate *today = [NSDate date];
    appointmentDF.dateFormat = @"dd LLL, yyyy";
    return [appointmentDF stringFromDate:today];
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

- (BOOL)isOnToday{
    return [self.appointmentDateString isEqualToString:self.todayDateString];
}

- (BOOL)isInFuture{
    return [self.appointmentDate compare:[NSDate date]] == NSOrderedDescending;
}

- (BOOL)isOnline{
    return [[self[@"clinic_name"] lowercaseString] isEqualToString:@"online"];
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

- (void)startConsultation{
    if (![self isOnline]) {
        return;
    }
    
    if ([[CUser currentUser] isStaff]) {
        return;
    }
    
    NSNumber *senderID = [[CUser currentUser] isPatient] ? [CUser currentUser][@"patient_id"] : @-1;
    NSString *calleeChannel = PATIENT_CHANNEL([self[@"patient_id"] stringValue]);
    
    NSString *roomID = [NSString stringWithFormat:@"room_%u", arc4random_uniform(999999)];
    NSString *callDescription = @"Dr. would like to start video consulation.";
    if ([[CUser currentUser] isPatient]) {
        NSString *patientName = [NSString stringWithFormat:@"%@ %@", [CUser currentUser][@"first_name"],
                                 [CUser currentUser][@"last_name"]];
        
        callDescription = [NSString stringWithFormat:@"%@ would like to start video consulation.", patientName];
    }
    
    NSDictionary *callDict = @{@"description" : callDescription,
                               @"is_initiator" : @1,
                               @"room_id" : roomID,
                               @"sender_id" : senderID,
                               @"type" : @"v_call",
                               @"channel" : calleeChannel,
                               @"caller" : [[CUser currentUser] fullName],
                               @"callee" : @"Dr."};
    [CallController sharedController].expectingCall = YES;
    [PubNubManager sendMessage:callDict toChannel:calleeChannel];
}

@end
