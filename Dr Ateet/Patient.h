//
//  Patient.h
//  Dr Ateet
//
//  Created by Shashank Patel on 22/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "CObject.h"

@interface Patient : CObject

@property (nonatomic, strong) NSURL     *imageURL;
@property (nonatomic, strong) NSString  *fullName;

+ (void)fetchPatientsInBackgroundWithBlock:(nullable ArrayResultBlock)block;
+ (void)searchPatientsFor:(NSString*)search inBackgroundWithBlock:(nullable ArrayResultBlock)block;
+ (id)patientFromDictionary:(NSDictionary*)dict;

- (void)fetchBookedAppointmentsInBackgroundWithBlock:(nullable ArrayResultBlock)block;
+ (void)addPatient:(NSDictionary*)dict inBackgroundWithBlock:(nullable DictionaryResultBlock)block;
- (BOOL)matches:(NSString*)matchString;

@end
