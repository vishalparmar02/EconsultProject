//
//  SubmitOTPVC.m
//  Dr Ateet Sharma
//
//  Created by JSH on 02/05/18.
//  Copyright © 2018 Shashank Patel. All rights reserved.
//

#import "SubmitOTPContoller.h"
#import "NetworkManager.h"
#import "HomeController.h"
#import "OTPVerificationController.h"
#import "PatientProfileController.h"
#import "MenuController.h"
@interface SubmitOTPVC ()



@property (weak, nonatomic) IBOutlet UITextField *TxtOtp;
@property (weak, nonatomic) IBOutlet UIButton *reendButton;
@property (nonatomic)NSInteger  timerCounter;
@property (nonatomic, strong)   IBOutlet    NSTimer *timer;
- (IBAction)resendTapped:(id)sender;


@end




@implementation SubmitOTPVC



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"<Back" style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = newBackButton;
    
    [self startResendCounter];
}

- (void)startResendCounter{
    [self.reendButton setBackgroundColor:[UIColor grayColor]];
    self.reendButton.enabled = NO;
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
        [self.reendButton setTitle:@"Resend OTP" forState:UIControlStateNormal];
        [self.reendButton setBackgroundColor:[UIColor colorWithHex:0x6FA9D9]];
        self.reendButton.enabled = YES;
    }else{
        [self.reendButton setTitle:[NSString stringWithFormat:@"Resend OTP (%ld)", (long)self.timerCounter] forState:UIControlStateNormal];
    }
    
    [UIView setAnimationsEnabled:YES];
}


- (void) back:(UIBarButtonItem *)sender {
    // Perform your custom actions
    // ...
    // Go back to the previous ViewController
    
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"NEWNUM"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"NEWCOUTNRYCODE"];
    
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)submitTap:(id)sender {
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *params = @{@"users_id" : [CUser currentUser].objectId,
                             @"otp" : _TxtOtp.text};
    
    
    
    [NetworkManager callBaseURL:API_BASE_URL
                       endPoint:VERIFY_OTP_END
                        headers:nil
                       withDict:params
                         method:@"POST"
                           JSON:NO
                        success:^(id  _Nonnull responseObject) {
                            NSLog(@"%@",[responseObject description]);
                        
                            if ([responseObject[@"status"] integerValue] == 1)
                            {
                                [MBProgressHUD hideHUDForView:self.view animated:true];
                                
                                [UIAlertController showAlertInViewController:self withTitle:@"Success" message:responseObject[@"message"] cancelButtonTitle:@"Ok" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                               
                                    
                                    
                                    
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        NSString *strfromsidebar = [[NSUserDefaults standardUserDefaults] valueForKey:@"FROMSIDEBAR"];
                                        NSLog(@"%@",strfromsidebar);
                                        
                                        if ([strfromsidebar isEqualToString:@"YES"])
                                        {
                                            NSArray *array = [self.navigationController viewControllers];
                                            [self.navigationController popToViewController:[array objectAtIndex:0] animated:YES];
                                        }
                                        else
                                        {
                                            NSArray *array = [self.navigationController viewControllers];
                                            [self.navigationController popToViewController:[array objectAtIndex:1] animated:YES];
                                        }
                                    
                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadForm" object:nil];

                                        
                                    });
                                }];
                                
                            }
                            else
                            {
                                 [MBProgressHUD hideHUDForView:self.view animated:true];
                                [UIAlertController showAlertInViewController:self withTitle:@"Error" message:responseObject[@"message"] cancelButtonTitle:@"Ok" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                    
                                }];
                            }
                            
                            
                            
                        } failure:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
                            NSLog(@"%@",[responseObject description]);
                            [error printHTMLError];
                        }];
    


}

- (IBAction)resendTapped:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *Mobnum = [[NSUserDefaults standardUserDefaults] valueForKey:@"NEWNUM"];
    NSString *Ccode = [[NSUserDefaults standardUserDefaults] valueForKey:@"NEWCOUTNRYCODE"];
    
    [CUser registerMobile:Mobnum country:Ccode
    inBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
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
@end
