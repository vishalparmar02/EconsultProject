//
//  PatientInfoController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 22/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "PatientInfoController.h"
#import "ReportsController.h"
#import "PatientAppointmentsController.h"

@interface PatientInfoController ()

@property (nonatomic, strong)   NSArray     *fieldTitles, *fieldNames;
@property (nonatomic, strong)   IBOutlet    UITableView     *tableView;
@property (nonatomic, strong)   IBOutlet    UIButton        *reportsButton, *logButton;

@end

@implementation PatientInfoController

+ (id)controller{
    return ControllerFromStoryBoard(@"Slot", [self description]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.logButton applyShadow];
    [self.reportsButton applyShadow];
    
    self.logButton.layer.cornerRadius = 5;
    self.reportsButton.layer.cornerRadius = 5;
    
    [self.logButton addBorder];
    [self.reportsButton addBorder];
    
    self.tableView.tableHeaderView = self.reportsButton.superview.superview;
    
    self.title = self.patient.fullName;
    NSString *fieldTitlesString = @"Name,Mobile Number,Age,Weight,Gender,Email,Aadhar Number,Address,Country,State,City,Pin Code,Birth Date,Height,Reffered By";
    NSString *fieldNamesString = @"name,mobile_number,age,weight,gender,email_address,aadhar_number,address,country,state,city,pin_code,birth_date,height,refer_by";
    self.fieldNames = [fieldNamesString componentsSeparatedByString:@","];
    self.fieldTitles = [fieldTitlesString componentsSeparatedByString:@","];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fieldNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DetailCell"];
    }
    
    NSString *field = self.fieldNames[indexPath.row];
    NSString *fieldTitle = self.fieldTitles[indexPath.row];
    NSString *fieldValue = self.patient[field];
    
    cell.textLabel.text = fieldTitle;
    cell.detailTextLabel.text = fieldValue;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)logTapped{
    PatientAppointmentsController *vc = [PatientAppointmentsController consultationLogController];
    vc.bookedOnly = YES;
    vc.isChild = YES;
    vc.patient = self.patient;
    UINavigationController *navVC = NavigationControllerWithController(vc);
    [self.navigationController presentViewController:navVC
                                            animated:YES
                                          completion:nil];
}

- (IBAction)reportsTapped{
    ReportsController *vc = [ReportsController controller];
    vc.patientID = self.patient.objectId;
    vc.isChild = YES;
    UINavigationController *navVC = NavigationControllerWithController(vc);
    [self.navigationController presentViewController:navVC
                                            animated:YES
                                          completion:nil];
}


@end
