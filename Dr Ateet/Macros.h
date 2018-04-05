//
//  Macros.h
//  Dr Ateet
//
//  Created by Shashank Patel on 30/05/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability-completeness"

#import <SDWebImage/UIImageView+WebCache.h>
#import "UIView+Theme.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <UIAlertController+Blocks/UIAlertController+Blocks.h>
#import "AppDelegate.h"
#import <UIColor+Hex/UIColor+Hex.h>
#import "NSError+PrintHTML.h"
#import "DeviceInfo.h"
#import <JSQMessagesViewController/JSQMessage.h>
#import "API_Defines.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "API_Defines.h"

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

#define APP_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]
#define ABOUT_STRING [NSString stringWithFormat:@"About %@", DOCTOR_NAME]

#define PushNotificationDetailsKey  @"PushNotificationDetailsKey"
#define DEVICE_TOKEN                @"DeviceToken"

#define APP_BLUE [UIColor colorWithHex:0x3498DB]
#define APP_GRAY [UIColor colorWithHex:0x464646]

#define ControllerFromStoryBoard(storyboard, identifier) [[UIStoryboard storyboardWithName:storyboard bundle:nil] instantiateViewControllerWithIdentifier:identifier]
#define ControllerFromMainStoryBoard(identifier) ControllerFromStoryBoard(@"Main", identifier)
#define NavigationControllerWithController(controller) [[UINavigationController alloc] initWithRootViewController:controller]

#endif /* Macros_h */
