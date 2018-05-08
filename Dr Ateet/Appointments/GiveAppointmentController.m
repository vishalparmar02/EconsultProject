//
//  GiveAppointmentController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 24/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "GiveAppointmentController.h"
#import "UIPickerView+Blocks.h"
#import "Clinic.h"
#import <UIAlertController+Blocks/UIAlertController+Blocks.h>

@interface GiveAppointmentController ()<UITextFieldDelegate>

@property (nonatomic, strong)   IBOutlet    UITextField     *dateField;
@property (nonatomic, strong)   IBOutlet    UITextField     *clinicField;
@property (nonatomic, strong)   IBOutlet    UITextField     *patientNameField;
@property (nonatomic, strong)   NSArray     *clinics, *slots;
@property (nonatomic, strong)   UIPickerView    *clinicPicker;
@property (nonatomic, strong)   UIDatePicker    *datePicker;
@property (nonatomic, strong)   Clinic          *selectedClinic;
@property (nonatomic, strong)   IBOutlet    UICollectionView    *collectionView;
@property (nonatomic, strong)   IBOutlet    UILabel *noAppointmentLabel;
@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint  *appointmentForHeight;
@property (nonatomic, strong)               UITextField         *timeField;
@property (nonatomic, strong)               UIDatePicker        *timePicker;

@end

@implementation GiveAppointmentController

+ (GiveAppointmentController*)controller{
    return ControllerFromStoryBoard(@"Appointments", @"GiveAppointmentController");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.title = @"Give Appointment";
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    layout.minimumLineSpacing = 0.0;
    layout.minimumInteritemSpacing = 0.0;
    self.collectionView.collectionViewLayout = layout;
    self.patientNameField.text = [NSString stringWithFormat:@"Patient Name: %@", self.patient.fullName];
    
    [self fetchClinics];
}

- (void)doneTapped{
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}

- (void)fetchClinics{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [Clinic fetchClinicsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        NSMutableArray *clinics = [NSMutableArray array];
        for (Clinic *aClinic in objects){
            if (![[aClinic[@"clinic_name"] lowercaseString] isEqualToString:@"online"]) {
                [clinics addObject:aClinic];
            }
        }
        self.clinics = clinics;
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (self.dateField == textField) {
        [self dateChanged];
    }else{
        if (!self.selectedClinic) {
            self.selectedClinic = self.clinics[0];
            [self.clinicPicker selectRow:0 inComponent:0 animated:NO];
            self.clinicField.text = self.selectedClinic[@"clinic_name"];
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self tryToFetchSlots];
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
    if (self.dateField.text == nil || self.selectedClinic == nil) {
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

#pragma mark UICollectionView methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return section == 0 ? 1 : self.slots.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        UICollectionViewCell *addCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddSlotCell" forIndexPath:indexPath];
        return addCell;
    }
    SlotCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SlotCell" forIndexPath:indexPath];
    cell.date = self.datePicker.date;
    cell.slot = self.slots[indexPath.row];
    
    NSLog(@"%@",_slots);
    
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(indexPath.section == 0 ? collectionView.frame.size.width : kSlotCellWidth, 50);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        [self addSlotTapped];
        return;
    }
    
    Slot *slot = self.slots[indexPath.row];
    
    if ([slot[@"book"] boolValue] || [slot hasPassedForDate:self.datePicker.date]) {
        return;
    }
    
    NSDateFormatter *dateF = [NSDateFormatter new];
    [dateF setDateFormat:@"dd MMM, YYYY"];
    
    NSString *clinicText = @"Online";
    if (self.selectedClinic.objectId.integerValue != -1){
        clinicText = [NSString stringWithFormat:@"Walk In, %@", self.selectedClinic[@"clinic_name"]];
    }
    
    NSString *message = [NSString stringWithFormat:@"Patient:%@ \nDate: %@ \nTime: %@\nConsult Type: %@",
                         self.patient.fullName,
                         [dateF stringFromDate:self.datePicker.date],
                         [slot startTime],
                         clinicText];
    
    [UIAlertController showAlertInViewController:self
                                       withTitle:@"Confirm Booking"
                                         message:message
                               cancelButtonTitle:nil
                          destructiveButtonTitle:@"No"
                               otherButtonTitles:@[@"Yes"]
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            if (buttonIndex == 2) {
                                                [self bookSlot:slot];
                                            }
                                        }];
}

- (void)addSlotTapped{
    if (!self.selectedClinic) {
        [UIAlertController showAlertInViewController:self
                                           withTitle:@""
                                             message:@"Please select a clinic to add slot"
                                   cancelButtonTitle:@"OK"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:nil
                                            tapBlock:nil];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Start Time"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        self.timeField = textField;
        self.timePicker = [[UIDatePicker alloc] init];
        self.timePicker.datePickerMode = UIDatePickerModeTime;
        [self.timePicker addTarget:self action:@selector(slotTimeChanged) forControlEvents:UIControlEventValueChanged];
        textField.inputView = self.timePicker;
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                 style:UIAlertActionStyleDestructive
                                               handler:nil];
    
    UIAlertAction *OK = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
                                                   [self tryToAddSlot];
                                               }];
    [alert addAction:cancel];
    [alert addAction:OK];
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)tryToAddSlot{
    Slot *slot = [Slot new];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *appointmentDate = [dateFormatter stringFromDate:self.datePicker.date];
    dateFormatter.dateFormat = @"HH:mm:ss";
    NSString *appointmentTime = [dateFormatter stringFromDate:self.timePicker.date];
    
    slot[@"save"] = @{@"appointment_date" : appointmentDate,
                      @"open_time" : appointmentTime};
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [slot createInBackgroundWithBlock:^(NSDictionary *dictionary, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            dateFormatter.dateFormat = @"H:m:s";
            NSString *startTime = [dateFormatter stringFromDate:self.timePicker.date];
            Slot *aSlot = [[Slot alloc] initWithDictionary:@{@"id" : dictionary[@"slot_id"],
                                                             @"start_time" : startTime
                                                             }];
            [self bookSlot:aSlot];
        }else{
            [UIAlertController showAlertInViewController:self
                                               withTitle:nil
                                                 message:error.userInfo[@"message"]
                                       cancelButtonTitle:@"OK"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:nil
                                                tapBlock:nil];
        }
    }];
}

- (void)slotTimeChanged{
    NSDateFormatter *timeFormatter = [NSDateFormatter new];
    timeFormatter.dateFormat = @"hh:mm a";
    self.timeField.text = [timeFormatter stringFromDate:self.timePicker.date];
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
                              @"patient_id" : self.patient[@"patient_id"]};
    
    slot[@"save"] = details;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [slot bookInBackgroundWithBlock:^(NSDictionary *responseObject, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (responseObject) {
            NSDateFormatter *dateF = [NSDateFormatter new];
            [dateF setDateFormat:@"dd MMM, YYYY"];
            
            NSString *clinicText = @"Online";
            if (self.selectedClinic.objectId.integerValue != -1){
                clinicText = [NSString stringWithFormat:@"Walk In, %@", self.selectedClinic[@"clinic_name"]];
            }
            
            
            NSString *message = [NSString stringWithFormat:@"Appointment booked successfully on %@ at %@, %@", [dateF stringFromDate:self.datePicker.date],
                                 [slot startTime],
                                 clinicText];
            
            [UIAlertController showAlertInViewController:self
                                               withTitle:@""
                                                 message:message
                                       cancelButtonTitle:@"OK"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:nil
                                                tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                                    [self.navigationController popToRootViewControllerAnimated:YES];
                                       }];
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

@end
