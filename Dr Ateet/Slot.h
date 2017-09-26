//
//  Slot.h
//  Dr Ateet
//
//  Created by Shashank Patel on 08/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "CObject.h"
#import "Clinic.h"

@interface Slot : CObject

@property (nonatomic, strong)   NSDate  *date;
@property (nonatomic, strong)   Clinic  *clinic;

+ (void)fetchSlotsForDate:(NSDate*)date clinic:(Clinic*)clinic inBackgroundWithBlock:(nullable ArrayResultBlock)block;

- (NSString*)startTime;
- (NSString*)endTime;
- (NSString*)time;
- (NSString*)repeatString;
- (CGFloat)heightForRepeatString;
- (CGFloat)height;
- (NSString*)timePerPatient;
- (BOOL)hasPassedForDate:(NSDate*)date;

@end
