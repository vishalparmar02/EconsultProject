//
//  HomeController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 29/05/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "HomeController.h"
#import "ThreadController.h"
#import "AppointmentsController.h"
#import "PatientsListController.h"
#import "MenuController.h"
#import "BookAppointmentController.h"
#import "ReportsController.h"
#import "PatientAppointmentsController.h"
#import "DemoMessagesViewController.h"
#import "PatientProfileController.h"
#import "DoctorProfileController.h"
#import "GiveAppointmentController.h"
#import "PatientSelectorController.h"
#import "NotificationsController.h"

#define kCellWidth ((CGRectGetWidth(collectionView.frame) / 2) - 0)

@implementation MenuCell

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.container applyShadow];
    self.container.layer.cornerRadius = 10;
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (void)setMenuDetails:(NSDictionary *)menuDetails{
    _menuDetails = menuDetails;
    UIImage *menuImage = [[UIImage imageNamed:menuDetails[@"image"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.menuImageView.image = menuImage;
    self.menuImageView.tintColor = APP_BLUE;
    self.menuTitleLabel.text = [menuDetails[@"title"] uppercaseString];
    self.menuTitleLabel.textColor = APP_GRAY;
    
    if (menuImage == nil) {
        
    }
}

@end

@interface HomeController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong)   IBOutlet    UICollectionView    *collectionView;
@property (nonatomic, strong)   IBOutlet    UIImageView         *userImageView;
@property (nonatomic, strong)   IBOutlet    UILabel             *userNameLabel;
@property (nonatomic, strong)               NSArray             *menuItems;
@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint  *userImageViewTopPadding, *collectionViewPadding;

@end

@implementation HomeController

+ (id)controller{
    return ControllerFromStoryBoard(@"Main", [self description]);
}

+ (id)navigationController{
    return [[UINavigationController alloc] initWithRootViewController:[self controller]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *notificationIcon = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [notificationIcon setImage:[UIImage imageNamed:@"bell.png"] forState:UIControlStateNormal];
    notificationIcon.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [notificationIcon addTarget:self action:@selector(notificationTapped) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:notificationIcon];
    
    if (@available(iOS 9, *)) {
        [notificationIcon.widthAnchor constraintEqualToConstant: 32].active = YES;
        [notificationIcon.heightAnchor constraintEqualToConstant: 32].active = YES;
    }
    
    self.userNameLabel.text = [[CUser currentUser] fullName];
    NSURL *profileURLString = [[CUser currentUser] profileImageURL];
    [self.userImageView sd_setImageWithURL:profileURLString
                          placeholderImage:nil
                                   options:SDWebImageProgressiveDownload];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    layout.minimumLineSpacing = 0.0;
    layout.minimumInteritemSpacing = 0.0;
    self.collectionView.collectionViewLayout = layout;
    if ([[CUser currentUser] isPatient]) {
        self.menuItems = @[@{@"image" : @"appointment", @"title" : @"Book an Appointment"},
                           @{@"image" : @"consultation", @"title" : @"Online Consultation"},
                           @{@"image" : @"reports", @"title" : @"Reports"},
                           @{@"image" : @"appointment", @"title" : @"My Appointments"},
                           @{@"image" : @"", @"title" : @"About Dr. Ateet Sharma"}];
//        self.collectionViewPadding.constant = -10;

    }else{
        self.menuItems = @[@{@"image" : @"appointment", @"title" : @"Appointments"},
                           @{@"image" : @"give_appointment", @"title" : @"Give Appointment"},
                           @{@"image" : @"patients", @"title" : @"Patient Info"},
                           @{@"image" : @"appointment", @"title" : @"Clashing Appointments"}];
//        self.collectionViewPadding.constant = 0;
    }
}

- (void)viewWillAppear:(BOOL)animated{
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self checkProfileCompletion];
}

- (void)notificationTapped{
    NotificationsController *vc = [[NotificationsController alloc] init];
    [self presentViewController:NavigationControllerWithController(vc) animated:YES completion:nil];
    
}

- (void)checkProfileCompletion{
    if([CUser currentUser] &&
       (![[CUser currentUser][@"first_name"] length] ||
       ![[CUser currentUser][@"last_name"] length])){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Update Profile"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        __block UITextField *fNameField, *lNameField;
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            fNameField = textField;
            textField.placeholder = @"First Name";
        }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            lNameField = textField;
            textField.placeholder = @"Last Name";
        }];
        UIAlertAction *update = [UIAlertAction actionWithTitle:@"Update"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [self updateProfileWithFirstName:fNameField.text
                                                                               lastName:lNameField.text];
                                                   }];
        [alert addAction:update];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)updateProfileWithFirstName:(NSString*)fName lastName:(NSString*)lName{
    NSMutableDictionary *currentUserDict = [[defaults_object(CURRENT_USER_KEY) JSONObject] mutableCopy];
    currentUserDict[@"first_name"] = fName;
    currentUserDict[@"last_name"] = lName;
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
            for (NSString *aKey in currentUserDict.allKeys){
                currentUser[aKey] = currentUserDict[aKey];
            }
            [currentUser setCurrent];
            
        }
    }];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2;
}

- (IBAction)profileTapped{
    if ([[CUser currentUser] isPatient] || [[CUser currentUser] isStaff]) {
        PatientProfileController *vc = [PatientProfileController controller];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        DoctorProfileController *vc = [DoctorProfileController controller];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark UICollectionView methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.menuItems.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MenuCell *cell;
    if (indexPath.row == 4 && [[CUser currentUser] isPatient]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AboutMenuCell"
                                                         forIndexPath:indexPath];
    }else{
         cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MenuCell"
                                                          forIndexPath:indexPath];
    }
    
    cell.menuDetails = self.menuItems[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 4 && [[CUser currentUser] isPatient]) {
        return CGSizeMake(kCellWidth * 2, kCellWidth / 3);
    }
    return CGSizeMake(kCellWidth, kCellWidth - 30);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if ([[CUser currentUser] isPatient]) {
        if (indexPath.row == 0) {
            BookAppointmentController *vc = [BookAppointmentController controller];
            vc.isChild = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row == 1) {
            PatientAppointmentsController *vc = [PatientAppointmentsController controller];
            vc.consultation = YES;
            vc.isChild = YES;
            [self.navigationController pushViewController:vc
                                                 animated:YES];
        }else if (indexPath.row == 2) {
            PatientsListController *vc = [PatientsListController controller];
            vc.isChild = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row == 3) {
            PatientAppointmentsController *vc = [PatientAppointmentsController controller];
            vc.consultation = NO;
            vc.isChild = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }else if(indexPath.row == 4) {
            DoctorProfileController *vc = [DoctorProfileController fullProfileController];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else{         
        if (indexPath.row == 0) {
            AppointmentsController *vc = [AppointmentsController controller];
            vc.clashing = NO;
            vc.isChild = YES;
            [self.navigationController pushViewController:vc
                                                 animated:YES];
        }else if (indexPath.row == 1) {
            PatientSelectorController *vc = [PatientSelectorController controller];
            vc.isChild = YES;
            [self.navigationController pushViewController:vc
                                                 animated:YES];
        }else if (indexPath.row == 2) {
            PatientsListController *vc = [PatientsListController controller];
            vc.isChild = YES;
            [self.navigationController pushViewController:vc
                                                 animated:YES];
        }else if (indexPath.row == 3) {
            AppointmentsController *vc = [AppointmentsController clashingController];
            vc.isChild = YES;
            [self.navigationController pushViewController:vc
                                                 animated:YES];
        }
    }
    
    
}



@end
