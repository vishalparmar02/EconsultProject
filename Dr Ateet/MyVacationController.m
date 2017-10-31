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
    self.vacationNameField.text = vacation[@"vacation_name"];
    
    NSString *address = vacation[@"address"];
    NSString *city = vacation[@"city"];
    NSString *state = vacation[@"state"];
    NSString *contactNumber = vacation[@"contact_number"];
    
    NSMutableArray *components = [NSMutableArray array];
    if (address.length) [components addObject:address];
    if (city.length) [components addObject:city];
    if (state.length) [components addObject:state];
    if (contactNumber.length) [components addObject:contactNumber];
    
    self.vacationDetailsField.text = [components componentsJoinedByString:@"\n"];
}

- (IBAction)deleteTapped{
    if ([self.delegate respondsToSelector:@selector(deleteVacation:)]) {
        [self.delegate deleteVacation:self.vacation];
    }
}

@end

@interface MyVacationController ()<UITableViewDataSource, UITableViewDelegate, VacationCellDelegate>

@property (nonatomic, strong) IBOutlet  UITableView *tableView;
@property (nonatomic, strong)           NSArray     *vacations;

@end

@implementation MyVacationController

+ (id)controller{
    return ControllerFromStoryBoard(@"Slot", [self description]);
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
        NSMutableArray *vacations = [NSMutableArray array];
        for (Vacation *aVacation in objects ) {
            if (aVacation.objectId.integerValue != -1) {
                [vacations addObject:aVacation];
            }
        }
        [vacations sortUsingComparator:^NSComparisonResult(Vacation *obj1, Vacation *obj2) {
            return [[obj1[@"vacation_name"] lowercaseString] compare:[obj2[@"vacation_name"] lowercaseString]];
        }];
        self.vacations = vacations;
        [self.tableView reloadData];
    }];
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
    return 125;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    VacationViewController *vc = [[VacationViewController alloc] init];
//    vc.vacation = self.vacations[indexPath.row];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addVacationTapped{
    UIAlertController *addVacation = [UIAlertController alertControllerWithTitle:@"Add Vacation"
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    __block UITextField *startDate, *endDate;
    
    [addVacation addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        startDate = textField;
        textField.placeholder = @"Start Date";
    }];
    
    [addVacation addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        endDate = textField;
        textField.placeholder = @"End Date";
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                      style:UIAlertActionStyleDestructive
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        
                                                    }];
    UIAlertAction *add = [UIAlertAction actionWithTitle:@"Add"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        
                                                    }];
    [addVacation addAction:cancel];
    [addVacation addAction:add];
    [self.navigationController presentViewController:addVacation
                                            animated:YES
                                          completion:nil];
}

- (void)deleteVacation:(Vacation*)vacation{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [vacation deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self confirmConflictVacation:vacation error:error];
    }];
}

- (void)confirmConflictVacation:(Vacation*)vacation error:(NSError*)error{
    NSString *message;
    if (error) {
        message = [NSString stringWithFormat:@"%ld clashing appointments. Are you sure you want to delete this vacation?",[error.userInfo[@"total"] integerValue]];
    }else{
        message = @"Are you sure you want to delete this vacation?";
    }
    
    [UIAlertController showAlertInViewController:self
                                       withTitle:@"Confirm"
                                         message:message
                               cancelButtonTitle:nil
                          destructiveButtonTitle:@"Cancel"
                               otherButtonTitles:@[@"Confirm"]
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            if(controller.destructiveButtonIndex != buttonIndex) {
                                                [self confirmDeleteVacation:vacation];
                                            }
                                        }];
}

- (void)confirmDeleteVacation:(Vacation*)vacation{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [vacation forceDeleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        [self fetchVacations];
//    }];
}


@end

