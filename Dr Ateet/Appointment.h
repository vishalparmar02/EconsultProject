//
//  Appointment.h
//  Dr Ateet
//
//  Created by Shashank Patel on 22/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "CObject.h"

@interface Appointment : CObject

+ (void)fetchClashingAppointmentsBackgroundWithBlock:(nullable ArrayResultBlock)block;
+ (void)fetchAppointmentsForDate:(NSDate*)date inBackgroundWithBlock:(nullable ArrayResultBlock)block;
+ (void)fetchAppointmentsForPatientInBackgroundWithBlock:(nullable ArrayResultBlock)block;

+ (id)appointmentFromDictionary:(NSDictionary*)dict;

- (void)markDoneInBackgroundWithBlock:(nullable BooleanResultBlock)block;

- (NSString*)endTime;
- (NSString*)startTime;
- (NSDate*)appointmentDate;
- (NSDate*)appointmentEndDate;
- (NSString*)appointmentDateString;
- (BOOL)hasPassed;
- (BOOL)allowConsultation;
- (BOOL)isOnToday;
- (BOOL)isInFuture;
- (BOOL)isOnline;
- (void)startConsultation;

@end
