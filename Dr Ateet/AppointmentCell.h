//
//  AppointmentsListController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 22/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Appointment.h"
#import <BEMCheckBox/BEMCheckBox.h>

@class Appointment;

@protocol AppointmentCellDelegate <NSObject>

- (void)cancelAppointment:(Appointment*)appointment;
- (void)markDoneAppointment:(Appointment*)appointment;
- (void)editAppointment:(Appointment*)appointment;
- (void)startConsultation:(Appointment*)appointment;
- (void)infoTapped:(Appointment*)appointment;

@end

@interface AppointmentCell : UITableViewCell<BEMCheckBoxDelegate>

@property (nonatomic, strong) IBOutlet  UILabel         *clinicNameLabel;
@property (nonatomic, strong) IBOutlet  UILabel         *nameLabel, *timeLabel, *dateLabel;
@property (nonatomic, strong) IBOutlet  UILabel         *mobileLabel, *bookedByLabel;
@property (nonatomic, strong) IBOutlet  UILabel         *consulationDoneLabel, *paymentStatusLabel;
@property (nonatomic, strong) IBOutlet  UILabel         *consulationStatusLabel;
@property (nonatomic, strong) IBOutlet  UIButton        *startConsultationButton;
@property (nonatomic, strong) IBOutlet  UIView          *consulationDoneContainer;
@property (nonatomic, strong) IBOutlet  UIImageView     *infoIcon;
@property (nonatomic, strong) IBOutlet  UIButton        *changeButton, *cancelButton, *infoButton;
@property (nonatomic, strong) IBOutlet  UIView          *container;
@property (nonatomic, strong)           Appointment     *appointment;
@property (nonatomic, strong)           BEMCheckBox     *consulationDoneCheckBox;
@property (nonatomic, strong)           id<AppointmentCellDelegate> delegate;
@property (nonatomic)                   BOOL            consultation;
@property (nonatomic, strong) IBOutlet  UIView          *actionView;

@end
