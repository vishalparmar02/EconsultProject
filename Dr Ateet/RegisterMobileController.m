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
#import <EMCCountryPickerController+DialingCodes/EMCCountryPickerController.h>

@interface RegisterMobileController ()<UITextFieldDelegate, EMCCountryDelegate>

@property (nonatomic, strong)   IBOutlet    UITextField     *countryCodeField, *mobileNumberField;
@property (nonatomic, strong)   IBOutlet    UIImageView     *countryFlagView;
@property (nonatomic, strong)   IBOutlet    UIButton        *nextButton;
@end

@implementation RegisterMobileController

- (void)viewDidLoad {
    if (TARGET_OS_SIMULATOR) {
        self.mobileNumberField.text = @"9574007979";
        NSString *countryCode = @"IN";
        NSString *imagePath = [NSString stringWithFormat:@"EMCCountryPickerController.bundle/%@", countryCode];
        UIImage *image = [UIImage imageNamed:imagePath inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        
        self.countryFlagView.image = image;
        self.countryCodeField.text = @"+91";
    }else if(DEBUG){
        self.mobileNumberField.text = @"7600660648";
        NSString *countryCode = @"IN";
        NSString *imagePath = [NSString stringWithFormat:@"EMCCountryPickerController.bundle/%@", countryCode];
        UIImage *image = [UIImage imageNamed:imagePath inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        
        self.countryFlagView.image = image;
        self.countryCodeField.text = @"+91";
    }
    self.mobileNumberField.delegate = self;
}

- (void)applyTheme{
    [self.nextButton applyShadow];
    self.view.clipsToBounds = NO;
}

- (IBAction)nextTapped{
    self.nextButton.enabled = NO;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [CUser registerMobile:self.mobileNumberField.text country:self.countryCodeField.text
    inBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.nextButton.enabled = YES;
        if (succeeded) {
            VerifyMobileController *vc = [VerifyMobileController controller];
            vc.mobileNumber = self.mobileNumberField.text;
            vc.countryCode = self.countryCodeField.text;
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

- (void)pickCountry{
    EMCCountryPickerController *vc = [[EMCCountryPickerController alloc] init];
    vc.delegate = self;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

- (void)countryController:(EMCCountryPickerController*)sender didSelectCountry:(EMCCountry *)chosenCountry{
    [sender dismissViewControllerAnimated:YES completion:nil];
    NSString *countryCode = [chosenCountry countryCode];
    NSString *imagePath = [NSString stringWithFormat:@"EMCCountryPickerController.bundle/%@", countryCode];
    UIImage *image = [UIImage imageNamed:imagePath inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    self.countryFlagView.image = image;
    self.countryCodeField.text = [chosenCountry dialingCode];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.countryCodeField) {
        [self pickCountry];
    }
    return textField != self.countryCodeField;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    if(newLength > 10) [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)tosTapped{
    SFSafariViewController *safariVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"https://consult.drateetsharma.com/term-conditions"] entersReaderIfAvailable:NO];
    safariVC.delegate = self;
    [self presentViewController:safariVC animated:NO completion:nil];
}

@end
