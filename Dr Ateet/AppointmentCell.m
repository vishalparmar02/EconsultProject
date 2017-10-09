//
//  AppointmentsListController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 22/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "AppointmentCell.h"

@implementation AppointmentCell

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.container applyShadow];
    self.container.layer.cornerRadius = 5;
    _consulationDoneCheckBox = [[BEMCheckBox alloc] initWithFrame:_consulationDoneContainer.bounds];
    _consulationDoneCheckBox.delegate = self;
    _consulationDoneCheckBox.boxType = BEMBoxTypeCircle;
    _consulationDoneCheckBox.onAnimationType = BEMAnimationTypeFill;
    _consulationDoneCheckBox.offAnimationType = BEMAnimationTypeFill;
    [_consulationDoneContainer addSubview:_consulationDoneCheckBox];
    _consulationDoneContainer.backgroundColor = [UIColor clearColor];
}

- (void)setAppointment:(Appointment *)appointment{
    _appointment = appointment;
    self.clinicNameLabel.text = appointment[@"clinic_name"];
    self.nameLabel.text = [appointment[@"other"] boolValue] ?appointment[@"other_name"] : appointment[@"name"];
    self.bookedByLabel.text = appointment[@"name"];
    self.mobileLabel.text = appointment[@"mobile_number"];
    self.timeLabel.text = [appointment startTime];
    self.dateLabel.text = [appointment appointmentDateString];
    self.consulationDoneCheckBox.on = [appointment[@"status"] boolValue];
    self.consulationDoneCheckBox.enabled = !self.consulationDoneCheckBox.on;
    self.consulationStatusLabel.text = [appointment[@"canceled"] boolValue] ? @"Canceled" : @"Pending";
    self.paymentStatusLabel.text = [appointment[@"fees"] integerValue] > 0 ? @"Pending" : @"Complete";
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:appointment.appointmentDate];
    BOOL shouldAllowConsultation = interval > 30 * 60;
    self.infoButton.enabled = ![appointment isOnline];
    self.infoIcon.alpha = ![appointment isOnline];
    
    self.videoCallButton.alpha = [appointment isOnline];
    self.videoCallIcon.alpha = [appointment isOnline];
    NSLog(@"%f", [appointment.appointmentDate timeIntervalSinceNow]);
    if ([appointment.appointmentDate timeIntervalSinceNow] > 30 * 60) {
        self.consulationDoneCheckBox.enabled = NO;
    }
    
    if ([appointment[@"status"] boolValue] ||
        [appointment.appointmentEndDate compare:[NSDate date]] == NSOrderedAscending ||
        [appointment[@"canceled"] boolValue]) {
        self.cancelButton.alpha = 0;
        self.changeButton.alpha = 0;
        self.startConsultationButton.alpha = 0;
        self.cancelButton.alpha = 0;
        self.actionBarHeight.constant = 0;
    }else{
        self.cancelButton.alpha = 1;
        self.changeButton.alpha = 1;
        self.startConsultationButton.alpha = [appointment isOnline];
        self.actionBarHeight.constant = 20;
    }
    
    
//    self.startConsultationButton.hidden = !appointment.allowConsultation;
    self.consulationDoneLabel.enabled = shouldAllowConsultation;
}

- (void)didTapCheckBox:(BEMCheckBox*)checkBox{
    if ([self.delegate respondsToSelector:@selector(markDoneAppointment:)]) {
        [self.delegate markDoneAppointment:self.appointment];
    }
}

- (IBAction)changeAppointmentTapped{
    if ([self.delegate respondsToSelector:@selector(editAppointment:)]) {
        [self.delegate editAppointment:self.appointment];
    }
}

- (IBAction)cancelAppointmentTapped{
    if ([self.delegate respondsToSelector:@selector(cancelAppointment:)]) {
        [self.delegate cancelAppointment:self.appointment];
    }
}

- (IBAction)startConsultationTapped{
    if ([self.delegate respondsToSelector:@selector(startConsultation:)]) {
        [self.delegate startConsultation:self.appointment];
    }
}

- (IBAction)infoTapped{
    if ([self.delegate respondsToSelector:@selector(infoTapped:)]) {
        [self.delegate infoTapped:self.appointment];
    }
}

@end
