//
//  ScheduleListController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 09/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "ScheduleListController.h"
#import "AddScheduleController.h"

@implementation ScheduleCell

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.container applyShadow];
    [self.container addBorder];
    self.container.layer.cornerRadius = 5;
}

- (void)setSchedule:(Schedule *)schedule{
    _schedule = schedule;
    
    self.scheduleNameLabel.text = [schedule time];
    self.monthsDetailsLabel.text = [schedule repeatMonthsString];
    self.monthsDetailsHeight.constant = [schedule heightForRepeatMonths];
    self.detailsHeight.constant = [schedule heightForRepeatString];
    self.scheduleDetailsLabel.text = [schedule repeatString];
    self.timePerPatientLabel.text = [schedule timePerPatient];
    self.detailsHeight.constant = [schedule heightForRepeatString];
    
//    NSString *address = schedule[@"address"];
//    NSString *city = schedule[@"city"];
//    NSString *state = schedule[@"state"];
//    NSString *contactNumber = schedule[@"contact_number"];
//    
//    NSMutableArray *components = [NSMutableArray array];
//    if (address.length) [components addObject:address];
//    if (city.length) [components addObject:city];
//    if (state.length) [components addObject:state];
//    if (contactNumber.length) [components addObject:contactNumber];
//    
//    self.scheduleDetailsField.text = [components componentsJoinedByString:@"\n"];
}

- (IBAction)deleteTapped{
    if ([self.delegate respondsToSelector:@selector(deleteSchedule:)]) {
        [self.delegate deleteSchedule:self.schedule];
    }
}

@end

@interface ScheduleListController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet  UITableView         *tableView;
@property (nonatomic, strong)           NSDictionary        *schedules, *allSchedules;
@property (nonatomic, strong)           NSArray             *clinicNames;

@end

@implementation ScheduleListController

+ (id)controller{
    return ControllerFromStoryBoard(@"Slot", [self description]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"My Schedules";
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add"
//                                                                  style:UIBarButtonItemStylePlain
//                                                                 target:self
//                                                                 action:@selector(addScheduleTapped:)];
//    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewWillAppear:(BOOL)animated{
    [self fetchSchedules];
}

- (void)fetchSchedules{
    [Schedule fetchSchedulesInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        NSMutableDictionary *schedules = [NSMutableDictionary dictionary];
        NSMutableDictionary *allSchedules = [NSMutableDictionary dictionary];
        for (Schedule *aSchedule in objects) {
            NSString *clinicName = aSchedule[@"clinic_name"];
            NSMutableArray *clinicSchedules = schedules[clinicName];
            NSMutableArray *allClinicSchedules = allSchedules[clinicName];
            if (!clinicSchedules) {
                clinicSchedules = [NSMutableArray array];
                allClinicSchedules = [NSMutableArray array];
                schedules[clinicName] = clinicSchedules;
                allSchedules[clinicName] = allClinicSchedules;
            }
            if([aSchedule[@"open_time"] length] != 0){
                [clinicSchedules addObject:aSchedule];
            }
            [allClinicSchedules addObject:aSchedule];
        }
        self.schedules = schedules;
        self.allSchedules = allSchedules;
        self.clinicNames = [self.schedules.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            if ([obj1.lowercaseString isEqualToString:@"online"]) return NSOrderedAscending;
            if ([obj2.lowercaseString isEqualToString:@"online"]) return NSOrderedDescending;
            return [obj1 compare:obj2];
        }];
        
        for (NSString *clinicName in self.clinicNames) {
            NSMutableArray *clinicSchedules = self.schedules[clinicName];
            [clinicSchedules sortUsingSelector:@selector(compare:)];
            
            NSMutableArray *allClinicSchedules = self.allSchedules[clinicName];
            [allClinicSchedules sortUsingSelector:@selector(compare:)];
        }
        
        [self.tableView reloadData];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.clinicNames.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *clinicName = self.clinicNames[section];
    NSArray *clinicSchedules = self.schedules[clinicName];
    return clinicSchedules.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *clinicName = self.clinicNames[indexPath.section];
    NSArray *clinicSchedules = self.schedules[clinicName];
    
    ScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScheduleCell"
                                                       forIndexPath:indexPath];
    cell.delegate = self;
    cell.schedule = clinicSchedules[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *clinicName = self.clinicNames[indexPath.section];
    NSArray *clinicSchedules = self.schedules[clinicName];
    Schedule *schedule = clinicSchedules[indexPath.row];
    return [schedule height];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *clinicName = self.clinicNames[section];
    CGFloat width = tableView.frame.size.width;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, width - 10, 40)];
    titleLabel.text = [NSString stringWithFormat:@" Clinic: %@", clinicName];
    titleLabel.font = [UIFont fontWithName:@"Roboto-Medium" size:16];
    titleLabel.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
    titleLabel.layer.cornerRadius = 5;
    titleLabel.clipsToBounds = YES;
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(width - 50, 10, 30, 30)];
    addButton.tag = section;
    [addButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addScheduleTapped:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:titleLabel];
    [header addSubview:addButton];
    header.backgroundColor = [UIColor whiteColor];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    return;
    
    NSString *clinicName = self.clinicNames[indexPath.section];
    NSArray *clinicSchedules = self.schedules[clinicName];
    AddScheduleController *vc = ControllerFromStoryBoard(@"Slot", @"AddScheduleController");
    vc.schedule = clinicSchedules[indexPath.row];
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)addScheduleTapped:(UIButton*)btn{
    AddScheduleController *vc = ControllerFromStoryBoard(@"Slot", @"AddScheduleController");
    NSString *clinicName = self.clinicNames[btn.tag];
    NSArray *clinicSchedules = self.allSchedules[clinicName];
    NSDictionary *details = clinicSchedules[0];
    vc.clinicID = details[@"clinic_id"];
    vc.clinicName = details[@"clinic_name"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)deleteSchedule:(Schedule*)schedule{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [schedule deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error) {
            [self confirmConflictSchedule:schedule error:error];
        }else{
            [self confirmConflictSchedule:schedule error:error];
        }
    }];
}

- (void)confirmConflictSchedule:(Schedule*)schedule error:(NSError*)error{
    NSString *message;
    if (error) {
        message = [NSString stringWithFormat:@"%ld clashing appointments. Are you sure you want to delete this schedule?",[error.userInfo[@"total"] integerValue]];
    }else{
        message = @"Are you sure you want to delete this schedule?";
    }
    
    [UIAlertController showAlertInViewController:self
                                       withTitle:@"Confirm"
                                         message:message
                               cancelButtonTitle:nil
                          destructiveButtonTitle:@"Cancel"
                               otherButtonTitles:@[@"Confirm"]
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            if(controller.destructiveButtonIndex != buttonIndex) {
                                                [self confirmDeleteSchedule:schedule];
                                            }
                                        }];
}

- (void)confirmDeleteSchedule:(Schedule*)schedule{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [schedule forceDeleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self fetchSchedules];
    }];
}

@end
