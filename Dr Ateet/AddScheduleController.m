//
//  AddScheduleController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 18/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "AddScheduleController.h"
#import "UIPickerView+Blocks.h"
#import "MonthSelector.h"

@interface ScheduleDayCell ()

@property (nonatomic, strong) BEMCheckBox           *dayCheckBox;
@property (nonatomic, strong) NSMutableArray        *weekCheckBoxes;

@end

@implementation ScheduleDayCell

- (void)didTapCheckBox:(BEMCheckBox*)checkBox{
    if (checkBox == self.dayCheckBox) {
        for (BEMCheckBox *cb in self.weekCheckBoxes) {
            [cb setOn:self.dayCheckBox.on animated:YES];
        }
    }else if ([_weekCheckBoxes containsObject:checkBox]) {
        BOOL checked = NO;
        for (BEMCheckBox *cb in _weekCheckBoxes) {
            if (cb.on) {
                checked = YES;
                break;
            }
        }
        
        if (checked != self.dayCheckBox.on) {
            [self.dayCheckBox setOn:checked animated:YES];
        }
    }
}

- (NSDictionary*)repeatDetails{
    if (self.dayCheckBox.on == NO) {
        return @{@"day" : self.dayLabel.text,
                 @"isChecked" : @NO};
    }else{
        NSMutableArray *repeatDays = [NSMutableArray array];
        for (NSInteger index = 0; index < self.weekCheckBoxes.count; index++) {
            BEMCheckBox *cb = self.weekCheckBoxes[index];
            if (cb.on) {
                [repeatDays addObject:[NSString stringWithFormat:@"%ld", (long)(index + 1)]];
            }
        }
                 
        return @{@"repeat_days":repeatDays,
                 @"day" : self.dayLabel.text,
                 @"isChecked" : @YES};
    }
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    
    self.weekCheckBoxes = [NSMutableArray array];
    _dayCheckBox = [[BEMCheckBox alloc] initWithFrame:_dayButtonContainer.bounds];
    _dayCheckBox.delegate = self;
    _dayCheckBox.boxType = BEMBoxTypeCircle;
    _dayCheckBox.onAnimationType = BEMAnimationTypeFill;
    _dayCheckBox.offAnimationType = BEMAnimationTypeFill;
    [_dayButtonContainer addSubview:_dayCheckBox];
    
    NSArray *views = @[_view1, _view2, _view3, _view4];
    
    for (NSInteger index = 0; index < views.count; index++) {
        UIView *aView = views[index];
        CGFloat x = (aView.frame.size.width - aView.frame.size.width/2) / 2;
        CGFloat y = (aView.frame.size.height - aView.frame.size.height/2) / 2 - 5;
        CGRect frame = CGRectMake(x, y, aView.frame.size.width/2, aView.frame.size.height/2);
        BEMCheckBox *cb = [[BEMCheckBox alloc] initWithFrame:frame];
        cb.delegate = self;
        cb.boxType = BEMBoxTypeCircle;
        cb.onAnimationType = BEMAnimationTypeFill;
        cb.offAnimationType = BEMAnimationTypeFill;
        [aView addSubview:cb];
        [self.weekCheckBoxes addObject:cb];
    }
}

@end

@interface AddScheduleController ()<UITextFieldDelegate, MonthSelectorDelegate>

@property (nonatomic, strong) IBOutlet  UITableView     *tableView;
@property (nonatomic, strong)           NSArray         *days;
@property (nonatomic, strong)           NSMutableArray  *selectedMonths;

@property (nonatomic, strong) IBOutlet  UITextField     *startTimeField, *endTimeField, *timePerPatientField;
@property (nonatomic, strong) IBOutlet  UILabel         *monthsLabel;
@property (nonatomic, strong)           UIPickerView    *minutesPicker;
@property (nonatomic, strong)           UIDatePicker    *startTimePicker, *endTimePicker;

@end

@implementation AddScheduleController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Add Schedule";
    self.days = @[@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday"];
    
    self.startTimePicker = [[UIDatePicker alloc] init];
    [self.startTimePicker addTarget:self action:@selector(startTimeChanged) forControlEvents:UIControlEventValueChanged];
    self.startTimePicker.datePickerMode = UIDatePickerModeTime;
    self.startTimeField.inputView = self.startTimePicker;
    
    self.endTimePicker = [[UIDatePicker alloc] init];
    [self.endTimePicker addTarget:self action:@selector(endTimeChanged) forControlEvents:UIControlEventValueChanged];
    self.endTimePicker.datePickerMode = UIDatePickerModeTime;
    self.endTimeField.inputView = self.endTimePicker;
    
    self.minutesPicker = [[UIPickerView alloc] init];
    [self.minutesPicker setTitles:@[@[@"10 Min", @"15 Min", @"20 Min", @"25 Min", @"30 Min", @"35 Min", @"40 Min"]]];
    [self.minutesPicker handleSelectionWithBlock:^(UIPickerView *pickerView, NSInteger row, NSInteger component) {
        NSString *minute = [self.minutesPicker pickerView:self.minutesPicker titleForRow:row forComponent:component];
        self.timePerPatientField.text = minute;
    }];
    self.timePerPatientField.inputView = self.minutesPicker;
    
    if (self.schedule) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Update"
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self
                                                                                 action:@selector(updateTapped)];
    }else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self
                                                                                 action:@selector(saveTapped)];
    }
    
    
    [self loadScheduleValues];
}

- (void)loadScheduleValues{
    if (!self.schedule) {
        return;
    }
    self.timePerPatientField.text = [NSString stringWithFormat:@"%@ Mins", self.schedule[@"time_duration"]];
    self.startTimeField.text = self.schedule.startTime;
    self.endTimeField.text = self.schedule.endTime;
}

static NSDateFormatter *timeFormatter;

- (void)startTimeChanged{
    if(!timeFormatter){
        timeFormatter = [NSDateFormatter new];
        timeFormatter.dateFormat = @"hh:mm a";
    }
    self.endTimePicker.minimumDate = self.startTimePicker.date;
    self.startTimeField.text = [timeFormatter stringFromDate:self.startTimePicker.date];
}

- (void)endTimeChanged{
    if(!timeFormatter){
        timeFormatter = [NSDateFormatter new];
        timeFormatter.dateFormat = @"hh:mm a";
    }
    
    self.startTimePicker.maximumDate = self.endTimePicker.date;
    self.endTimeField.text = [timeFormatter stringFromDate:self.endTimePicker.date];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ScheduleDayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScheduleDayCell"
                                                         forIndexPath:indexPath];
    cell.dayLabel.text = self.days[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

static NSDateFormatter *saveTimeFormatter;

- (void)saveTapped{
    NSMutableArray *repeatArray = [NSMutableArray array];
    for (NSInteger index = 0; index < 7; index++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        ScheduleDayCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        [repeatArray addObject:[cell repeatDetails]];
    }
    
    BOOL isRepeatEmpty = YES;
    for (NSDictionary *repeatDict in repeatArray) {
        NSLog(@"%@", [repeatDict[@"checked"] description]);
        if ([repeatDict[@"isChecked"] boolValue]) {
            isRepeatEmpty = NO;
            break;
        }
    }
    
    if (isRepeatEmpty ||
        self.startTimeField.text.length == 0 ||
        self.endTimeField.text.length == 0 ||
        self.timePerPatientField.text.length == 0) {
        NSString *errorMessage = @"All fields are compulsary";
        
        if (isRepeatEmpty) {
            errorMessage = @"Please select at least one day";
        }
        
        [UIAlertController showAlertInViewController:self
                                           withTitle:@"Error"
                                             message:errorMessage
                                   cancelButtonTitle:@"OK"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:nil
                                            tapBlock:nil];
        return;
    }
    
    if(!saveTimeFormatter){
        saveTimeFormatter = [NSDateFormatter new];
        saveTimeFormatter.dateFormat = @"HH:mm";
    }
    NSDate *startTime = [timeFormatter dateFromString:self.startTimeField.text];
    NSDate *endTime = [timeFormatter dateFromString:self.endTimeField.text];
    
    
    NSString *timePerPatient = [self.timePerPatientField.text stringByReplacingOccurrencesOfString:@" Min"
                                                                                        withString:@""];
    if (self.selectedMonths.count == 0) self.selectedMonths = [MonthSelector allMonths].mutableCopy;
    NSMutableArray *months = [NSMutableArray array];
    for (NSInteger index = 0; index < [MonthSelector allMonths].count; index++) {
        NSString *monthName = [MonthSelector allMonths][index];
        if ([self.selectedMonths containsObject:monthName]) {
            [months addObject:[@(index+1) stringValue]];
        }
    }
    
    Schedule *newSchedule = [Schedule new];
    newSchedule[@"save"] = @{@"open_time" : [saveTimeFormatter stringFromDate:startTime],
                             @"close_time" : [saveTimeFormatter stringFromDate:endTime],
                             @"clinic_name" : self.clinicName,
                             @"clinic_id" : self.clinicID,
                             @"repeat" : repeatArray,
                             @"repeat_month" : months,
                             @"time_duration" : timePerPatient};
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [newSchedule saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (succeeded) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [UIAlertController showAlertInViewController:self
                                               withTitle:@"Error"
                                                 message:nil
                                       cancelButtonTitle:@"OK"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:nil
                                                tapBlock:nil];
        }
    }];
}

- (void)updateTapped{

    if (self.startTimeField.text.length == 0 ||
        self.endTimeField.text.length == 0 ||
        self.timePerPatientField.text.length == 0) {
        [UIAlertController showAlertInViewController:self
                                           withTitle:@"Error"
                                             message:@"All fields are compulsary"
                                   cancelButtonTitle:@"OK"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:nil
                                            tapBlock:nil];
        return;
    }
    
    if(!saveTimeFormatter){
        saveTimeFormatter = [NSDateFormatter new];
        saveTimeFormatter.dateFormat = @"HH:mm";
    }
    NSDate *startTime = [timeFormatter dateFromString:self.startTimeField.text];
    NSDate *endTime = [timeFormatter dateFromString:self.endTimeField.text];
    
    NSMutableArray *repeatArray = [NSMutableArray array];
    for (NSInteger index = 0; index < 7; index++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        ScheduleDayCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        [repeatArray addObject:[cell repeatDetails]];
    }
    NSString *timePerPatient = [self.timePerPatientField.text stringByReplacingOccurrencesOfString:@" Mins"
                                                                                        withString:@""];
    timePerPatient = [timePerPatient stringByReplacingOccurrencesOfString:@" Min"
                                                                              withString:@""];
    if (self.selectedMonths.count == 0) self.selectedMonths = [MonthSelector allMonths].mutableCopy;
    NSMutableArray *months = [NSMutableArray array];
    for (NSInteger index = 0; index < [MonthSelector allMonths].count; index++) {
        NSString *monthName = [MonthSelector allMonths][index];
        if ([self.selectedMonths containsObject:monthName]) {
            [months addObject:[@(index+1) stringValue]];
        }
    }
    
    self.schedule[@"update"] = @{@"open_time" : [saveTimeFormatter stringFromDate:startTime],
                                 @"close_time" : [saveTimeFormatter stringFromDate:endTime],
                                 @"clinic_name" : self.schedule[@"clinicName"],
                                 @"clinic_id" : self.schedule[@"clinic_id"],
                                 @"repeat_month" : months,
                                 @"repeat" : repeatArray,
                                 @"time_duration" : timePerPatient};
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.schedule updateInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (succeeded) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [UIAlertController showAlertInViewController:self
                                               withTitle:@"Error"
                                                 message:nil
                                       cancelButtonTitle:@"OK"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:nil
                                                tapBlock:nil];
        }
    }];
}

- (IBAction)monthSelectorTapped{
    MonthSelector *selector = [[MonthSelector alloc] init];
    selector.selectedMonths = self.selectedMonths;
    selector.delegate = self;
    [self presentViewController:NavigationControllerWithController(selector)
                       animated:YES
                     completion:nil];
}

- (void)monthsUpdated:(NSMutableArray *)selectedMonths{
//    self.selectedMonths
    if (selectedMonths.count == 12 || selectedMonths.count == 0) {
        self.monthsLabel.text = @"All Months";
        [self.selectedMonths removeAllObjects];
        [self.selectedMonths addObjectsFromArray:[MonthSelector allMonths]];
    }else{
        self.selectedMonths = selectedMonths;
        NSMutableArray *shortMonths = [NSMutableArray array];
        for (NSString *aMonth in self.selectedMonths) {
            [shortMonths addObject:[aMonth substringToIndex:3]];
        }
        self.monthsLabel.text = [shortMonths componentsJoinedByString:@", "];
    }
}

@end
