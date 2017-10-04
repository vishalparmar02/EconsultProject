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
    
    AFHTTPRequestSerializer *reqSerializer = [AFHTTPRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"Authorization"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:ADD_REPORT];
    NSDictionary *params = @{@"role_id" : [CUser currentUser][@"role_id"],
                             @"patient_id" : self.patientID,
                             @"description" : self.reportDescription,
                             @"report_type" : @"",
                             @"count" : @(self.reportImages.count)
                             };
    NSMutableURLRequest *request = [reqSerializer multipartFormRequestWithMethod:@"POST"
                                        URLString:URLString
                                       parameters:params
                        constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                            NSInteger index = 0;
                            for (UIImage *anImage in self.reportImages) {
                                NSData *imageData = UIImageJPEGRepresentation(anImage, 0.5);
                                NSString *name = [NSString stringWithFormat:@"file%ld", index++];
                                [formData appendPartWithFileData:imageData
                                                            name:name
                                                        fileName:@"image.jpg"
                                                        mimeType:@"image/jpeg"];
                            }
                            
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

- (UIImage*)reportThumb{
    NSString *fileName = self[@"file_title"];
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *fileURL = [documentsURL URLByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileURL.path]) {
        return [UIImage imageNamed:@"pdf_icon"];
    }
    
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)fileURL);
    CGPDFPageRef page;
    
    CGRect aRect = CGRectMake(0, 0, 70, 100); // thumbnail size
    UIGraphicsBeginImageContext(aRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage* thumbnailImage;
    
    NSUInteger totalNum = CGPDFDocumentGetNumberOfPages(pdf);
    
    for(int i = 0; i < totalNum; i++ ) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0.0, aRect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGContextSetGrayFillColor(context, 1.0, 1.0);
        CGContextFillRect(context, aRect);
        page = CGPDFDocumentGetPage(pdf, i + 1);
        CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, aRect, 0, true);
        CGContextConcatCTM(context, pdfTransform);
        CGContextDrawPDFPage(context, page);
        thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
        CGContextRestoreGState(context);
        if (thumbnailImage) {
            break;
        }
    }

    UIGraphicsEndImageContext();
    CGPDFDocumentRelease(pdf);
    
    return thumbnailImage;
}

@end
