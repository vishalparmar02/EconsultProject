//
//  PubBunManager.m
//  SmallCircles
//
//  Created by Shashank Patel on 10/01/16.
//  Copyright © 2016 AmolG. All rights reserved.
//

#import "PubNubManager.h"
#import "Macros.h"
#import "Patient.h"

#define kDeviceToken defaults_object(@"DeviceToken")

@implementation PubNubManager

+ (void)load{
    [self sharedManager];
}

+ (instancetype)sharedManager{
    static dispatch_once_t onceToken;
    static PubNubManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[PubNubManager alloc] init];
    });

    return manager;
}

+ (void)updateChannels{
    [[self sharedManager] updateChannels];
}

+ (void)sendMessage:(NSDictionary*)json toChannel:(NSString*)channel{
    [[self sharedManager] sendMessage:json toChannel:channel];
}

- (void)setOffline{
    [self.client unsubscribeFromAll];
}

- (void)setOnline{
    [self updateChannels];
}

- (void)updateChannels{
    [self.client unsubscribeFromAll];
    [self.client removeAllPushNotificationsFromDeviceWithPushToken:kDeviceToken andCompletion:nil];
    
    NSMutableArray *channels = [NSMutableArray array];
    CUser *currentUser = [CUser currentUser];
    
    if (currentUser) {
        if ([currentUser isPatient]) {//Patient
            NSString *patientID = currentUser[@"patient_id"];
            if (![patientID isKindOfClass:[NSString class]]) {
                patientID = [(NSNumber*)patientID stringValue];
            }
            [channels addObject:[NSString stringWithFormat:@"patient_%@", patientID]];
            [self.client subscribeToChannels:channels withPresence:NO];
            if (!TARGET_OS_SIMULATOR) {
                NSLog(@"Device Token: %@", kDeviceToken);
                [self.client addPushNotificationsOnChannels:channels
                                        withDevicePushToken:kDeviceToken
                                              andCompletion:^(PNAcknowledgmentStatus *status) {
                                                  if (status.isError){
                                                      NSLog(@"Could not add Push Notifications to PubNub");
                                                  }
                                              }];
            }
        }else if([currentUser isDoctor]){//Doctor
            [Patient fetchPatientsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                for (Patient *aPatient in objects) {
                    [channels addObject:[NSString stringWithFormat:@"patient_%@", aPatient.objectId]];
                }
                [self.client subscribeToChannels:channels withPresence:NO];
                NSLog(@"Device Token: %@", kDeviceToken);
                if (!TARGET_OS_SIMULATOR) {
                    [[PubNubManager sharedManager].client addPushNotificationsOnChannels:channels
                                                                     withDevicePushToken:kDeviceToken
                                                                           andCompletion:^(PNAcknowledgmentStatus *status) {
                                                                               if (status.isError){
                                                                                   NSLog(@"Could not add Push Notifications to PubNub");
                                                                               }
                                                                           }];
                }
            }];
        }
    }
}

- (void)sendMessage:(NSDictionary*)json toChannel:(NSString*)channel{
//    NSDictionary *pushPayload = @{@"aps": @{@"content-available" : @1,
//                                            @"sound": @"",
//                                            @"call_payload" : json}};
    BOOL isCall = [json[@"type"] isEqualToString:@"v_call"];
    NSDictionary *callPayload = @{@"call_payload" :json};
    NSString *isDoctor = [[CUser currentUser] isDoctor] ? @"y" : @"n";
    NSDictionary *pushPayload = @{@"aps": @{@"content-available" : @1,
                                            @"sound": @"",
                                            @"call_payload" : json},
                                  @"pn_gcm":@{@"data":@{@"isDoctor": isDoctor,
                                                        @"call_payload": json,
                                                        @"push_message" :json[@"description"],
                                                        @"type": json[@"type"]}
                                            }
                                  };
    [self.client publish:callPayload
               toChannel:channel
       mobilePushPayload:isCall ? pushPayload : nil
          withCompletion:^(PNPublishStatus * _Nonnull status) {
              
          }];
}

- (instancetype)init{
    if (self = [super init]) {
        NSLog(@"%d - %@:%@", DEBUG, TARGET_NAME, PUBLISH_KEY);
        self.configuration = [PNConfiguration configurationWithPublishKey:PUBLISH_KEY
                                                             subscribeKey:SUB_KEY];
        NSLog(PUBLISH_KEY);
        self.client = [PubNub clientWithConfiguration:self.configuration];
        [self.client addListener:self];
        [self updateChannels];
    }
    
    return self;
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    
    NSDictionary *JSON = message.data.message;
    if (JSON[@"call_payload"]) {
        JSON = JSON[@"call_payload"];
    }
    
    if (JSON[@"json_data"]) {
        JSON = JSON[@"json_data"];
    }
    
    NSLog(@"isSimulator: %d, Type:%@", IS_SIMULATOR, JSON[@"type"]);
    if ([JSON[@"type"] isEqualToString:@"v_call"]) {
        NSLog(@"Call: %@", JSON.description);
        if([UIApplication sharedApplication].applicationState != UIApplicationStateActive){
            UILocalNotification *notification = [[UILocalNotification alloc]init];
            notification.userInfo = JSON;
            [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
            [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
            notification.soundName = @"ring.wav";
            [notification setAlertBody:JSON[@"description"]];
            NSString *type = JSON[@"type"];
            if ([type isEqualToString:@"v_call"]) {
                [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
            }
        }else{
            NSNotification *notification = [NSNotification notificationWithName:@"INCOMING_CALL_NOTIFICATION"
                                                                         object:nil
                                                                       userInfo:JSON];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    }else if([JSON[@"type"] isEqualToString:@"v_call_end"]){
        NSNotification *notification = [NSNotification notificationWithName:@"CALL_END_NOTIFICATION"
                                                                     object:nil
                                                                   userInfo:JSON];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }else if([JSON[@"type"] isEqualToString:@"v_call_reject"]){
        NSNotification *notification = [NSNotification notificationWithName:@"CALL_END_NOTIFICATION"
                                                                     object:nil
                                                                   userInfo:JSON];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event{
    return;
    if (![event.data.channel isEqualToString:event.data.subscription]) {
        
        // Presence event has been received on channel group stored in event.data.subscription.
    }
    else {
        
        // Presence event has been received on channel stored in event.data.channel.
    }
    
    if (![event.data.presenceEvent isEqualToString:@"state-change"]) {
        
        NSLog(@"%@ \"%@'ed\"\nat: %@ on %@ (Occupancy: %@)", event.data.presence.uuid,
              event.data.presenceEvent, event.data.presence.timetoken, event.data.channel,
              event.data.presence.occupancy);
    }
    else {
        
        NSLog(@"%@ changed state at: %@ on %@ to: %@", event.data.presence.uuid,
              event.data.presence.timetoken, event.data.channel, event.data.presence.state);
    }
}

- (void)client:(PubNub *)client didReceiveStatus:(PNSubscribeStatus *)status {
    
    if (status.category == PNUnexpectedDisconnectCategory) {
        // This event happens when radio / connectivity is lost
    }
    
    else if (status.category == PNConnectedCategory) {
        
        // Connect event. You can do stuff like publish, and know you'll get it.
        // Or just use the connected event to confirm you are subscribed for
        // UI / internal notifications, etc
        
    }
    else if (status.category == PNReconnectedCategory) {
        
        // Happens as part of our regular operation. This event happens when
        // radio / connectivity is lost, then regained.
    }
    else if (status.category == PNDecryptionErrorCategory) {
        
        // Handle messsage decryption error. Probably client configured to
        // encrypt messages and on live data feed it received plain text.
    }
    
}

@end
