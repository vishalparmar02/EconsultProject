//
//  GiveAppointmentController.h
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
#import "Patient.h"

@interface GiveAppointmentController : BaseController

@property (nonatomic, strong) Patient       *patient;

+ (GiveAppointmentController*)controller;

@end
