//
//  Report.h
//  Dr Ateet
//
//  Created by Shashank Patel on 08/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "CObject.h"

@interface Report : CObject

typedef void (^ReportsResultBlock)(NSArray *_Nullable doctorReports, NSArray *_Nullable patientReports, NSError *_Nullable error);

@property (nonatomic, strong)   NSString    *reportType, *reportDescription;
@property (nonatomic, strong)   NSString    *patientID;
@property (nonatomic, strong)   UIImage     *reportImage;

+ (void)fetchReportsForPatientID:(NSString*)patientID
           inBackgroundWithBlock:(nullable ReportsResultBlock)block;

- (NSURL*)reportImageURL;

@end
