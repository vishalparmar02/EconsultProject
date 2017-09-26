//
//  Slot.m
//  Dr Ateet
//
//  Created by Shashank Patel on 08/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "Slot.h"

@implementation Slot

+ (id)slotFromDictionary:(NSDictionary*)dict{
    Slot *clinic = [[Slot alloc] initWithDictionary:dict];
    return clinic;
}

- (instancetype)initWithDictionary:(NSDictionary*)dict{
//    NSLog(dict.description);
    if (self = [super initWithDictionary:dict]) {
    }
    return self;
}

+ (void)fetchSlotsForDate:(NSDate*)date
                   clinic:(Clinic*)clinic
    inBackgroundWithBlock:(nullable ArrayResultBlock)block{
    static NSDateFormatter *df;
    if (!df) {
        df = [NSDateFormatter new];
        df.dateFormat = @"yyyy-MM-dd";
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"Authorization"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:GET_SLOTS];
    
    NSDictionary    *params = @{@"appointment_date": [df stringFromDate:date],
                                @"clinic_id" : clinic.objectId};
    
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"POST"
                                                          URLString:URLString
                                                         parameters:params
                                                              error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [error printHTMLError];
            if(block)block(nil, error);
        } else {
            NSMutableArray *slots = [NSMutableArray array];
            NSArray *slotArray = responseObject[@"data"];
            for (NSDictionary *aSlotDict in slotArray) {
                [slots addObject:[Slot slotFromDictionary:aSlotDict]];
            }
            if(block)block(slots, nil);
        }
    }];
    [dataTask resume];
}

static NSDateFormatter *inFormatter, *outFormatter;

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

- (NSString*)time{
    NSString *startTimeString = self[@"open_time"];
    NSString *endTimeString = self[@"close_time"];
    
    if(!inFormatter){
        inFormatter = [NSDateFormatter new];
        inFormatter.dateFormat = @"H:m:s";
        
        outFormatter = [NSDateFormatter new];
        outFormatter.dateFormat = @"hh:mm a";
        
    }
    
    NSDate *startTime = [inFormatter dateFromString:startTimeString];
    NSDate *endTime = [inFormatter dateFromString:endTimeString];
    
    NSString *time = [NSString stringWithFormat:@"%@ - %@",
                      [outFormatter stringFromDate:startTime],
                      [outFormatter stringFromDate:endTime]];
    
    return time;
}

static NSDateFormatter *todayFormatter, *onlyDateFormatter;

- (BOOL)hasPassedForDate:(NSDate*)date{
    
    if(!todayFormatter){
        todayFormatter = [NSDateFormatter new];
        todayFormatter.dateFormat = @"yyyy-MM-dd hh:mm a";
        
        onlyDateFormatter = [NSDateFormatter new];
        onlyDateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    
    NSDate *todayDate = [NSDate date];
    NSString *slotDateString = [NSString stringWithFormat:@"%@ %@",
                                [onlyDateFormatter stringFromDate:date],
                                [self startTime]];
    NSDate *slotDate = [todayFormatter dateFromString:slotDateString];
    return [slotDate compare:todayDate] == NSOrderedAscending;
}

- (NSString*)timePerPatient{
    return [NSString stringWithFormat:@"%@ Minutes", self[@"time_duration"]];
}

- (NSString*)repeatString{
    NSArray *repeatArray = self[@"repeat"];
    NSMutableArray *repeatStringArray = [NSMutableArray array];
    for (NSDictionary *repeatDict in repeatArray) {
        if ([repeatDict[@"isChecked"] boolValue]) {
            NSString *day = [repeatDict[@"day"] substringToIndex:3];
            NSArray *weeks = repeatDict[@"repeat_days"];
            
            NSMutableArray *weekStrings = [NSMutableArray array];
            
            BOOL weekRepeat[4] = {NO, NO, NO, NO};
            
            for (NSString *weekName in weeks) {
                weekRepeat[[weekName integerValue] - 1] = YES;
                [weekStrings addObject:[NSString stringWithFormat:@"Week %@", weekName]];
            }
            
            NSString *weekDetail = [weekStrings componentsJoinedByString:@", "];
            if (weekRepeat[0] == YES &&
                weekRepeat[1] == YES &&
                weekRepeat[2] == YES &&
                weekRepeat[3] == YES) {
                weekDetail = @"All Weeks";
            }
            
            NSString *repeatString = [NSString stringWithFormat:@"%@ (%@)", day, weekDetail];
            [repeatStringArray addObject:repeatString];
        }  
    }
    
    return [repeatStringArray componentsJoinedByString:@"\n"];
}

- (CGFloat)heightForRepeatString{
    UIFont *font = [UIFont fontWithName:@"Roboto-Light" size:14];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributes = @{NSFontAttributeName : font,
                                 NSParagraphStyleAttributeName: paragraphStyle};
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:[self repeatString]
                                                                  attributes:attributes];
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 20;
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(width, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    CGFloat height = rect.size.height;
    if ((int)height % 21 != 0) {
        int div = ((int)height) / 21;
        div++;
        return 21 * div;
    }
    
    return rect.size.height;
}

- (CGFloat)height{
    CGFloat titleHeight = [self heightForRepeatString];
    return titleHeight + 120;
}

- (void)saveInBackgroundWithBlock:(BooleanResultBlock)block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"Authorization"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:ADD_APPOINTMENT];
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"POST"
                                                          URLString:URLString
                                                         parameters:self[@"save"]
                                                              error:nil];
//    NSLog(@"Dict: %@", [self[@"save"] description]);
//    NSDictionary *dict = self[@"save"];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [error printHTMLError];
            if(block)block(nil, error);
        } else {
            NSMutableArray *slots = [NSMutableArray array];
            NSDictionary *slotDict = responseObject[@"data"];
            for (NSArray *schedualArray in slotDict.allValues) {
                for (NSDictionary *aSlot in schedualArray) {
                    [slots addObject:[Slot slotFromDictionary:aSlot]];
                }
            }
            if(block)block(slots, nil);
        }
    }];
    [dataTask resume];
}

- (void)updateInBackgroundWithBlock:(BooleanResultBlock)block{
    NSString *endPoint = [NSString stringWithFormat:UPDATE_SCHEDULE, self[@"slot_id"]];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"Authorization"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:endPoint];
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"PUT"
                                                          URLString:URLString
                                                         parameters:self[@"update"]
                                                              error:nil];
    NSDictionary *dict = self[@"update"];
    NSLog([dict JSONString]);
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [error printHTMLError];
            if(block)block(nil, error);
        } else {
            NSMutableArray *slots = [NSMutableArray array];
            NSDictionary *slotDict = responseObject[@"data"];
            for (NSArray *schedualArray in slotDict.allValues) {
                for (NSDictionary *aSlot in schedualArray) {
                    [slots addObject:[Slot slotFromDictionary:aSlot]];
                }
            }
            if(block)block(slots, nil);
        }
    }];
    [dataTask resume];
}

@end
