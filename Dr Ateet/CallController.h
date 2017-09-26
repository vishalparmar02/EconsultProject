//
//  CallController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 30/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallController : UIViewController

@property (nonatomic)       BOOL    isOnCall, expectingCall;

+ (instancetype)sharedController;

- (void)callReceived:(NSNotification*)notification;

@end
