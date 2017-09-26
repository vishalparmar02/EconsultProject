//
//  ClinicsListController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 08/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "ClinicsListController.h"
#import "Clinic.h"
#import "ClinicViewController.h"

@implementation ClinicCell

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.container applyShadow];
    [self.container addBorder];
    self.container.layer.cornerRadius = 5;
}


- (void)setClinic:(Clinic *)clinic{
    _clinic = clinic;
    self.clinicNameField.text = clinic[@"clinic_name"];
    
    NSString *address = clinic[@"address"];
    NSString *city = clinic[@"city"];
    NSString *state = clinic[@"state"];
    NSString *contactNumber = clinic[@"contact_number"];
    
    NSMutableArray *components = [NSMutableArray array];
    if (address.length) [components addObject:address];
    if (city.length) [components addObject:city];
    if (state.length) [components addObject:state];
    if (contactNumber.length) [components addObject:contactNumber];
    
    self.clinicDetailsField.text = [components componentsJoinedByString:@"\n"];
}

- (IBAction)deleteTapped{
    if ([self.delegate respondsToSelector:@selector(deleteClinic:)]) {
        [self.delegate deleteClinic:self.clinic];
    }
}

@end

@interface ClinicsListController ()<UITableViewDataSource, UITableViewDelegate, ClinicCellDelegate>

@property (nonatomic, strong) IBOutlet  UITableView *tableView;
@property (nonatomic, strong)           NSArray     *clinics;

@end

@implementation ClinicsListController

+ (id)controller{
    return ControllerFromStoryBoard(@"Slot", [self description]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My Clinics";
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                     style:UIBarButtonItemStylePlain
                                    target:self action:@selector(addClinicTapped)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self fetchClinics];
}

- (void)fetchClinics{
    [Clinic fetchClinicsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        NSMutableArray *clinics = [NSMutableArray array];
        for (Clinic *aClinic in objects ) {
            if (![aClinic.objectId isEqual:@-1]) {
                [clinics addObject:aClinic];
            }
        }
        [clinics sortUsingComparator:^NSComparisonResult(Clinic *obj1, Clinic *obj2) {
            return [[obj1[@"clinic_name"] lowercaseString] compare:[obj2[@"clinic_name"] lowercaseString]];
        }];
        self.clinics = clinics;
        [self.tableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.clinics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ClinicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClinicCell"
                                                       forIndexPath:indexPath];
    cell.clinic = self.clinics[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 125;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ClinicViewController *vc = [[ClinicViewController alloc] init];
    vc.clinic = self.clinics[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addClinicTapped{
    ClinicViewController *vc = [[ClinicViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)deleteClinic:(Clinic*)clinic{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [clinic deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self confirmConflictClinic:clinic error:error];
    }];
}

- (void)confirmConflictClinic:(Clinic*)clinic error:(NSError*)error{
    NSString *message;
    if (error) {
        message = [NSString stringWithFormat:@"%ld clashing appointments. Are you sure you want to delete this clinic?",[error.userInfo[@"total"] integerValue]];
    }else{
        message = @"Are you sure you want to delete this clinic?";
    }
    
    [UIAlertController showAlertInViewController:self
                                       withTitle:@"Confirm"
                                         message:message
                               cancelButtonTitle:nil
                          destructiveButtonTitle:@"Cancel"
                               otherButtonTitles:@[@"Confirm"]
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            if(controller.destructiveButtonIndex != buttonIndex) {
                                                [self confirmDeleteClinic:clinic];
                                            }
                                        }];
}

- (void)confirmDeleteClinic:(Clinic*)clinic{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [clinic forceDeleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self fetchClinics];
    }];
}


@end
