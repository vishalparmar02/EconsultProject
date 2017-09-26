//
//  ReportsController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 24/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "ReportsController.h"
#import <IDMPhotoBrowser/IDMPhotoBrowser.h>
#import "UIImage+FixRotation.h"
#import "ReportUploadController.h"

#define kCellWidth ((CGRectGetWidth(collectionView.frame) / 2) - 0)

@implementation ReportCell

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.container applyShadow];
    self.container.layer.cornerRadius = 10;
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (void)setReport:(Report *)report{
    _report = report;
    self.reportLabel.text = [report[@"description"] capitalizedString];
    [self.reportImageView sd_setImageWithURL:[report reportImageURL]
                            placeholderImage:nil
                                     options:SDWebImageProgressiveDownload];
}

@end

@interface ReportsController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet  UICollectionView    *collectionView;
@property (nonatomic, strong) IBOutlet  UISegmentedControl  *reportTypeSegment;
@property (nonatomic, strong)           NSArray             *reports, *patientReports, *doctorReports;
@property (nonatomic, strong)           Report              *reportToUpload;

@end

@implementation ReportsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"Reports";
    if ([[CUser currentUser] isPatient]) {
        self.patientID = [CUser currentUser][@"patient_id"];
    }
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    layout.minimumLineSpacing = 0.0;
    layout.minimumInteritemSpacing = 0.0;
    self.collectionView.collectionViewLayout = layout;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Upload"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(uploadTapped)];
    
    if (self.isChild && (self.isBeingPresented || self.navigationController.isBeingPresented)) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                                 style:UIBarButtonItemStyleDone
                                                                                target:self
                                                                                action:@selector(doneTapped)];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self fetchReports];
}

- (void)doneTapped{
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
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
                                 [self showImagePickerForIndex:0];
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
    self.reportToUpload = [Report new];
    self.reportToUpload.patientID = self.patientID;
    self.reportToUpload.reportImage = image;
    [self proceedToReportDetails];
    
//    ReportUploadController *vc = [ReportUploadController controller];
//    vc.report = self.reportToUpload;
//    [picker pushViewController:vc animated:YES];
}

- (void)proceedToReportDetails{
    UIAlertController *alert=   [UIAlertController
                                  alertControllerWithTitle:@"Add Description"
                                  message:nil
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Upload"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             UITextField *descriptionTextField = alert.textFields[0];
                             self.reportToUpload.reportDescription = descriptionTextField.text;
                             [self uploadReport];
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"e.g. X-Ray";
    }];
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
}


- (void)uploadReport{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.reportToUpload saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([[CUser currentUser] isPatient]) {
            self.reportTypeSegment.selectedSegmentIndex = 0;
        }else{
            self.reportTypeSegment.selectedSegmentIndex = 1;
        }
        [self fetchReports];
    }];
}

- (void)fetchReports{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [Report fetchReportsForPatientID:self.patientID
               inBackgroundWithBlock:^(NSArray *doctorReports, NSArray *patientReports, NSError * _Nullable error) {
                   [MBProgressHUD hideHUDForView:self.view
                                        animated:YES];
                   if (!error) {
                       self.patientReports = patientReports;
                       self.doctorReports = doctorReports;
                       self.reports = self.reportTypeSegment.selectedSegmentIndex == 0 ? self.patientReports : self.doctorReports;
                       [self.collectionView reloadData];
                   }
    }];
}

- (IBAction)segmentChanged{
    self.reports = self.reportTypeSegment.selectedSegmentIndex == 0 ? self.patientReports : self.doctorReports;
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.reports.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ReportCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ReportCell" forIndexPath:indexPath];
    cell.report = self.reports[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(kCellWidth, kCellWidth);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    ReportCell *cell = (ReportCell*)[collectionView cellForItemAtIndexPath:indexPath];
    IDMPhoto *photo = [IDMPhoto photoWithImage:cell.reportImageView.image];
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo] animatedFromView:cell.reportImageView];
    [self presentViewController:browser animated:YES completion:nil];
}


@end
