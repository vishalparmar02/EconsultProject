//
//  MonthSelector.m
//  Dr Ateet
//
//  Created by Shashank Patel on 06/01/18.
//  Copyright © 2018 Shashank Patel. All rights reserved.
//

#import "MonthSelector.h"

@interface MonthSelector ()

@property (nonatomic, strong)   NSArray             *allMonths;

@end

@implementation MonthSelector

+ (NSArray*)allMonths{
    static dispatch_once_t onceToken;
    static NSArray  *allMonths;
    dispatch_once(&onceToken, ^{
        allMonths = @[@"January", @"February", @"March", @"April",
                      @"May", @"June", @"July", @"August",
                      @"September", @"October", @"November", @"December"];
    });
    return allMonths;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Select Months";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneTapped)];
    self.allMonths = [MonthSelector allMonths];
    if (!self.selectedMonths) {
        self.selectedMonths = [NSMutableArray array];
        [self.selectedMonths addObjectsFromArray:self.allMonths];
    }
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MonthCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 12;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MonthCell" forIndexPath:indexPath];
    NSString *monthName = self.allMonths[indexPath.row];
    cell.textLabel.text = monthName;
    cell.accessoryType =  [self.selectedMonths containsObject:monthName] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *monthName = self.allMonths[indexPath.row];
    if ([self.selectedMonths containsObject:monthName]) {
        [self.selectedMonths removeObject:monthName];
    }else{
        [self.selectedMonths addObject:monthName];
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType =  [self.selectedMonths containsObject:monthName] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void)doneTapped{
    [self.delegate monthsUpdated:self.selectedMonths];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
