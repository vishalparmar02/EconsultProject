//
//  PatientAppointmentsController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 24/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "BaseController.h"
#import "Patient.h"

@interface PatientAppointmentsController : BaseController

@property (nonatomic)           BOOL        bookedOnly, child, consultation;
@property (nonatomic, strong)   Patient     *patient;

+ (PatientAppointmentsController*)consultationLogController;

@end
