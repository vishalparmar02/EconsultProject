//
//  DoctorProDetailsController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 08/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "DoctorProDetailsController.h"

@interface DoctorProDetailsController ()

@property (nonatomic, strong) IBOutlet  UIView          *headerView;
@property (nonatomic, strong)           UIBarButtonItem *editButton, *saveButton;

@end

@implementation DoctorProDetailsController

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
    self.title = @"Professional Details";
    [self initializeForm];
    self.tableView.tableHeaderView = _headerView;
    [self applyTheme];
    [self addNavigationButtons];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(updateTapped)];
    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                    target:self
                                                                    action:@selector(editTapped)];
    
    self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                    target:self
                                                                    action:@selector(updateTapped)];
    self.navigationItem.rightBarButtonItem = self.editButton;
}

- (void)applyTheme{
    
}

- (void)addNavigationButtons{
    UIButton *menuIcon = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [menuIcon setImage:[UIImage imageNamed:@"menu_icon.png"] forState:UIControlStateNormal];
    menuIcon.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [menuIcon addTarget:self action:@selector(menuTapped) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuIcon];
    
    if (@available(iOS 9, *)) {
        [menuIcon.widthAnchor constraintEqualToConstant: 32].active = YES;
        [menuIcon.heightAnchor constraintEqualToConstant: 32].active = YES;
    }
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
    
    form = [XLFormDescriptor formDescriptorWithTitle:@"Professional Profile"];
    
    // Professional Experience
    section = [XLFormSectionDescriptor formSection];
    section.title = @"Professional Experience";
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"professional_experience" rowType:XLFormRowDescriptorTypeTextView];
    row.value = user[row.tag];
    row.height = 80;
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textView.font"];
    [section addFormRow:row];
    
    // Professional Awards & Achievements
    section = [XLFormSectionDescriptor formSection];
    section.title = @"Professional Awards & Achievements";
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"professional_awards_achievements" rowType:XLFormRowDescriptorTypeTextView];
    row.value = user[row.tag];
    row.height = 80;
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textView.font"];
    [section addFormRow:row];
    
    // Services/Treatments
    section = [XLFormSectionDescriptor formSection];
    section.title = @"Services/Treatments";
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"services_treatments" rowType:XLFormRowDescriptorTypeTextView];
    row.value = user[row.tag];
    row.height = 80;
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textView.font"];
    [section addFormRow:row];
    
    // Education
    section = [XLFormSectionDescriptor formSection];
    section.title = @"Education";
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"education" rowType:XLFormRowDescriptorTypeTextView];
    row.value = user[row.tag];
    row.height = 80;
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textView.font"];
    [section addFormRow:row];
    
    // About Me
    section = [XLFormSectionDescriptor formSection];
    section.title = @"About Me";
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"about_me" rowType:XLFormRowDescriptorTypeTextView];
    row.value = user[row.tag];
    row.height = 80;
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textView.font"];
    [section addFormRow:row];
    
    self.form = form;
    [self setFormState:NO];
}

- (void)setFormState:(BOOL)enabled{
    for (XLFormSectionDescriptor *section in self.form.formSections){
        for (XLFormRowDescriptor *row in section.formRows){
            row.disabled = @(!enabled);
        }
    }
    [self.tableView reloadData];
}

- (void)editTapped{
    [self setFormState:YES];
    self.navigationItem.rightBarButtonItem = self.saveButton;
}

- (void)updateTapped{
    NSMutableDictionary *currentUserDict = [[defaults_object(CURRENT_USER_KEY) JSONObject] mutableCopy];
    NSDictionary *formValues = self.form.formValues;
    for (NSString *aKey in formValues.allKeys){
        currentUserDict[aKey] = formValues[aKey];
    }
    __block CUser *currentUser = [CUser currentUser];
    currentUser[@"update"] = currentUserDict;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [currentUser updateInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error) {
            [UIAlertController showAlertInViewController:self
                                               withTitle:@"Error"
                                                 message:@"Please retry"
                                       cancelButtonTitle:@"OK"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:nil
                                                tapBlock:nil];
        }else{
            self.navigationItem.rightBarButtonItem = self.editButton;
            
            for (NSString *aKey in currentUserDict.allKeys){
                currentUser[aKey] = currentUserDict[aKey];
            }
            [currentUser setCurrent];
            [self setFormState:NO];
            [UIAlertController showAlertInViewController:self
                                               withTitle:@"Success"
                                                 message:@"Updated Successfully."
                                       cancelButtonTitle:@"OK"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:nil
                                                tapBlock:nil];
        }
    }];
}

@end
