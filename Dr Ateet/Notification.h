//
//  Notification.h
//  Dr Ateet
//
//  Created by Shashank Patel on 04/01/18.
//  Copyright © 2018 Shashank Patel. All rights reserved.
//

#import "CObject.h"

@interface Notification : CObject

+ (id)notificationFromDictionary:(NSDictionary*)dict;
+ (void)fetchNotificationsInBackgroundWithBlock:(ArrayResultBlock)block;

@end
