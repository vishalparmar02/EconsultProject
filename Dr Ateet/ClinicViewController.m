//
//  ClinicViewController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 08/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "ClinicViewController.h"

@interface ClinicViewController ()

@end

@implementation ClinicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.clinic) {
        self.title = self.clinic[@"clinic_name"];
    }else{
        self.title = @"Add Clinic";
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(saveTapped)];
    
    [self initializeForm];
}

- (void)initializeForm {
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    if (self.clinic) {
        form = [XLFormDescriptor formDescriptorWithTitle:@"Modify Clinic"];
    }else{
        form = [XLFormDescriptor formDescriptorWithTitle:@"Add Clinic"];
    }
    
    
    // First section
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    UIFont *font = [UIFont fontWithName:@"Roboto-Medium" size:16];
    UIFont *detailFont = [UIFont fontWithName:@"Roboto-Regular" size:14];
    
    // Clinic Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"clinic_name"
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:@"Clinic Name"];
    [row.cellConfigAtConfigure setObject:@"Clinic Name" forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textField.font"];
    if (self.clinic)row.value = self.clinic[row.tag];
    [section addFormRow:row];
    
    // Building/Block
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"address"
                                                rowType:XLFormRowDescriptorTypeTextView
                                                   title:@"Address"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textView.textAlignment"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textView.font"];
    
    if (self.clinic)row.value = self.clinic[row.tag];
    [section addFormRow:row];
    
    // Landmark
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"landmark"
//                                                rowType:XLFormRowDescriptorTypeText
//                                                  title:@"Landmark"];
//    [row.cellConfigAtConfigure setObject:@"Landmark" forKey:@"textField.placeholder"];
//    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
//    [row.cellConfig setObject:font forKey:@"textLabel.font"];
//    [row.cellConfig setObject:detailFont forKey:@"textField.font"];
//    if (self.clinic)row.value = self.clinic[row.tag];
//    [section addFormRow:row];
    
    // City
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"city"
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:@"City"];
    [row.cellConfigAtConfigure setObject:@"City" forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textField.font"];
    if (self.clinic)row.value = self.clinic[row.tag];
    [section addFormRow:row];
    
    // State
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"state"
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:@"State"];
    [row.cellConfigAtConfigure setObject:@"State" forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textField.font"];
    if (self.clinic)row.value = self.clinic[row.tag];
    [section addFormRow:row];
    
    // Country
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"country"
                                                rowType:XLFormRowDescriptorTypeText
                                                  title:@"Country"];
    [row.cellConfigAtConfigure setObject:@"e.g. India" forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textField.font"];
    [section addFormRow:row];
    if (self.clinic)row.value = self.clinic[row.tag];
    
    // Pin Code
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"pincode"
                                                rowType:XLFormRowDescriptorTypeZipCode
                                                  title:@"Pincode"];
    [row.cellConfigAtConfigure setObject:@"Pin Code" forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textField.font"];
    if (self.clinic)row.value = self.clinic[row.tag];
    [section addFormRow:row];
    
    // Phone Number
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"contact_number"
                                                rowType:XLFormRowDescriptorTypePhone
                                                  title:@"Phone Number"];
    [row.cellConfigAtConfigure setObject:@"Phone Number" forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textField.font"];
    [section addFormRow:row];
    if (self.clinic)row.value = self.clinic[row.tag];
    
    self.form = form;
}

- (void)saveTapped{
    if (self.clinic) {
        [self updateClinic];
    }else{
        [self addNewClinic];
    }
    NSLog(@"%@", [self.form.formValues description]);
}

- (void)addNewClinic{
    Clinic *aClinic = [Clinic new];
    aClinic[@"save"] = self.form.formValues;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [aClinic saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error) {
            [UIAlertController showAlertInViewController:self
                                               withTitle:@"Error"
                                                 message:@"Please retry"
                                       cancelButtonTitle:@"OK"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:nil
                                                tapBlock:nil];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)updateClinic{
    self.clinic[@"update"] = self.form.formValues;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.clinic updateInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error) {
            [UIAlertController showAlertInViewController:self
                                               withTitle:@"Error"
                                                 message:@"Please retry"
                                       cancelButtonTitle:@"OK"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:nil
                                                tapBlock:nil];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

@end
