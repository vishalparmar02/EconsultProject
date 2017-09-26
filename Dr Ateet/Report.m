//
//  Report.m
//  Dr Ateet
//
//  Created by Shashank Patel on 08/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "Report.h"

@implementation Report

+ (id)reportFromDictionary:(NSDictionary*)dict{
    Report *clinic = [[Report alloc] initWithDictionary:dict];
    return clinic;
}

- (instancetype)initWithDictionary:(NSDictionary*)dict{
//    NSLog(dict.description);
    if (self = [super initWithDictionary:dict]) {
    }
    return self;
}

+ (void)fetchReportsForPatientID:(NSString*)patientID
           inBackgroundWithBlock:(nullable ReportsResultBlock)block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"Authorization"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:GET_REPORTS];
    NSDictionary *params = @{@"patient_id" : patientID};
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"POST"
                                                          URLString:URLString
                                                         parameters:params
                                                              error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            if(block)block(nil, nil, error);
        } else {
            NSArray *patientReportsArray = responseObject[@"uploadByPatient"];
            NSArray *doctorReportsArray = responseObject[@"uploadByDoctor"];
            
            NSMutableArray  *patientReports = [NSMutableArray array];
            NSMutableArray  *doctorReports = [NSMutableArray array];
            
            for (NSDictionary *aReportDict in patientReportsArray) {
                [patientReports addObject:[Report reportFromDictionary:aReportDict]];
            }
            
            for (NSDictionary *aReportDict in doctorReportsArray) {
                [doctorReports addObject:[Report reportFromDictionary:aReportDict]];
            }
            
            if(block)block(doctorReports, patientReports, nil);
        }
    }];
    [dataTask resume];
}

- (void)saveInBackgroundWithBlock:(BooleanResultBlock)block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"Authorization"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:ADD_REPORT];
    NSDictionary *params = @{@"role_id" : [CUser currentUser][@"role_id"],
                             @"patient_id" : self.patientID,
                             @"description" : self.reportDescription,
                             @"report_type" : @""};
    NSMutableURLRequest *request = [reqSerializer multipartFormRequestWithMethod:@"POST"
                                        URLString:URLString
                                       parameters:params
                        constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                            NSData *imageData = UIImageJPEGRepresentation(self.reportImage, 0.5);
                            [formData appendPartWithFileData:imageData
                                                        name:@"file"
                                                    fileName:@"image.jpg" 
                                                    mimeType:@"image/jpeg"];
                        } error:nil];
   
                             
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

- (NSURL*)reportImageURL{
    return [NSURL URLWithString:self[@"upload_path"]];
}

@end
