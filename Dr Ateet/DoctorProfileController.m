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
#import "OTPVerificationController.h"


@interface DoctorProfileController ()<UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

{
    
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
}


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

- (void)awakeFromNib
{
    [super awakeFromNib];
}



- (void)viewDidLoad
{
    
    
    
    [super viewDidLoad];
    
    
    self.profileImageButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.profileImageButton setImage:nil forState:UIControlStateNormal];
    [self fetchProfile];
    self.title = [[CUser currentUser] isPatient] ? ABOUT_STRING : @"My Profile";
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
    
    [self initializeForm];
    [self setFormState:NO];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ActionCaptured:)
                                                 name:@"ReloadForm" object:nil];
    
}


- (void)ActionCaptured:(NSNotification *)note {
    
    NSLog(@"Received Notification");
    
    [self initializeForm];
    
}


- (void)fetchProfile{
    
    
    if ([[CUser currentUser] isPatient]) {
        self.title = ABOUT_STRING;
        
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
        
        //[self initializeForm];
    }
    
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

- (void)initializeProfileForm:(NSDictionary*)profile {
    
  
    
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
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"dob" rowType:XLFormRowDescriptorTypeText title:@"Date of Birth"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.value = profile[row.tag];
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
    
    
    // Website
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"website" rowType:XLFormRowDescriptorTypeTextView];
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
    
//    // Mobile Number
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"mobile_number" rowType:XLFormRowDescriptorTypePhone title:@"Mobile Number"];
//    [row.cellConfigAtConfigure setObject:@"Mobile Number" forKey:@"textField.placeholder"];
//    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
//    [row.cellConfig setObject:font forKey:@"textLabel.font"];
//    [row.cellConfig setObject:detailFont forKey:@"textField.font"];
//    row.value = user[row.tag];
//    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"mobile_number" rowType:XLFormRowDescriptorTypeButton title:@"Mobile Number"];
    //[row.cellConfig setObject:[UIColor blackColor] forKey:@"textLabel.textColor"];
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    row.cellStyle = UITableViewCellStyleValue1;
    NSString *newnum = [[NSUserDefaults standardUserDefaults] valueForKey:@"NEWNUM"];
    if (newnum == nil)
    {
        [[NSUserDefaults standardUserDefaults]setObject:user[row.tag] forKey:@"NEWNUM"];
        
    }
    NSString *newnum3 = [[NSUserDefaults standardUserDefaults] valueForKey:@"NEWNUM"];
    row.value = newnum3;
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
    
    
    // Website
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"website" rowType:XLFormRowDescriptorTypeURL title:@"Website"];
    row.value = @"http://drateetsharma.com";
    [row.cellConfig setObject:font forKey:@"textLabel.font"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:detailFont forKey:@"textField.font"];
    [section addFormRow:row];
    
    self.form = form;
  //  [self setFormState:NO];
}

- (void)setFormState:(BOOL)enabled{
    for (XLFormSectionDescriptor *section in self.form.formSections){
        for (XLFormRowDescriptor *row in section.formRows){
            row.disabled = @(!enabled);
        }
    }
    [self.tableView reloadData];
}

-(void)didSelectFormRow:(XLFormRowDescriptor *)formRow
{
    
    if ([formRow.tag isEqualToString:@"mobile_number"])
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            OTPVerificationVC *View = [storyboard instantiateViewControllerWithIdentifier:@"OTPVerificationVC"];
            [self.navigationController pushViewController:View animated:YES];
            
            
        });
    }
}



- (void)editTapped{
    [self setFormState:YES];
    self.navigationItem.rightBarButtonItem = self.saveButton;
}



- (void)updateTapped{


    NSMutableDictionary *currentUserDict = [[defaults_object(CURRENT_USER_KEY) JSONObject] mutableCopy];
    NSDictionary *formValues = self.form.formValues;
    
    if (formValues[@"first_name"] == [NSNull null] || formValues[@"last_name"] == [NSNull null])
    {
        [UIAlertController showAlertInViewController:self withTitle:@"Error" message:@"First name or Last name is mising" cancelButtonTitle:@"Ok" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
            
        }];
        
        
    }
    else
    {
        for (NSString *aKey in formValues.allKeys){
            
            if ([formValues[aKey] isKindOfClass:[NSDate class]]) {
                NSDate *date = formValues[aKey];
                NSDateFormatter *df = [NSDateFormatter new];
                [df setDateFormat:@"yyyy-MM-dd"];
                currentUserDict[aKey] = [df stringFromDate:date];
            }else{
                
                NSLog(@"%@",aKey);
                NSLog(@"%@",formValues[aKey]);
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
                
                self.navigationItem.rightBarButtonItem = self.editButton;
                
                for (NSString *aKey in currentUserDict.allKeys){
                    if ([currentUserDict[aKey] isKindOfClass:[NSNull class]]) {
                        currentUser[aKey] = @"";
                    }else{
                        currentUser[aKey] = currentUserDict[aKey];
                    }
                }
                [currentUser setCurrent];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self setFormState:NO];
                });
                [UIAlertController showAlertInViewController:self
                                                   withTitle:@"Success"
                                                     message:@"Updated Successfully."
                                           cancelButtonTitle:@"OK"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:nil
                                                    tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                                    }];
            }
        }];
    }
    
    
    
}

- (IBAction)uploadTapped{
   /*vedited UIAlertController * view=   [UIAlertController
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
    
    [self presentViewController:view animated:YES completion:nil]; vedited*/
}


- (void)showImagePickerForIndex:(NSInteger)buttonIndex
{
 
    
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
