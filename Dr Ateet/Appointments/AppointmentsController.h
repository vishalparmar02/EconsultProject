//
//  AppointmentsController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 30/05/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JTCalendar/JTCalendar.h>
#import "Appointment.h"
#import <BEMCheckBox/BEMCheckBox.h>
#import "AppointmentCell.h"
#import "BaseController.h"

@interface AppointmentsController : BaseController

@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTHorizontalCalendarView *calendarContentView;

@property (strong, nonatomic) JTCalendarManager *calendarManager;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarContentViewHeight;
@property (nonatomic)   BOOL clashing;

+ (AppointmentsController*)controller;
+ (AppointmentsController*)clashingController;

@end
