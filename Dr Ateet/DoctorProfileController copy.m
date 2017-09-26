//
//  DoctorProfileController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 08/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "DoctorProfileController.h"

@interface DoctorProfileController ()

@property (nonatomic, strong) IBOutlet  UIView    *headerView;

@end

@implementation DoctorProfileController

+ (id)controller{
    return ControllerFromMainStoryBoard([self description]);
}

+ (id)navigationController{
    return [[UINavigationController alloc] initWithRootViewController:[self controller]];
}


- (void)awakeFromNib{
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My Profile";
    [self initializeForm];
    self.tableView.tableHeaderView = _headerView;
    [self applyTheme];
    [self addNavigationButtons];
}

- (void)applyTheme{
    
}

- (void)addNavigationButtons{
    UIButton *menuIcon = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [menuIcon setImage:[UIImage imageNamed:@"menu_icon.png"] forState:UIControlStateNormal];
    [menuIcon addTarget:self action:@selector(menuTapped) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuIcon];
}

- (void)menuTapped{
    [ApplicationDelegate toggleMenu];
}

- (void)initializeForm {
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    CUser *user = [CUser currentUser];
    UIFont *font = [UIFont fontWithName:@"Roboto-Medium" size:16];
    UIFont *detailFont = [UIFont fontWithName:@"Roboto-Regular" size:14];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"dd-MM-yyyy";
    
    form = [XLFormDescriptor formDescriptorWithTitle:@"Add Event"];
    
    // First section
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // First Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"first_name" rowType:XLFormRowDescriptorTypeText title:@"First Name"];
    [row.cellConfigAtConfigure setObject:@"First Name" forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textField.font"];
    row.value = user[row.tag];
    [section addFormRow:row];
    
    // Last Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"last_name" rowType:XLFormRowDescriptorTypeText title:@"Last Name"];
    [row.cellConfigAtConfigure setObject:@"Last Name" forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textField.font"];
    row.value = user[row.tag];
    [section addFormRow:row];
    
    // Mobile Number
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"mobile_number" rowType:XLFormRowDescriptorTypePhone title:@"Mobile Number"];
    [row.cellConfigAtConfigure setObject:@"Mobile Number" forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textField.font"];
    row.value = user[row.tag];
    [section addFormRow:row];
    
    // Visible to patient
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"is_display" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Visible to patient"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    row.value = user[row.tag];
    [section addFormRow:row];
    
    // Medical Registration Number
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"medical_registration_number" rowType:XLFormRowDescriptorTypeNumber title:@"Medical Registration Number"];
    [row.cellConfigAtConfigure setObject:@"Medical Registration Number" forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textField.font"];
    row.value = user[row.tag];
    [section addFormRow:row];
    
    // Email
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"email" rowType:XLFormRowDescriptorTypeEmail title:@"Email"];
    [row.cellConfigAtConfigure setObject:@"Email" forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textField.font"];
    row.value = user[row.tag];
    [section addFormRow:row];
    
    // DOB
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"dob" rowType:XLFormRowDescriptorTypeDateInline title:@"Date of Birth"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    row.value = [dateFormatter dateFromString:user[row.tag]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"gender" rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Gender"];
    row.selectorOptions = @[@"Male" , @"Female"];
    row.value = [user[row.tag] capitalizedString];
    [section addFormRow:row];
    
    self.form = form;
}

@end
