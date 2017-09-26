//
//  BookAppointmentController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 24/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseController.h"
#import "Slot.h"
#import "Appointment.h"
#import "SlotCell.h"

@interface BookAppointmentController : BaseController

@property (nonatomic, strong) Appointment   *appointment;

+ (BookAppointmentController*)controller;

@end
