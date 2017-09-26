//
//  DoctorProfileController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 08/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "DoctorProfileController.h"
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/UIButton+WebCache.h>
#import "UIImage+FixRotation.h"

@interface DoctorProfileController ()<UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet  UIView          *headerView;
@property (nonatomic, strong) IBOutlet  UIButton        *profileImageButton;
@property (nonatomic, strong)           UIBarButtonItem *editButton, *saveButton;

@end

@implementation DoctorProfileController

+ (id)controller{
    return ControllerFromMainStoryBoard([self description]);
}

+ (id)fullProfileController{
    return ControllerFromMainStoryBoard(@"DoctorFullProfileController");
}

+ (id)navigationController{
    return [[UINavigationController alloc] initWithRootViewController:[self controller]];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return ![[CUser currentUser] isPatient];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return ![[CUser currentUser] isPatient];
}

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchProfile];
    self.title = [[CUser currentUser] isPatient] ? @"About Dr. Ateet Sharma" : @"My Profile";
    self.tableView.tableHeaderView = _headerView;
    [self applyTheme];
    if(self.navigationController.viewControllers[0] == self)[self addNavigationButtons];
    
    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                    target:self
                                                                    action:@selector(editTapped)];
    
    self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                    target:self
                                                                    action:@selector(updateTapped)];
    
    
    if (![[CUser currentUser] isPatient]){
        self.navigationItem.rightBarButtonItem = self.editButton;
    }
}

- (void)fetchProfile{
    if ([[CUser currentUser] isPatient]) {
        self.title = @"About Dr. Ateet Sharma";
        
        [CUser fetchDoctorProfileInBackgroundWithBlock:^(NSDictionary * _Nullable object, NSError * _Nullable error) {
            NSURL *profileURL = [NSURL URLWithString:object[@"profile_pic"]];
            [self.profileImageButton sd_setImageWithURL:profileURL
                                               forState:UIControlStateNormal
                                       placeholderImage:nil
                                                options:SDWebImageProgressiveDownload];
            
            [self initializeProfileForm:object];
        }];
    }else{
        NSURL *profileURL = [[CUser currentUser] profileImageURL];
        [self.profileImageButton sd_setImageWithURL:profileURL
                                           forState:UIControlStateNormal
                                   placeholderImage:nil
                                            options:SDWebImageProgressiveDownload];
        
        [self initializeForm];
    }
    
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

- (void)initializeProfileForm:(NSDictionary*)profile {
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
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
    [row.cellConfig setObject:self forKey:@"textField.delegate"];
    row.value = profile[row.tag];
    [section addFormRow:row];
    
    // Last Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"last_name" rowType:XLFormRowDescriptorTypeText title:@"Last Name"];
    [row.cellConfigAtConfigure setObject:@"Last Name" forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textField.font"];
    row.value = profile[row.tag];
    [section addFormRow:row];
    
    // Mobile Number
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"mobile_number" rowType:XLFormRowDescriptorTypePhone title:@"Mobile Number"];
    [row.cellConfigAtConfigure setObject:@"Mobile Number" forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textField.font"];
    row.value = profile[row.tag];
    [section addFormRow:row];
    
    // Medical Registration Number
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"medical_registration_number" rowType:XLFormRowDescriptorTypeText title:@"Medical Registration Number"];
    [row.cellConfigAtConfigure setObject:@"Medical Registration Number" forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textField.font"];
    row.value = profile[row.tag];
    [section addFormRow:row];
    
    // Email
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"email" rowType:XLFormRowDescriptorTypeEmail title:@"Email"];
    [row.cellConfigAtConfigure setObject:@"Email" forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textField.font"];
    row.value = profile[row.tag];
    [section addFormRow:row];
    
    // DOB
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"dob" rowType:XLFormRowDescriptorTypeDateInline title:@"Date of Birth"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    row.value = [dateFormatter dateFromString:profile[row.tag]];
    [section addFormRow:row];
    
//    //Gender
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"gender" rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Gender"];
//    row.selectorOptions = @[@"Male" , @"Female"];
//    row.value = [profile[row.tag] capitalizedString];
//    [section addFormRow:row];
    
    // Professional Experience
    section = [XLFormSectionDescriptor formSection];
    section.title = @"Professional Experience";
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"professional_experience" rowType:XLFormRowDescriptorTypeTextView];
    row.value = profile[row.tag];
    row.height = 80;
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textView.font"];
    [section addFormRow:row];
    
    // Professional Awards & Achievements
    section = [XLFormSectionDescriptor formSection];
    section.title = @"Professional Awards & Achievements";
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"professional_awards_achievements" rowType:XLFormRowDescriptorTypeTextView];
    row.value = profile[row.tag];
    row.height = 80;
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textView.font"];
    [section addFormRow:row];
    
    // Services/Treatments
    section = [XLFormSectionDescriptor formSection];
    section.title = @"Services/Treatments";
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"services_treatments" rowType:XLFormRowDescriptorTypeTextView];
    row.value = profile[row.tag];
    row.height = 80;
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textView.font"];
    [section addFormRow:row];
    
    // Education
    section = [XLFormSectionDescriptor formSection];
    section.title = @"Education";
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"education" rowType:XLFormRowDescriptorTypeTextView];
    row.value = profile[row.tag];
    row.height = 80;
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textView.font"];
    [section addFormRow:row];
    
    // About Me
    section = [XLFormSectionDescriptor formSection];
    section.title = @"About Me";
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"about_me" rowType:XLFormRowDescriptorTypeTextView];
    row.value = profile[row.tag];
    row.height = 80;
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfig setObject:detailFont forKey:@"textView.font"];
    [section addFormRow:row];
    
    self.form = form;
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
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"medical_registration_number" rowType:XLFormRowDescriptorTypeText title:@"Medical Registration Number"];
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
    
    //Gender
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"gender" rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Gender"];
    row.selectorOptions = @[@"Male" , @"Female"];
    row.value = [user[row.tag] capitalizedString];
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
        if ([formValues[aKey] isKindOfClass:[NSDate class]]) {
            NSDate *date = formValues[aKey];
            NSDateFormatter *df = [NSDateFormatter new];
            [df setDateFormat:@"yyyy-MM-dd"];
            currentUserDict[aKey] = [df stringFromDate:date];
        }else{
            currentUserDict[aKey] = formValues[aKey];
        }
        
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
            [self setFormState:NO];
            self.navigationItem.rightBarButtonItem = self.editButton;
            
            for (NSString *aKey in currentUserDict.allKeys){
                currentUser[aKey] = currentUserDict[aKey];
            }
            [currentUser setCurrent];
            
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

- (IBAction)uploadTapped{
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:@"Choose Source"
                                 message:@""
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *gallary = [UIAlertAction
                              actionWithTitle:@"Gallery"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [self showImagePickerForIndex:0];
                                  [view dismissViewControllerAnimated:YES completion:nil];
                                  
                              }];
    
    UIAlertAction *camera = [UIAlertAction
                             actionWithTitle:@"Camera"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self showImagePickerForIndex:1];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    
    [view addAction:gallary];
    [view addAction:camera];
    [view addAction:cancel];
    
    [self presentViewController:view animated:YES completion:nil];
}

- (void)showImagePickerForIndex:(NSInteger)buttonIndex{
    BOOL isCamera = buttonIndex > 0;
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType              = isCamera ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    pickerController.allowsEditing = NO;
    
    [pickerController.navigationBar setTranslucent:NO];
    [pickerController.navigationBar setTintColor:[UIColor blackColor]];
    
    
    [self presentViewController:pickerController
                       animated:YES
                     completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [image fixRotation];
    CUser *currentUser = [CUser currentUser];
    currentUser.image = image;
    [self.profileImageButton setImage:image forState:UIControlStateNormal];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [currentUser updateProfileImageInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
}

@end
