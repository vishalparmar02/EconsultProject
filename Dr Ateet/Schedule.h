//
//  Schedule.h
//  Dr Ateet
//
//  Created by Shashank Patel on 08/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "CObject.h"

@interface Schedule : CObject

+ (void)fetchSchedulesInBackgroundWithBlock:(nullable ArrayResultBlock)block;

- (NSString*)startTime;
- (NSString*)endTime;
- (NSString*)repeatMonthsString;
- (NSString*)time;
- (NSString*)repeatString;
- (CGFloat)heightForRepeatMonths;
- (CGFloat)heightForRepeatString;
- (CGFloat)height;
- (NSString*)timePerPatient;
- (void)forceDeleteInBackgroundWithBlock:(nullable BooleanResultBlock)block;

@end
