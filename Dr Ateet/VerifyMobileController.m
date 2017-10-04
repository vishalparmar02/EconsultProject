//
//  VerifyMobileController.m
//  Chilap
//
//  Created by Shashank Patel on 24/03/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "VerifyMobileController.h"
#import "AppDelegate.h"
#import "MenuController.h"
#import "PubNubManager.h"

@interface VerifyMobileController ()

@property (nonatomic, strong)   IBOutlet    UITextField     *OTPField;
@property (nonatomic, strong)   IBOutlet    UIButton        *resendButton;
@property (nonatomic, strong)   IBOutlet    NSTimer         *timer;
@property (nonatomic, strong)   IBOutlet    UILabel         *phoneNumberLabel;
@property (nonatomic)                       NSInteger       timerCounter;

@end

@implementation VerifyMobileController


- (void)viewDidLoad {
    if (TARGET_OS_SIMULATOR) {
        self.OTPField.text = @"1234";
    }
    self.OTPField.delegate = self;
    self.phoneNumberLabel.text = self.mobileNumber;
    [self startResendCounter];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    if(newLength > 6) [textField resignFirstResponder];
    return YES;
}

- (void)startResendCounter{
    [self.resendButton setBackgroundColor:[UIColor grayColor]];
    self.resendButton.enabled = NO;
    self.timerCounter = 30;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(timerTick)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)timerTick{
    self.timerCounter--;
    [UIView setAnimationsEnabled:NO];
    if (self.timerCounter == 0) {
        [self.timer invalidate];
        [self.resendButton setTitle:@"Resend OTP" forState:UIControlStateNormal];
        [self.resendButton setBackgroundColor:[UIColor colorWithHex:0x6FA9D9]];
        self.resendButton.enabled = YES;
    }else{
        [self.resendButton setTitle:[NSString stringWithFormat:@"Resend OTP (%ld)", (long)self.timerCounter] forState:UIControlStateNormal];
    }
    [UIView setAnimationsEnabled:YES];
}

- (IBAction)resendTapped{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [CUser registerMobile:self.mobileNumber inBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!succeeded) {
            [UIAlertController showAlertInViewController:self
                                               withTitle:@"Failed"
                                                 message:@"Please retry"
                                       cancelButtonTitle:@"OK"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:nil
                                                tapBlock:nil];
        }else{
            [self startResendCounter];
        }
    }];
}

- (IBAction)verifyTapped{
    if (self.OTPField.text.length < 4) {
        [UIAlertController showAlertInViewController:self
                                           withTitle:@"Error"
                                             message:@"Please enter a valid OTP"
                                   cancelButtonTitle:@"Ok"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:nil
                                            tapBlock:nil];
        return;
    }
    [CUser verifyMobile:self.mobileNumber OTP:self.OTPField.text inBackgroundWithBlock:^(CUser * _Nullable user, NSError * _Nullable error) {
        if (!error) {
            [PubNubManager updateChannels];
            [[MenuController controller] reload];
            [ApplicationDelegate setController];
        }else{
            [UIAlertController showAlertInViewController:self
                                               withTitle:@"Error"
                                                 message:@"Please enter a valid OTP"
                                       cancelButtonTitle:@"Ok"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:nil
                                                tapBlock:nil];
        }
    }];
}

@end
