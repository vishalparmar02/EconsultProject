//
//  APIManager.h
//  Dr Ateet
//
//  Created by Shashank Patel on 27/03/18.
//  Copyright © 2018 Shashank Patel. All rights reserved.
//

#import "CObject.h"

@interface APIManager : CObject

@property (nonatomic)   BOOL ready;

+ (instancetype)sharedManager;

- (NSString*)baseURL;
- (NSString*)pubnubPublishKey;
- (NSString*)pubnubSubscribeKey;
- (NSString*)paymentURL;
- (BOOL)videoConsultationEnabled;
- (BOOL)appointmentsEnabled;
- (BOOL)patientReportsEnabled;
    
@end
