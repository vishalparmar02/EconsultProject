//
//  PatientAppointmentsController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 24/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "PatientAppointmentsController.h"
#import "Appointment.h"
#import "AppointmentCell.h"
#import "ARTCVideoChatViewController.h"
#import "PubNubManager.h"
#import "CallController.h"

@interface PatientAppointmentsController ()<AppointmentCellDelegate>

@property (nonatomic, strong) NSArray   *appointments, *pastAppointments, *upcomingAppointments;
@property (nonatomic, strong) IBOutlet  UITableView   *tableView;
@property (nonatomic, strong) IBOutlet  UISegmentedControl  *appointmentTypeSegment;

@end

@implementation PatientAppointmentsController

+ (PatientAppointmentsController*)controller{
    return ControllerFromStoryBoard(@"Appointments", @"PatientAppointmentsController");
}

+ (PatientAppointmentsController*)consultationLogController{
    return ControllerFromStoryBoard(@"Appointments", @"ConsultationLog");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appointmentTypeSegment.alpha = !self.consultation;
    self.edgesForExtendedLayout=UIRectEdgeNone;
    if (self.isChild && self.navigationController.isBeingPresented) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                                 style:UIBarButtonItemStyleDone
                                                                                target:self
                                                                                action:@selector(doneTapped)];
    }
    if (self.bookedOnly) {
        self.title = @"Consultation Log";
    }
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
    if (self.bookedOnly) {
        [self fetchBookedAppointments];
    }else{
        [self fetchAppointments];
    }
}

- (void)doneTapped{
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}

- (void)fetchAppointments{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [Appointment fetchAppointmentsForPatientInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSMutableArray *pastAppointments = [NSMutableArray array];
        NSMutableArray *upcomingAppointments = [NSMutableArray array];
        for (Appointment *appointment in objects) {
            if ([appointment hasPassed]) {
                [pastAppointments addObject:appointment];
            }else{
                [upcomingAppointments addObject:appointment];
            }
        }
        self.upcomingAppointments = upcomingAppointments;
        self.pastAppointments = pastAppointments;
        
        if (self.consultation) {
            NSMutableArray *validAppointments = [NSMutableArray array];
            for (Appointment *anAppointment in objects) {
                NSLog(anAppointment.appointmentDate.description);
                if(![anAppointment[@"canceled"] boolValue] &&
                   ([anAppointment isOnToday] || [anAppointment isInFuture]) &&
                   [anAppointment isOnline]){
                    [validAppointments addObject:anAppointment];
                }
            }
            self.appointments = validAppointments;
        }else{
            if (_appointmentTypeSegment.selectedSegmentIndex == 0) {
                self.appointments = self.upcomingAppointments;
            }else{
                self.appointments = self.pastAppointments;
            }
        }
        
        [self.tableView reloadData];
    }];
}

- (IBAction)appointmentTypeChanged{
    if (_appointmentTypeSegment.selectedSegmentIndex == 0) {
        self.appointments = self.upcomingAppointments;
    }else{
        self.appointments = self.pastAppointments;
    }
    [self.tableView reloadData];
}

- (void)fetchBookedAppointments{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.patient fetchBookedAppointmentsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.appointments = objects;
        [self.tableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.appointments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = self.bookedOnly ? @"ConsultationLogCell" : (self.consultation ? @"ConsultationCell" : @"AppointmentCell");
    AppointmentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier
                                                            forIndexPath:indexPath];
    cell.appointment = self.appointments[indexPath.row];
//    cell.startConsultationButton.alpha = self.consultation;
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.bookedOnly ? 50 : (self.consultation ? 230 : 170);
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.consultation) return;
    
    Appointment *appointment = self.appointments[indexPath.row];
    if ([[appointment[@"clinic_name"] lowercaseString] isEqualToString:@"online"]){
        [self startConsultation:appointment];
    }
    //    PatientInfoController *vc = [PatientInfoController controller];
    //    vc.patient = self.patients[indexPath.row];
    //    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cancelAppointment:(Appointment*)appointment{
    CGFloat cancellationTime = 2 * 24 * 60 * 60;
    
    if ([appointment.appointmentDate timeIntervalSinceDate:[NSDate date]] < cancellationTime) {
        [UIAlertController showAlertInViewController:self
                                           withTitle:@"Info"
                                             message:@"You can only cancel appointment before 48 hours of appointment time"
                                   cancelButtonTitle:nil
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@[@"OK"]
                                            tapBlock:nil];
        
        return;
    }
    
    [UIAlertController showAlertInViewController:self
                                       withTitle:@""
                                         message:@"Are you sure you want to cancel this appointment?"
                               cancelButtonTitle:nil
                          destructiveButtonTitle:@"No"
                               otherButtonTitles:@[@"Yes"]
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            if (buttonIndex == 2) {
                                                [self confirmCancelAppointment:appointment];
                                            }
                                        }];
    
    
}

- (void)infoTapped:(Appointment*)appointment{
    NSDictionary *address = appointment[@"address"];
    NSString *addressString = [NSString stringWithFormat:@"%@, %@\n Contact Number: %@", address[@"address"],
                               address[@"city"], address[@"contact_number"]];
    [UIAlertController showAlertInViewController:self
                                       withTitle:appointment[@"clinic_name"]  
                                         message:addressString
                               cancelButtonTitle:@"OK"
                          destructiveButtonTitle:nil
                               otherButtonTitles:nil
                                        tapBlock:nil];
}

- (void)startConsultation:(Appointment*)appointment{
    if (![appointment allowConsultation]) {
        [UIAlertController showAlertInViewController:self
                                           withTitle:@""
                                             message:@"Online consultation will be activated 5 minutes prior to the appointment time." cancelButtonTitle:@"Ok"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:nil
                                            tapBlock:nil];
        return;
    }
    NSNumber *senderID = [[CUser currentUser] isPatient] ? [CUser currentUser][@"patient_id"] : @-1;
    NSString *calleeChannel = [NSString stringWithFormat:@"patient_%@", [appointment[@"patient_id"] stringValue]];
    
    NSString *roomID = [NSString stringWithFormat:@"room_%u", arc4random_uniform(999999)];
    NSString *callDescription = @"Dr. would like to start video consulation.";
    if ([[CUser currentUser] isPatient]) {
        NSString *patientName = [NSString stringWithFormat:@"%@ %@", [CUser currentUser][@"first_name"],
                                 [CUser currentUser][@"last_name"]];
        
        callDescription = [NSString stringWithFormat:@"%@ would like to start video consulation.", patientName];
    }
    
    NSDictionary *callDict = @{@"description" : callDescription,
                               @"is_initiator" : @1,
                               @"room_id" : roomID,
                               @"sender_id" : senderID,
                               @"type" : @"v_call",
                               @"channel" : calleeChannel,
                               @"caller" : [[CUser currentUser] fullName],
                               @"callee" : @"Dr."};
    [CallController sharedController].expectingCall = YES;
    [PubNubManager sendMessage:callDict toChannel:calleeChannel];
}

- (void)confirmCancelAppointment:(Appointment*)appointment{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [appointment deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self fetchAppointments];
    }];
}

@end
