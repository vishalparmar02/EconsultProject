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
    self.titleLabel.text = [NSString stringWithFormat:@"%@ (%@)", patient.fullName, patient[@"mobile_number"]];;
    NSLog(@"%@ - %@", patient.fullName, patient.imageURL.description);
}

@end

@interface PatientsListController ()

@property (nonatomic, strong) NSArray           *allPatients;
@property (nonatomic, strong) NSMutableArray    *patients;

@property (nonatomic, strong)   IBOutlet        UITableView     *tableView;
@property (nonatomic, strong)   IBOutlet        UISearchBar     *searchBar;

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
    
    
    if ([[CUser currentUser] isDoctor]) {
        self.title = @"My Patients";
        [self fetchPatients];
    }else if ([[CUser currentUser] isStaff]) {
        self.title = @"Patients";
        [self fetchPatients];
    }else{
        self.title = @"Select Patient";
        [self fetchMyPatients];
    }
}

- (void)fetchPatients{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [Patient fetchPatientsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.allPatients = [objects sortedArrayUsingSelector:@selector(compare:)];
        self.patients = self.allPatients.mutableCopy;
        [self.tableView reloadData];
    }];
}

- (void)fetchMyPatients{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[CUser currentUser] fetchMyPatientsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.allPatients = [objects sortedArrayUsingSelector:@selector(compare:)];
        self.patients = self.allPatients.mutableCopy;
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
        vc.isChild = YES;
        vc.patient = self.patients[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        PatientInfoController *vc = [PatientInfoController controller];
        vc.patient = self.patients[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    for (Patient *aPatient in self.allPatients) {
        if ([aPatient matches:searchText]) {
            if (![self.patients containsObject:aPatient]) {
                [self.patients addObject:aPatient];
            }
        }else{
            if ([self.patients containsObject:aPatient]){
                [self.patients removeObject:aPatient];
            }
        }
    }
    [self.patients sortUsingSelector:@selector(compare:)];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    searchBar.text = nil;
    self.patients = self.allPatients.mutableCopy;
    [self.tableView reloadData];
}

@end
