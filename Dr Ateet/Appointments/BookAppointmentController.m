//
//  BookAppointmentController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 24/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "BookAppointmentController.h"
#import "UIPickerView+Blocks.h"
#import "Clinic.h"
#import <UIAlertController+Blocks/UIAlertController+Blocks.h>
#import "Patient.h"
#import "CUser.h"
#import <SafariServices/SafariServices.h>

@interface BookAppointmentController ()<UITextFieldDelegate>

@property (nonatomic, strong)   IBOutlet    UITextField     *dateField;
@property (nonatomic, strong)   IBOutlet    UITextField     *clinicField;
@property (nonatomic, strong)   NSArray     *clinics, *slots;
@property (nonatomic, strong)   UIPickerView    *clinicPicker, *patientPicker;
@property (nonatomic, strong)   UIDatePicker    *datePicker;
@property (nonatomic, strong)   Clinic          *selectedClinic;
@property (nonatomic, strong)   Patient     *selectedPatient;
@property (nonatomic, strong)   NSString    *selectedMobileNumber;
@property (nonatomic, strong)   IBOutlet    UICollectionView    *collectionView;
@property (nonatomic, strong)   IBOutlet    UILabel *noAppointmentLabel;
@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint  *appointmentForHeight;
@property (nonatomic, strong)   IBOutlet    UITextField     *patientField;
@property (nonatomic, strong)   NSMutableArray  *patients;
@property (nonatomic, strong)   SFSafariViewController *paymentController;

@end

@implementation BookAppointmentController

+ (BookAppointmentController*)controller{
    return ControllerFromStoryBoard(@"Appointments", @"BookAppointmentController");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.patients = [NSMutableArray array];
    
    if (self.appointment) {
        self.title = @"Change Appointment";
        self.patientField.enabled = NO;
        self.patientField.text = self.appointment[@"name"];
    }else{
        self.title = @"Book Appointment";
        [self loadPatients];
    }
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    layout.minimumLineSpacing = 0.0;
    layout.minimumInteritemSpacing = 0.0;
    self.collectionView.collectionViewLayout = layout;
    
    [self fetchClinics];
}

- (void)doneTapped{
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}

- (void)fetchClinics{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [Clinic fetchClinicsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.clinics = objects;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self loadUI];
    }];
}

- (void)loadUI{
    self.datePicker = [[UIDatePicker alloc] init];
    [self.datePicker addTarget:self
                        action:@selector(dateChanged)
              forControlEvents:UIControlEventValueChanged];
    self.datePicker.minimumDate = [NSDate date];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.dateField.inputView = self.datePicker;
    self.dateField.delegate = self;
    
    NSMutableArray *clinicTitles = [NSMutableArray array];
    
    for (Clinic *aClinic in _clinics) {
        [clinicTitles addObject:aClinic[@"clinic_name"]];
    }
    
    self.clinicPicker = [[UIPickerView alloc] init];
    
    [self.clinicPicker setTitles:@[clinicTitles]];
    [self.clinicPicker handleSelectionWithBlock:^(UIPickerView *pickerView, NSInteger row, NSInteger component) {
        self.selectedClinic = self.clinics[row];
        self.clinicField.text = clinicTitles[row];
    }];
    
    self.clinicField.inputView = self.clinicPicker;
    self.clinicField.delegate = self;
    
    [self dateChanged];
    
}

- (void)loadPatientPicker{
//    [CUser currentUser]
    
    NSMutableArray *patientNames = [NSMutableArray array];
    
    for (Patient *aPatient in _patients) {
        [patientNames addObject:aPatient.fullName];
    }
    
    self.patientPicker = [[UIPickerView alloc] init];
    
    [self.patientPicker setTitles:@[patientNames]];
    [self.patientPicker handleSelectionWithBlock:^(UIPickerView *pickerView, NSInteger row, NSInteger component) {
        self.selectedPatient = self.patients[row];
        self.patientField.text = patientNames[row];
        
    }];
    self.patientField.inputView = self.patientPicker;
    self.patientField.delegate = self;
    
    if (!self.selectedPatient) {
        self.selectedPatient = self.patients[0];
        [self.patientPicker selectRow:0 inComponent:0 animated:NO];
        self.patientField.text = self.selectedPatient.fullName;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (self.dateField == textField) {
        [self dateChanged];
    }else if (self.clinicField == textField) {
        if (!self.selectedClinic) {
            self.selectedClinic = self.clinics[0];
            [self.clinicPicker selectRow:0 inComponent:0 animated:NO];
            self.clinicField.text = self.selectedClinic[@"clinic_name"];
        }
    }else if (self.patientField == textField) {
        if (!self.selectedPatient) {
            self.selectedPatient = self.patients[0];
            [self.patientPicker selectRow:0 inComponent:0 animated:NO];
            self.patientField.text = self.selectedPatient[@"name"];
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self tryToFetchSlots];
    if (textField == _patientField) {
        if ([self.selectedPatient[@"patient_id"] integerValue] == -1) {
            [self addPatient];
        }
    }
}

static NSDateFormatter *timeFormatter;

- (void)dateChanged{
    if(!timeFormatter){
        timeFormatter = [NSDateFormatter new];
        timeFormatter.dateFormat = @"dd LLL, yy";
    }
    
    self.dateField.text = [timeFormatter stringFromDate:self.datePicker.date];
}

- (void)tryToFetchSlots{
    if (self.dateField.text == nil || self.selectedClinic == nil || [self.selectedPatient[@"patient_id"] integerValue] == -1) {
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [Slot fetchSlotsForDate:self.datePicker.date
                     clinic:self.selectedClinic
      inBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
          [MBProgressHUD hideHUDForView:self.view animated:YES];
          self.slots = objects;
          self.noAppointmentLabel.alpha = !objects.count;
          self.collectionView.alpha = !self.noAppointmentLabel.alpha;
          [self.collectionView reloadData];
      }];
}

- (IBAction)addPatient{
    if (YES) {
       UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add New Patient" message:nil preferredStyle:UIAlertControllerStyleAlert];
        __block UITextField *firstNameField, *lastNameField, *mobileNumberField;
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            firstNameField = textField;
            textField.placeholder = @"First Name";
        }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            lastNameField = textField;
            textField.placeholder = @"Last Name";
        }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            mobileNumberField = textField;
            textField.placeholder = @"Country Code";
            textField.keyboardType = UIKeyboardTypePhonePad;
        }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            mobileNumberField = textField;
            textField.placeholder = @"Mobile Number";
            textField.keyboardType = UIKeyboardTypePhonePad;
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleDestructive
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [alert dismissViewControllerAnimated:YES
                                                                                   completion:nil];
                                                     }];
        
        [alert addAction:cancel];
        
        UIAlertAction *next = [UIAlertAction actionWithTitle:@"Add"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [self addPatient:firstNameField.text
                                                                         :lastNameField.text
                                                                         :mobileNumberField.text];
                                                     }];
        
        [alert addAction:next];
        [self presentViewController:alert
                           animated:YES
                         completion:nil];
    }
}

- (void)addPatient:(NSString*)firstName :(NSString*)lastName :(NSString*)mobile{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *patientDict = @{@"first_name" : firstName,
                                  @"last_name" : lastName,
                                  @"mobile_number" : mobile,
                                  @"users_id" : [CUser currentUser].objectId,
                                  @"role_id" : [CUser currentUser][@"role_id"]};
    typeof(self) __weak weakSelf = self;
    [Patient addPatient:patientDict inBackgroundWithBlock:^(NSDictionary * _Nullable object, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([object[@"status"] boolValue]) {
            self.selectedMobileNumber = mobile;
            [weakSelf loadPatients];
        }
    }];
}

- (void)loadPatients{
    [[CUser currentUser] fetchMyPatientsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self.patients removeAllObjects];
        
        for (Patient *aPatient in objects) {
            [self.patients addObject:aPatient];
        }
        
        [self.patients addObject:[Patient patientFromDictionary:@{@"name" : @"Add New Member",
                                                                  @"patient_id" : @-1}]];
        for (Patient *aPatient in self.patients) {
            if ([aPatient[@"mobile_number"] isEqualToString:self.selectedMobileNumber]) {
                self.selectedPatient = aPatient;
                break;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.patientField.text = self.selectedPatient.fullName;
            [self loadPatientPicker];
        });
    }];
    
}

- (void)checkOTP{
    
}

#pragma mark UICollectionView methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.slots.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SlotCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SlotCell" forIndexPath:indexPath];
    cell.date = self.datePicker.date;
    cell.slot = self.slots[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(kSlotCellWidth, 50);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    Slot *slot = self.slots[indexPath.row];
    
    if ([slot[@"book"] boolValue] || [slot hasPassedForDate:self.datePicker.date]) {
        return;
    }
    
    [UIAlertController showAlertInViewController:self
                                       withTitle:@""
                                         message:@"Are you sure you want to book this appointment?"
                               cancelButtonTitle:nil
                          destructiveButtonTitle:@"No"
                               otherButtonTitles:@[@"Yes"]
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            if (buttonIndex == 2) {
                                                if (self.appointment) {
                                                   [self updateSlot:slot];
                                                }else{
                                                    [self bookSlot:slot];
                                                }
                                            }
                                        }];
    
    
}

- (void)updateSlot:(Slot*)slot{
    NSDictionary *updateDict = @{@"id" : self.appointment.objectId,
                                 @"clinic_id" : self.selectedClinic.objectId,
                                 @"slot_id" : slot.objectId};
    self.appointment[@"update"] = updateDict;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.appointment updateInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)bookSlot:(Slot*)slot{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    NSDictionary *details = @{@"clinic_id" : self.selectedClinic.objectId,
                              @"appointment_date" : [dateFormatter stringFromDate:self.datePicker.date],
                              @"slot_id" : slot.objectId,
                              @"other" : @0,
                              @"other_f_name" : @"",
                              @"other_l_name" : @"",
                              @"other_contact_number" : @"",
                              @"users_id" : [CUser currentUser].objectId,
                              @"patient_id" : self.selectedPatient[@"patient_id"]};
    
    slot[@"save"] = details;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [slot bookInBackgroundWithBlock:^(NSDictionary *responseObject, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (responseObject) {
            if (self.selectedClinic.objectId.integerValue == -1) {
                [self payForOnlineAppointment:responseObject[@"appointment_id"]];
            }else{
                NSDateFormatter *dateF = [NSDateFormatter new];
                [dateF setDateFormat:@"dd MMM, YYYY"];
                
                NSString *clinicText = [NSString stringWithFormat:@"Walk In, %@", self.selectedClinic[@"clinic_name"]];
                
                NSString *message = [NSString stringWithFormat:@"Appointment booked successfully on %@ at %@, %@", [dateF stringFromDate:self.datePicker.date],
                                     [slot startTime],
                                     clinicText];
                [UIAlertController showAlertInViewController:self
                                                   withTitle:@""
                                                     message:message
                                           cancelButtonTitle:@"OK"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:nil
                                                    tapBlock:nil];
            }
            
            
        }else{
            [UIAlertController showAlertInViewController:self
                                               withTitle:@""
                                                 message:@"Error occurred."
                                       cancelButtonTitle:@"OK"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:nil
                                                tapBlock:nil];
        }
        [self tryToFetchSlots];
    }];
    
}

- (void)startPaymentStatusChecking:(NSString*)appointmentID{
    NSString *endPoint = [NSString stringWithFormat:GET_APPOINTMENT, appointmentID];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFJSONRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    [reqSerializer setValue:[CUser currentUser].authHeader forHTTPHeaderField:@"api-token"];
    NSString *URLString          = [API_BASE_URL stringByAppendingPathComponent:endPoint];
    NSMutableURLRequest *request = [reqSerializer requestWithMethod:@"GET"
                                                          URLString:URLString
                                                         parameters:nil
                                                              error:nil];
    //    NSLog(@"Dict: %@", [self[@"save"] description]);
    //    NSDictionary *dict = self[@"save"];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [error printHTMLError];
        } else {
            if ([responseObject[@"status"] boolValue]) {
                NSDictionary *appointmentDict = responseObject[@"data"];
                Appointment *appointment = [Appointment appointmentFromDictionary:appointmentDict];
                if (![appointment[@"paid"] boolValue]) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self startPaymentStatusChecking:appointmentID];
                    });
                }else{
                    [self.paymentController dismissViewControllerAnimated:YES completion:^{
                        NSDateFormatter *dateF = [NSDateFormatter new];
                        [dateF setDateFormat:@"dd MMM, YYYY"];
                        
                        NSString *clinicText = [NSString stringWithFormat:@"Walk In, %@", self.selectedClinic[@"clinic_name"]];
                        
                        NSString *message = [NSString stringWithFormat:@"Appointment booked successfully on %@ at %@, %@", [appointment appointmentDateString],
                                             [appointment startTime],
                                             clinicText];
                        [UIAlertController showAlertInViewController:self
                                                           withTitle:@""
                                                             message:message
                                                   cancelButtonTitle:@"OK"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:nil
                                                            tapBlock:nil];
                    }];
                }
            }
            
        }
    }];
    [dataTask resume];
}

- (void)payForOnlineAppointment:(NSString*)appointmentID{
    [self startPaymentStatusChecking:appointmentID];
    NSURL *paymentURL = [NSURL URLWithString:[NSString stringWithFormat:PAY_URL, appointmentID]];
    self.paymentController = [[SFSafariViewController alloc] initWithURL:paymentURL];
    [self.navigationController presentViewController:self.paymentController
                                            animated:YES
                                          completion:nil];
}

@end
