//
//  MyVacationController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 31/10/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "MyVacationController.h"

@implementation VacationCell

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.container applyShadow];
    [self.container addBorder];
    self.container.layer.cornerRadius = 5;
}


- (void)setVacation:(Vacation *)vacation{
    _vacation = vacation;
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"dd-MM-yyyy"];
    NSDate *startDate = [df dateFromString:vacation[@"start_date"]];
    NSDate *endDate = [df dateFromString:vacation[@"end_date"]];
    
    [df setDateFormat:@"dd LLL, YYYY"];
    self.vacationNameField.text = vacation[@"descriptions"];
    self.vacationDetailsField.text = [NSString stringWithFormat:@"%@ - %@",
                                      [df stringFromDate:startDate],
                                      [df stringFromDate:endDate]];
}

- (IBAction)deleteTapped{
    if ([self.delegate respondsToSelector:@selector(deleteVacation:)]) {
        [self.delegate deleteVacation:self.vacation];
    }
}

@end

@interface MyVacationController ()<UITableViewDataSource, UITableViewDelegate, VacationCellDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet  UITableView     *tableView;
@property (nonatomic, strong)           NSArray         *vacations;
@property (nonatomic, strong)           UIDatePicker    *startDatePicker, *endDatePicker;
@property (nonatomic, strong)           UITextField     *startDateField, *endDateField, *descriptionField;
@property (nonatomic, strong)           UIAlertAction   *addAlertAction;

@end

@implementation MyVacationController

+ (id)controller{
    return ControllerFromStoryBoard(@"Appointments", [self description]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My Vacations";
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self action:@selector(addVacationTapped)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self fetchVacations];
}

- (void)fetchVacations{
    [Vacation fetchVacationsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.vacations = objects;
        [self.tableView reloadData];
    }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.startDateField) {
        [self startDateChanged];
    }else if (textField == self.endDateField) {
        [self endDateChanged];
    }
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.vacations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    VacationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VacationCell"
                                                       forIndexPath:indexPath];
    cell.vacation = self.vacations[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    VacationViewController *vc = [[VacationViewController alloc] init];
//    vc.vacation = self.vacations[indexPath.row];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)startDateChanged{
    NSDateFormatter *timeFormatter = [NSDateFormatter new];
    timeFormatter.dateFormat = @"dd LLLL, YYYY";
    self.startDateField.text = [timeFormatter stringFromDate:self.startDatePicker.date];
    self.addAlertAction.enabled = self.startDateField.text.length && self.endDateField.text.length;
}

- (void)endDateChanged{
    NSDateFormatter *timeFormatter = [NSDateFormatter new];
    timeFormatter.dateFormat = @"dd LLLL, YYYY";
    self.endDateField.text = [timeFormatter stringFromDate:self.endDatePicker.date];
    self.addAlertAction.enabled = self.startDateField.text.length && self.endDateField.text.length;
}

- (void)addVacationTapped{
    UIAlertController *addVacation = [UIAlertController alertControllerWithTitle:@"Add Vacation"
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [addVacation addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        self.startDateField = textField;
        self.startDateField.delegate = self;
        self.startDateField.placeholder = @"Start Date";
        self.startDatePicker = [[UIDatePicker alloc] init];
        self.startDatePicker.datePickerMode = UIDatePickerModeDate;
        [self.startDatePicker addTarget:self
                                 action:@selector(startDateChanged)
                       forControlEvents:UIControlEventValueChanged];
        self.startDateField.inputView = self.startDatePicker;
    }];
    
    [addVacation addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        self.endDateField = textField;
        self.endDateField.delegate = self;
        self.endDateField.placeholder = @"End Date";
        self.endDatePicker = [[UIDatePicker alloc] init];
        self.endDatePicker.datePickerMode = UIDatePickerModeDate;
        [self.endDatePicker addTarget:self
                                 action:@selector(endDateChanged)
                       forControlEvents:UIControlEventValueChanged];
        self.endDateField.inputView = self.endDatePicker;
    }];
    
    [addVacation addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        self.descriptionField = textField;
        self.descriptionField.text = @"";
        textField.placeholder = @"Description";
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                      style:UIAlertActionStyleDestructive
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        
                                                    }];
    self.addAlertAction = [UIAlertAction actionWithTitle:@"Add"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        if (_startDateField.text.length && _endDateField.text.length) {
                                                            [self addVacation];
                                                        }
                                                    }];
    [addVacation addAction:cancel];
    [addVacation addAction:self.addAlertAction];
    [self.navigationController presentViewController:addVacation
                                            animated:YES
                                          completion:nil];
}

- (void)addVacation{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"YYYY-MM-dd";
    
    Vacation *vacation = [Vacation new];
    vacation[@"save"] = @{@"users_id" : [CUser currentUser].objectId,
                          @"descriptions" : self.descriptionField.text,
                          @"start_date" : [dateFormatter stringFromDate:self.startDatePicker.date],
                          @"end_date" : [dateFormatter stringFromDate:self.endDatePicker.date]};
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];
    [vacation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view
                             animated:YES];
        [self fetchVacations];
    }];
}

- (void)deleteVacation:(Vacation*)vacation{
    [UIAlertController showAlertInViewController:self
                                       withTitle:@"Confirm"
                                         message:@"Are you sure you want to delete this vacation?"
                               cancelButtonTitle:@"Cancel"
                          destructiveButtonTitle:@"Confirm"
                               otherButtonTitles:nil
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            if(controller.destructiveButtonIndex == buttonIndex) {
                                                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                [vacation deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                    [self fetchVacations];
                                                }];
                                            }
                                        }];
    
    
}

@end

