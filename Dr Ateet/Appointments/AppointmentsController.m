//
//  AppointmentsController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 30/05/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "AppointmentsController.h"
#import "BookAppointmentController.h"
#import "PubNubManager.h"
#include <stdlib.h>
#import "CallController.h"

@interface AppointmentsController () <JTCalendarDelegate, AppointmentCellDelegate> {
    NSMutableDictionary *_eventsByDate;
    
    NSDate *_todayDate;
    NSDate *_minDate;
    NSDate *_maxDate;
    
    NSDate *_dateSelected;
}

@property (nonatomic, strong) NSArray   *appointments;
@property (nonatomic, strong) IBOutlet UITableView   *tableView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint   *tableTopSpace;
@property (nonatomic, strong) IBOutlet UILabel              *noClashLabel;

@end

@implementation AppointmentsController

+ (AppointmentsController*)controller{
    AppointmentsController *vc = ControllerFromStoryBoard(@"Appointments", @"AppointmentsController");
    return vc;
}

+ (AppointmentsController*)clashingController{
    AppointmentsController *vc = ControllerFromStoryBoard(@"Appointments", @"ClashingAppointmentsController");
    vc.isChild = NO;
    vc.clashing = YES;
    return vc;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if (!self.clashing) {
        self.title = @"Appointments";
        _calendarManager = [JTCalendarManager new];
        _calendarManager.delegate = self;
        
        [self createMinAndMaxDate];
        
        [_calendarManager setMenuView:_calendarMenuView];
        [_calendarManager setContentView:_calendarContentView];
        [_calendarManager setDate:_todayDate];
    }else{
        self.title = @"Clashing Appointments";
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self fetchAppointments];
}

- (void)fetchAppointments{
    if(self.clashing){
        [self fetchConflictingAppointments];
    }else{
        [self fetchAppointments:_dateSelected];
    }
}

#pragma mark - Buttons callback

- (IBAction)didGoTodayTouch
{
    [_calendarManager setDate:_todayDate];
}

- (IBAction)didChangeModeTouch
{
    _calendarManager.settings.weekModeEnabled = !_calendarManager.settings.weekModeEnabled;
    [_calendarManager reload];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat newHeight = 300;
        if(_calendarManager.settings.weekModeEnabled){
            newHeight = 85.;
        }
        self.calendarContentViewHeight.constant = newHeight;
    }];
    
    [self.view layoutIfNeeded];
}

#pragma mark - CalendarManager delegate

// Exemple of implementation of prepareDayView method
// Used to customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    // Today
    if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor blueColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Selected date
    else if(_dateSelected && [_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor redColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Other month
    else if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor lightGrayColor];
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor blackColor];
    }
    
    if([self haveEventForDay:dayView.date]){
        dayView.dotView.hidden = NO;
    }
    else{
        dayView.dotView.hidden = YES;
    }
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    _dateSelected = dayView.date;
    
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
                        dayView.circleView.transform = CGAffineTransformIdentity;
                        [_calendarManager reload];
                        [self fetchAppointments];
                    } completion:nil];
    
    
    // Don't change page in week mode because block the selection of days in first and last weeks of the month
    if(_calendarManager.settings.weekModeEnabled){
        return;
    }
    
    // Load the previous or next page if touch a day from another month
    
    if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        if([_calendarContentView.date compare:dayView.date] == NSOrderedAscending){
            [_calendarContentView loadNextPageWithAnimation];
        }
        else{
            [_calendarContentView loadPreviousPageWithAnimation];
        }
    }
}

#pragma mark - CalendarManager delegate - Page mangement

// Used to limit the date for the calendar, optional
- (BOOL)calendar:(JTCalendarManager *)calendar canDisplayPageWithDate:(NSDate *)date
{
    return [_calendarManager.dateHelper date:date isEqualOrAfter:_minDate andEqualOrBefore:_maxDate];
}

- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar
{
    //    NSLog(@"Next page loaded");
}

- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar
{
    //    NSLog(@"Previous page loaded");
}

#pragma mark - Fake data

- (void)createMinAndMaxDate
{
    _todayDate = [NSDate date];
    
    // Min date will be 2 month before today
    _minDate = [_calendarManager.dateHelper addToDate:_todayDate months:-2];
    
    // Max date will be 2 month after today
    _maxDate = [_calendarManager.dateHelper addToDate:_todayDate months:2];
}

// Used only to have a key for _eventsByDate
- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
}

- (BOOL)haveEventForDay:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(_eventsByDate[key] && [_eventsByDate[key] count] > 0){
        return YES;
    }
    
    return NO;
    
}

- (void)createRandomEvents
{
    _eventsByDate = [NSMutableDictionary new];
    
    for(int i = 0; i < 30; ++i){
        // Generate 30 random dates between now and 60 days later
        NSDate *randomDate = [NSDate dateWithTimeInterval:(rand() % (3600 * 24 * 60)) sinceDate:[NSDate date]];
        
        // Use the date as key for eventsByDate
        NSString *key = [[self dateFormatter] stringFromDate:randomDate];
        
        if(!_eventsByDate[key]){
            _eventsByDate[key] = [NSMutableArray new];
        }
        
        [_eventsByDate[key] addObject:randomDate];
    }
}

- (void)collapse{
    _calendarManager.settings.weekModeEnabled = !_calendarManager.settings.weekModeEnabled;
    _calendarManager.settings.weekModeEnabled = YES;
    [_calendarManager reload];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat newHeight = 300;
        if(_calendarManager.settings.weekModeEnabled){
            newHeight = 85.;
            self.tableTopSpace.constant = -215;
        }
        self.calendarContentViewHeight.constant = newHeight;
    }];
    
    [self.view layoutIfNeeded];
}

- (void)fetchConflictingAppointments{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [Appointment fetchClashingAppointmentsBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self collapse];
        self.appointments = objects;
        self.noClashLabel.alpha = objects.count == 0;
        [self.tableView reloadData];
    }];
}

- (void)fetchAppointments:(NSDate*)date{
    if (!date) date = _todayDate;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [Appointment fetchAppointmentsForDate:date
                    inBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [self collapse];
                        self.appointments = objects;
                        [self.tableView reloadData];
                    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.appointments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = self.clashing ? @"ClashingAppointmentCell" : @"AppointmentCell";
    AppointmentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier
                                                            forIndexPath:indexPath];
    cell.appointment = self.appointments[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 200;
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView
           willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[CUser currentUser] isDoctor] ? indexPath : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.clashing) return;
    
    NSNumber *senderID = [[CUser currentUser] isPatient] ? [CUser currentUser][@"patient_id"] : @-1;
    Appointment *appointment = self.appointments[indexPath.row];
    if ([[appointment[@"clinic_name"] lowercaseString] isEqualToString:@"online"]){
        NSString *calleeChannel = [NSString stringWithFormat:@"patient_%@", [appointment[@"patient_id"] stringValue]];
        
        NSString *roomID = [NSString stringWithFormat:@"room_%u", arc4random_uniform(999999)];
        NSString *callDescription = @"Dr. would like to start video call.";
        if ([[CUser currentUser] isPatient]) {
            NSString *patientName = [NSString stringWithFormat:@"%@ %@", [CUser currentUser][@"first_name"],
                                     [CUser currentUser][@"last_name"]];
            
            callDescription = [NSString stringWithFormat:@"%@ would like to start video call.", patientName];
        }
        
        NSDictionary *callDict = @{@"description" : callDescription,
                                   @"is_initiator" : @1,
                                   @"room_id" : roomID,
                                   @"sender_id" : senderID,
                                   @"type" : @"v_call",
                                   @"channel" : calleeChannel,
                                   @"caller" : @"Dr.",
                                   @"callee" : appointment[@"name"]};
        
        [CallController sharedController].expectingCall = YES;
        [PubNubManager sendMessage:callDict toChannel:calleeChannel];
    }
}

- (void)editAppointment:(Appointment*)appointment{
    BookAppointmentController *vc =[BookAppointmentController controller];
    vc.appointment = appointment;
    vc.isChild = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cancelAppointment:(Appointment*)appointment{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"Are you sure you want to cancel this appointment?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    __block UITextField *reasonField;
    if([[CUser currentUser] isDoctor]){
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            reasonField = textField;
            textField.placeholder = @"Reason? (Optional)";
        }];
    }
    
    
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"No"
                                                 style:UIAlertActionStyleDestructive
                                               handler:nil];
    
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes"
                                                 style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    appointment[@"reason"] = reasonField.text.length ? reasonField.text : @"";
                                                    [self confirmCancelAppointment:appointment];
                                                }];
    
    [alert addAction:no];
    [alert addAction:yes];
    
    [self presentViewController:alert animated:YES completion:nil];
}
//
//- (void)startConsultation:(Appointment*)appointment{
//    ARTCVideoChatViewController *vc = [ARTCVideoChatViewController controller];
//    NSString *patientID = [CUser currentUser][@"patient_id"];
//    NSString *roomName = [NSString stringWithFormat:@"Doctor_Patient_%@", patientID];
//    [vc setRoomName:roomName];
//    
//    [self.navigationController pushViewController:vc
//                                         animated:YES];
//    
//    
//}

- (void)confirmCancelAppointment:(Appointment*)appointment{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [appointment deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (succeeded) {
            [self fetchAppointments];
            [UIAlertController showAlertInViewController:self
                                               withTitle:@""
                                                 message:@"Appointment cancelled successfully"
                                       cancelButtonTitle:@"OK"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:nil
                                                tapBlock:nil];
        }else{
            [UIAlertController showAlertInViewController:self
                                               withTitle:@""
                                                 message:@"Error in cancellation. Please retry."
                                       cancelButtonTitle:@"OK"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:nil
                                                tapBlock:nil];
        }
        
    }];
}

- (void)startConsultation:(Appointment*)appointment{
    [appointment startConsultation];
}

- (void)markDoneAppointment:(Appointment*)appointment{
    if (![appointment[@"status"] boolValue]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [appointment markDoneInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self fetchAppointments];
        }];
    }
}


@end
