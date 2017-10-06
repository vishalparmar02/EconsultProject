//
//  MenuController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 08/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "MenuController.h"
#import "AppDelegate.h"
#import "DoctorProfileController.h"
#import "DoctorProDetailsController.h"
#import "ClinicsListController.h"
#import "HomeController.h"
#import "ScheduleListController.h"
#import "CUser.h"
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/UIButton+WebCache.h>
#import "PatientProfileController.h"
#import "ReportsController.h"
#import "BookAppointmentController.h"
#import "PatientAppointmentsController.h"
#import "AppointmentsController.h"
#import "PatientSelectorController.h"
#import "PatientsListController.h"
#import "StaffListController.h"
#import "UIView+Theme.h"

@implementation SideMenuCell

- (void)setMenuText:(NSString*)text badge:(NSInteger)badge{
    self.badgeLabel.alpha = badge;
    self.badgeLabel.clipsToBounds = YES;
    [self.badgeLabel applyShadow];
    
    self.badgeLabel.text = [NSString stringWithFormat:@"%ld", badge];
    self.menuLabel.text = text;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat revealWidth = [ApplicationDelegate.drawerController revealWidthForDirection:MSDynamicsDrawerDirectionLeft];
    self.badgePaddingConstraint.constant = self.contentView.frame.size.width - revealWidth;
    self.badgeLabel.layer.cornerRadius = self.badgeLabel.frame.size.height / 2;
    self.badgeLabel.clipsToBounds = YES;
}

@end

@interface MenuController ()<UITableViewDataSource ,UITableViewDelegate>

@property (nonatomic, strong)   NSArray     *menu;
@property (nonatomic, strong)   IBOutlet    UITableView         *tableView;
@property (nonatomic, strong)   IBOutlet    UIButton            *profileButton;
@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint  *profileButtonCenterConstraint;
@property (nonatomic)                       NSInteger           conflictCount;

@end

@implementation MenuController

+ (id)controller{
    static MenuController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = ControllerFromMainStoryBoard([self description]);
    });
    return sharedInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reload];
}

- (void)reload{
    self.profileButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    NSURL *profileURLString = [[CUser currentUser] profileImageURL];
    [self.profileButton sd_setImageWithURL:profileURLString
                                  forState:UIControlStateNormal
                          placeholderImage:nil
                                   options:SDWebImageProgressiveDownload];
    
    if ([[CUser currentUser] isPatient]) {
//        self.menu = @[@[@"Home", @"Profile", @"Reports"],
//                      @[@"Book Appointment", @"My Appointments"],
//                      @[@"Logout"]];
        self.menu = @[@[@"Home", @"Book Appointment", @"My Appointments"],
                      @[@"Online Consultation", @"Reports", @"My Profile"],
                      @[@"About Dr. Ateet Sharma", @"Logout"]];
    }else{
        [self fetchConflictCount];
        self.menu = @[@[@"Home"],
                      @[@"Appointments", @"Give Appointment", @"Clashing Appointments"],
                      @[@"Patient Info", @"My Schedules", @"My Clinics", @"My Staff", @"Profile", @"Professional Profile"],
                      @[@"Logout"]];
    }
    [self.tableView reloadData];
}

- (void)fetchConflictCount{
    [Appointment fetchClashingAppointmentsBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.conflictCount = objects.count;
        [self.tableView reloadData];
    }];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.profileButton.backgroundColor = [UIColor whiteColor];
    self.profileButton.layer.cornerRadius = self.profileButton.frame.size.width / 2;
    //    [self.profileButton applyShadow];
    CGFloat revealWidth = [ApplicationDelegate.drawerController revealWidthForDirection:MSDynamicsDrawerDirectionLeft];
    self.profileButtonCenterConstraint.constant =  (revealWidth - self.view.frame.size.width) / 2;
}

- (void)homeTapped{
    [ApplicationDelegate.drawerController setPaneViewController:[HomeController navigationController]];
    [ApplicationDelegate.drawerController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:^{
        
    }];
}

- (void)profileTapped{
    if([[CUser currentUser] isDoctor]){
        [ApplicationDelegate.drawerController setPaneViewController:[DoctorProfileController navigationController]];
    }else{
        [ApplicationDelegate.drawerController setPaneViewController:[PatientProfileController navigationController]];
    }
    
    [ApplicationDelegate.drawerController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:^{
        
    }];
}

- (void)patientProfileTapped{
    [ApplicationDelegate.drawerController setPaneViewController:[PatientProfileController navigationController]];
    [ApplicationDelegate.drawerController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:^{
        
    }];
}

- (void)proDetailsTapped{
    [ApplicationDelegate.drawerController setPaneViewController:[DoctorProDetailsController navigationController]];
    [ApplicationDelegate.drawerController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:^{
        
    }];
}

- (void)myClinicsTapped{
    [ApplicationDelegate.drawerController setPaneViewController:[ClinicsListController navigationController]];
    [ApplicationDelegate.drawerController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:^{
        
    }];
}

- (void)myStaffTapped{
    [ApplicationDelegate.drawerController setPaneViewController:[StaffListController navigationController]];
    [ApplicationDelegate.drawerController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:^{

    }];
}

- (void)giveAppointmentTapped{
    [ApplicationDelegate.drawerController setPaneViewController:[PatientSelectorController navigationController]];
    [ApplicationDelegate.drawerController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:^{
        
    }];
}

- (void)appointmentsTapped{
    [ApplicationDelegate.drawerController setPaneViewController:[AppointmentsController navigationController]];
    [ApplicationDelegate.drawerController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:^{
        
    }];
}

- (void)clashingAppointmentTapped{
    AppointmentsController *vc = [AppointmentsController clashingController];
    UINavigationController *navVC = NavigationControllerWithController(vc);
    
    [ApplicationDelegate.drawerController setPaneViewController:navVC];
    [ApplicationDelegate.drawerController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:^{
        
    }];
}

- (void)patientInfoTapped{
    [ApplicationDelegate.drawerController setPaneViewController:[PatientsListController navigationController]];
    [ApplicationDelegate.drawerController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:^{
        
    }];
}

- (void)mySchedulesTapped{
    [ApplicationDelegate.drawerController setPaneViewController:[ScheduleListController navigationController]];
    [ApplicationDelegate.drawerController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:^{
        
    }];
}

- (void)reportsTapped{
    [ApplicationDelegate.drawerController setPaneViewController:[PatientsListController navigationController]];
    [ApplicationDelegate.drawerController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:^{
        
    }];
}

- (void)bookAppointmentTapped{
    [ApplicationDelegate.drawerController setPaneViewController:[BookAppointmentController navigationController]];
    [ApplicationDelegate.drawerController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:^{
        
    }];
}

- (void)myAppointmentsTapped{
    [ApplicationDelegate.drawerController setPaneViewController:[PatientAppointmentsController navigationController]];
    [ApplicationDelegate.drawerController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:^{
        
    }];
}

- (void)onlineConsultationTapped{
    PatientAppointmentsController *vc = [PatientAppointmentsController controller];
    vc.consultation = YES;
    UINavigationController *navVC = NavigationControllerWithController(vc);
    [ApplicationDelegate.drawerController setPaneViewController:navVC];
    [ApplicationDelegate.drawerController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:^{
        
    }];
}

- (void)aboutDoctorTapped{
    DoctorProfileController *vc = [DoctorProfileController fullProfileController];
    UINavigationController *navVC = NavigationControllerWithController(vc);
    [ApplicationDelegate.drawerController setPaneViewController:navVC];
    [ApplicationDelegate.drawerController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:NO completion:^{
        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_menu count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_menu[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SideMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SideMenuCell" forIndexPath:indexPath];
    NSArray *subMenu = _menu[indexPath.section];
    NSString *menuText = subMenu[indexPath.row];

    NSInteger badge = 0;
    if ([menuText isEqualToString:@"Clashing Appointments"]) {
        badge = self.conflictCount;
    }
    [cell setMenuText:menuText badge:badge];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[CUser currentUser] isPatient]) {
        [self patientMenuTapped:indexPath];
    }else{
        [self doctorMenuTapped:indexPath];
    }
}

- (void)patientMenuTapped:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                [self homeTapped];
                break;
            case 1:
                [self bookAppointmentTapped];
                break;
            case 2:
                [self myAppointmentsTapped];
                break;
                
            default:
                break;
        }
    }else if(indexPath.section == 1){
        switch (indexPath.row) {
            case 0:
                [self onlineConsultationTapped];
                break;
            case 1:
                [self reportsTapped];
                break;
            case 2:
                [self patientProfileTapped];
                break;
                
            default:
                break;
        }
    }else if(indexPath.section == 2){
        switch (indexPath.row) {
            case 0:
                [self aboutDoctorTapped];
                break;
            case 1:
                [CUser logOut];
                [ApplicationDelegate setController];
            default:
                break;
        }
    }
}

- (void)doctorMenuTapped:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                [self homeTapped];
                break;
            default:
                break;
        }
    }else if(indexPath.section == 1){
//        @[@"Appointments", @"Give Appointment", @"Clashing Appointments"]
        switch (indexPath.row) {
            case 0:
                [self appointmentsTapped];
                break;
            case 1:
                [self giveAppointmentTapped];
                break;
            case 2:
                [self clashingAppointmentTapped];
                break;
        }
    }else if (indexPath.section == 2){
//        @[@"Patient Info", @"My Schedules", @"My Clinics", @"My Staff", @"Profile", @"Professional Profile"]
        switch (indexPath.row) {
            case 0:
                [self patientInfoTapped];
                break;
            case 1:
                [self mySchedulesTapped];
                break;
            case 2:
                [self myClinicsTapped];
                break;
            case 3:
                [self myStaffTapped];
                break;
            case 4:
                [self profileTapped];
                break;
            case 5:
                [self proDetailsTapped];
                break;
                
            default:
                break;
        }
    }
    else if(indexPath.section == 3){
        [CUser logOut];
        [ApplicationDelegate setController];
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return nil;
    }
    
    CGFloat revealWidth = [ApplicationDelegate.drawerController revealWidthForDirection:MSDynamicsDrawerDirectionLeft];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, revealWidth, 10)];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 5, revealWidth - 20, 1)];
    line.backgroundColor = [UIColor grayColor];
    [header addSubview:line];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 10;
}

@end
