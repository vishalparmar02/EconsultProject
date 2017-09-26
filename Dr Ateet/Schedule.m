//
//  Schedule.m
//  Dr Ateet
//
//  Created by Shashank Patel on 08/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "Schedule.h"

@implementation Schedule

+ (id)scheduleFromDictionary:(NSDictionary*)dict{
    Schedule *clinic = [[Schedule alloc] initWithDictionary:dict];
    return clinic;
}

- (instancetype)initWithDictionary:(NSDictionary*)dict{
//    NSLog(dict.description);
    if (self = [super initWithDictionary:dict]) {
    }
    return self;
}

+ (void)fetchSchedulesInBackgroundWithBlock:(nullable ArrayResultBlock)block{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"Authorization"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:GET_SCHEDULES];
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"GET"
                                                          URLString:URLString
                                                         parameters:nil
                                                              error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            if(block)block(nil, error);
        } else {
            NSMutableArray *schedules = [NSMutableArray array];
            NSDictionary *scheduleDict = responseObject[@"data"];
            for (NSArray *schedualArray in scheduleDict.allValues) {
                for (NSDictionary *aSchedule in schedualArray) {
                    [schedules addObject:[Schedule scheduleFromDictionary:aSchedule]];
                }
            }
            if(block)block(schedules, nil);
        }
    }];
    [dataTask resume];
}

static NSDateFormatter *inFormatter, *outFormatter;

- (NSString*)endTime{
    NSString *endTimeString = self[@"close_time"];
    
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
    NSString *startTimeString = self[@"open_time"];
    
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
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:ADD_SCHEDULE];
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"POST"
                                                          URLString:URLString
                                                         parameters:self[@"save"]
                                                              error:nil];
    NSDictionary *dict = self[@"save"];
    NSLog(@"%@", [dict JSONString]);
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [error printHTMLError];
            if(block)block(NO, error);
        } else {
            NSMutableArray *schedules = [NSMutableArray array];
            NSDictionary *scheduleDict = responseObject[@"data"];
            for (NSArray *schedualArray in scheduleDict.allValues) {
                for (NSDictionary *aSchedule in schedualArray) {
                    [schedules addObject:[Schedule scheduleFromDictionary:aSchedule]];
                }
            }
            if(block)block(YES, nil);
        }
    }];
    [dataTask resume];
}

- (void)deleteInBackgroundWithBlock:(nullable BooleanResultBlock)block{
    NSString *endPoint = [NSString stringWithFormat:DELETE_SCHEDULE, self[@"schedule_id"], @"0"];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"Authorization"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:endPoint];
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"DELETE"
                                                          URLString:URLString
                                                         parameters:self[@"update"]
                                                              error:nil];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [error printHTMLError];
            if(block)block(nil, error);
        } else {
            if ([responseObject[@"total"] integerValue]) {
                NSError *error = [NSError errorWithDomain:@"Conflict"
                                                     code:501
                                                 userInfo:responseObject];
                if(block)block(NO, error);
            }else{
                if(block)block(YES, nil);
            }
        }
    }];
    [dataTask resume];
}

- (void)forceDeleteInBackgroundWithBlock:(nullable BooleanResultBlock)block{
    NSString *endPoint = [NSString stringWithFormat:DELETE_SCHEDULE, self[@"schedule_id"], @"1"];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"Authorization"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:endPoint];
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"DELETE"
                                                          URLString:URLString
                                                         parameters:self[@"update"]
                                                              error:nil];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [error printHTMLError];
            if(block)block(nil, error);
        } else {
            if ([responseObject[@"total"] integerValue]) {
                NSError *error = [NSError errorWithDomain:@"Conflict"
                                                     code:501
                                                 userInfo:responseObject];
                if(block)block(NO, error);
            }else{
                if(block)block(YES, nil);
            }
        }
    }];
    [dataTask resume];
}

- (NSComparisonResult)compare:(id)other{
    
    NSString *selfStartTimeString = self[@"open_time"];
    NSString *otherStartTimeString = other[@"open_time"];
    
    if(!inFormatter){
        inFormatter = [NSDateFormatter new];
        inFormatter.dateFormat = @"H:m:s";
        
        outFormatter = [NSDateFormatter new];
        outFormatter.dateFormat = @"hh:mm a";
    }
    
    NSDate *selfStartTime = [inFormatter dateFromString:selfStartTimeString];
    NSDate *otherStartTime = [inFormatter dateFromString:otherStartTimeString];
    
    return [selfStartTime compare:otherStartTime];
}

@end
