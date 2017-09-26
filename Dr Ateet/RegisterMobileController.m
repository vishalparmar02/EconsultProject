//
//  RegisterMobileController.m
//  Chilap
//
//  Created by Shashank Patel on 24/03/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "RegisterMobileController.h"
#import "VerifyMobileController.h"
#import <SafariServices/SafariServices.h>

@interface RegisterMobileController ()

@property (nonatomic, strong)   IBOutlet    UITextField     *mobileNumberField;
@property (nonatomic, strong)   IBOutlet    UIButton        *nextButton;

@end

@implementation RegisterMobileController

- (void)viewDidLoad {
    if (TARGET_OS_SIMULATOR) {
        self.mobileNumberField.text = @"7600660648";
    }
}

- (void)applyTheme{
    [self.nextButton applyShadow];
    self.view.clipsToBounds = NO;
}

- (IBAction)nextTapped{
    self.nextButton.enabled = NO;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [CUser registerMobile:self.mobileNumberField.text inBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.nextButton.enabled = YES;
        if (succeeded) {
            VerifyMobileController *vc = [VerifyMobileController controller];
            vc.mobileNumber = self.mobileNumberField.text;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [UIAlertController showAlertInViewController:self
                                               withTitle:@"Failed"
                                                 message:@"Please retry"
                                       cancelButtonTitle:@"OK"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:nil
                                                tapBlock:nil];
        }
    }];
}

- (IBAction)tosTapped{
    SFSafariViewController *safariVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"https://www.chilapp.in/terms-conditions"] entersReaderIfAvailable:NO];
    safariVC.delegate = self;
    [self presentViewController:safariVC animated:NO completion:nil];
}

@end
