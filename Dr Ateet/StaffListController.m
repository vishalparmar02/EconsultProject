//
//  StaffListController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 04/10/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "StaffListController.h"
//#import "PatientInfoController.h"
//#import "ReportsController.h"

@implementation StaffCell

- (void)setStaff:(CUser *)staff{
    _staff = staff;
    [self.staffImageView makeCircular];
    [self.staffImageView sd_setImageWithURL:staff.profileImageURL
                             placeholderImage:nil
                                      options:SDWebImageRefreshCached | SDWebImageProgressiveDownload
                                    completed:nil];
    self.titleLabel.text = staff.fullName;
    self.descriptionLabel.text = staff[@"mobile_number"];
    NSLog(@"%@ - %@", staff.fullName, staff.profileImageURL.description);
}

@end

@interface StaffListController ()<UITextFieldDelegate>

@property (nonatomic, strong)           NSArray             *staff;
@property (nonatomic, strong) IBOutlet  UITableView         *tableView;
@property (nonatomic, strong)           UIAlertAction       *addAction;

@end

@implementation StaffListController

+ (id)controller{
    return ControllerFromStoryBoard(@"Main", [self description]);
}

+ (id)navigationController{
    return [[UINavigationController alloc] initWithRootViewController:[self controller]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My Staff";
    self.tableView.editing = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(addTapped)];
    [self fetchStaff];
}

- (void)fetchStaff{
    [[CUser currentUser] fetchMyStaffInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.staff = [objects sortedArrayUsingSelector:@selector(compare:)];
        [self.tableView reloadData];
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.tag == 100) {
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        self.addAction.enabled = newLength;
    }
    
    return YES;
}

- (void)addTapped{
    UIAlertController *alert=   [UIAlertController
                                 alertControllerWithTitle:@"Add Staff"
                                 message:@""
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    __block UITextField *fNameField, *lNameField, *mobileField;
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        fNameField = textField;
        textField.placeholder = @"First Name";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        lNameField = textField;
        textField.placeholder = @"Last Name";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        mobileField = textField;
//        textField.keyboardType = UIKeyboardTypePhonePad;
        textField.placeholder = @"Mobile Number";
        textField.delegate = self;
        textField.tag = 100;
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       
                                                   }];
    [alert addAction:cancel];
    
    self.addAction = [UIAlertAction actionWithTitle:@"Add"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    if (mobileField.text.length == 0) {
                                                        mobileField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Mobile Number"
                                                                                                                            attributes:@{NSForegroundColorAttributeName : [UIColor redColor]}];
                                                        return;
                                                    }
                                                    
                                                    if (fNameField.text == nil) {
                                                        fNameField.text = @"";
                                                    }
                                                    
                                                    if (lNameField.text == nil) {
                                                        lNameField.text = @"";
                                                    }
                                                    
                                                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                         
                                                    NSDictionary *staff = @{@"first_name" : fNameField.text,
                                                                            @"last_name" : lNameField.text,
                                                                            @"mobile_number" : mobileField.text,
                                                                            };
                                                    [[CUser currentUser] addStaff:staff withBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                        [self fetchStaff];
                                                    }];
                                                }];
    self.addAction.enabled = NO;
    [alert addAction:self.addAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.staff.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    StaffCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StaffCell"
                                                        forIndexPath:indexPath];
    cell.staff = self.staff[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    CUser *staffUser = self.staff[indexPath.row];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [staffUser deleteStaffInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self fetchStaff];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    if ([[CUser currentUser] isPatient]) {
//        ReportsController *vc = [ReportsController controller];
//        vc.patient = self.patients[indexPath.row];
//        [self.navigationController pushViewController:vc animated:YES];
//    }else{
//        PatientInfoController *vc = [PatientInfoController controller];
//        vc.patient = self.patients[indexPath.row];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
}

@end

