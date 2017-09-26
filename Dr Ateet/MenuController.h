//
//  MenuController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 08/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuController : UIViewController

+ (id)controller;
- (void)reload;

- (void)bookAppointmentTapped;
- (void)myAppointmentsTapped;
- (void)reportsTapped;

@end
