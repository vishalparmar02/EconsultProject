//
//  PatientSelectorController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 05/09/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "PatientSelectorController.h"
#import "Patient.h"
#import "GiveAppointmentController.h"

@interface PatientSelectorController ()<UISearchBarDelegate>

@property (nonatomic, strong)   NSArray     *patients;
@property (nonatomic, strong)   IBOutlet    UITableView     *tableView;
@property (nonatomic, strong)   IBOutlet    UISearchBar     *searchBar;

@end

@implementation PatientSelectorController

+ (PatientSelectorController*)controller{
    return ControllerFromStoryBoard(@"Appointments", @"PatientSelectorController");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"Search Patient";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"PatientCell"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add Patient"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(addPatientTapped)];
    [self fetchPatients];
}

- (void)fetchPatients{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [Patient fetchPatientsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.patients = [objects sortedArrayUsingSelector:@selector(compare:)];
        [self.tableView reloadData];
    }];
}


- (IBAction)addPatientTapped{
    if (YES) {
        [self.searchBar resignFirstResponder];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add New Patient" message:nil preferredStyle:UIAlertControllerStyleAlert];
        __block UITextField *firstNameField, *lastNameField, *countryCodeField, *mobileNumberField;
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            firstNameField = textField;
            textField.placeholder = @"First Name";
        }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            lastNameField = textField;
            textField.placeholder = @"Last Name";
        }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            countryCodeField = textField;
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
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                         [self addPatient:firstNameField.text
                                                                         :lastNameField.text
                                                                         :countryCodeField.text
                                                                         :mobileNumberField.text];
                                                     }];
        
        [alert addAction:next];
        [self presentViewController:alert
                           animated:YES
                         completion:nil];
    }
}

- (void)addPatient:(NSString*)firstName :(NSString*)lastName :(NSString*)countryCode :(NSString*)mobile{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *patientDict = @{@"first_name" : firstName,
                                  @"last_name" : lastName,
                                  @"mobile_number" : mobile,
                                  @"country_code" : countryCode,
                                  @"users_id" : [CUser currentUser].objectId,
                                  @"role_id" : [CUser currentUser][@"role_id"]};
    typeof(self) __weak weakSelf = self;
    [Patient addPatient:patientDict inBackgroundWithBlock:^(NSDictionary * _Nullable object, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([object[@"status"] boolValue]) {
            self.searchBar.text = mobile;
            [weakSelf searchBar:self.searchBar textDidChange:self.searchBar.text];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.patients.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PatientCell"
                                                            forIndexPath:indexPath];
    Patient *patient = self.patients[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", patient.fullName, patient[@"mobile_number"]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Patient *patient = self.patients[indexPath.row];
    GiveAppointmentController *vc = [GiveAppointmentController controller];
    vc.patient = patient;
    vc.isChild = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length > 2) {
        [Patient searchPatientsFor:searchText.lowercaseString
             inBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                 self.patients = objects;
                 [self.tableView reloadData];
             }];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    searchBar.text = nil;
    [self fetchPatients];
}

@end
