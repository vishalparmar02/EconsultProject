//
//  CallController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 30/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallController : UIViewController

+ (instancetype)sharedController;

- (void)reportCall:(NSDictionary*)callDict;
- (void)reportIncomingCall:(NSDictionary *)callDict withUUID:(NSUUID *)uuid;
- (void)reportOutgoingCall:(NSDictionary *)callDict withUUID:(NSUUID *)uuid;
- (void)endCall:(NSDictionary *)callDict;

@end
