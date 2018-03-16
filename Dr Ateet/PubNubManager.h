//
//  PubBunManager.h
//  SmallCircles
//
//  Created by Shashank Patel on 10/01/16.
//  Copyright © 2016 AmolG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PubNub/PubNub.h>
#import "API_Defines.h"

@interface PubNubManager : NSObject<PNObjectEventListener>

@property(nonatomic, strong)    PNConfiguration     *configuration;
@property(nonatomic, strong)    PubNub              *client;

+ (instancetype)sharedManager;
+ (void)sendMessage:(NSDictionary*)json toChannel:(NSString*)channel;
+ (void)updateChannels;

- (void)setOffline;
- (void)setOnline;

@end
