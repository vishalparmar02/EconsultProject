//
//  PatientsListController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 22/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "PatientsListController.h"
#import "PatientInfoController.h"
#import "ReportsController.h"

@implementation PatientCell

- (void)setPatient:(Patient *)patient{
    _patient = patient;
    [self.patientImageView makeCircular];
    [self.patientImageView sd_setImageWithURL:patient.imageURL
                            placeholderImage:nil
                                     options:SDWebImageRefreshCached | SDWebImageProgressiveDownload
                                   completed:nil];
    self.titleLabel.text = patient.fullName;
    NSLog(@"%@ - %@", patient.fullName, patient.imageURL.description);
}

@end

@interface PatientsListController ()

@property (nonatomic, strong) NSArray           *patients;
@property (nonatomic, strong) IBOutlet  UITableView         *tableView;

@end

@implementation PatientsListController

+ (id)controller{
    return ControllerFromStoryBoard(@"Slot", [self description]);
}

+ (id)navigationController{
    return [[UINavigationController alloc] initWithRootViewController:[self controller]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My Patients";
    
    if ([[CUser currentUser] isDoctor]) {
        [self fetchPatients];
    }else{
        [self fetchMyPatients];
    }
}

- (void)fetchPatients{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [Patient fetchPatientsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.patients = [objects sortedArrayUsingSelector:@selector(compare:)];
        [self.tableView reloadData];
    }];
}

- (void)fetchMyPatients{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[CUser currentUser] fetchMyPatientsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.patients = [objects sortedArrayUsingSelector:@selector(compare:)];
        [self.tableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.patients.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PatientCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PatientCell"
                                                       forIndexPath:indexPath];
    cell.patient = self.patients[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([[CUser currentUser] isPatient]) {
        ReportsController *vc = [ReportsController controller];
        vc.patient = self.patients[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        PatientInfoController *vc = [PatientInfoController controller];
        vc.patient = self.patients[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
