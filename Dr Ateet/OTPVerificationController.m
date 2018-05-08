//
//  OTPVerificationVC.m
//  Dr Ateet Sharma
//
//  Created by JSH on 02/05/18.
//  Copyright © 2018 Shashank Patel. All rights reserved.
//

#import "OTPVerificationController.h"
#import "SubmitOTPContoller.h"
#import "NetworkManager.h"
#import <EMCCountryPickerController+DialingCodes/EMCCountryPickerController.h>

@interface OTPVerificationVC ()<UITextFieldDelegate, EMCCountryDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtCountryCode;
@property (weak, nonatomic) IBOutlet UITextField *TxtMobilenumber;
@property (weak, nonatomic) IBOutlet UIImageView *countryFlagView;

@end

@implementation OTPVerificationVC

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _txtCountryCode.text = @"+91";
    NSString *countryCode = @"IN";
    NSString *imagePath = [NSString stringWithFormat:@"EMCCountryPickerController.bundle/%@", countryCode];
    NSLog(@"%@",imagePath);
    UIImage *image = [UIImage imageNamed:imagePath inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    
    self.countryFlagView.image = image;
    
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"<Back" style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = newBackButton;
    
    
}


- (void) back:(UIBarButtonItem *)sender
{
    // Perform your custom actions
    // ...
    // Go back to the previous ViewController
    
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"NEWNUM"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"NEWCOUTNRYCODE"];
    
    
    [self.navigationController popViewControllerAnimated:YES];
}



- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.txtCountryCode) {
        [self pickCountry];
    }
    return textField != self.txtCountryCode;
}
- (void)pickCountry{
    EMCCountryPickerController *vc = [[EMCCountryPickerController alloc] init];
    vc.delegate = self;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

- (void)countryController:(EMCCountryPickerController*)sender didSelectCountry:(EMCCountry *)chosenCountry{
    [sender dismissViewControllerAnimated:YES completion:nil];
    NSString *countryCode = [chosenCountry countryCode];
    [[NSUserDefaults standardUserDefaults]setObject:countryCode forKey:@"NEWCOUTNRYCODE"];
    NSString *imagePath = [NSString stringWithFormat:@"EMCCountryPickerController.bundle/%@", countryCode];
    UIImage *image = [UIImage imageNamed:imagePath inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    self.countryFlagView.image = image;
    self.txtCountryCode.text = [chosenCountry dialingCode];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)tapGetOTP:(id)sender {
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *params = @{@"mobile_number" : _TxtMobilenumber.text,
                             @"users_id" : [CUser currentUser].objectId,
                             @"country_code" : _txtCountryCode.text};
    
    
    
    [NetworkManager callBaseURL:API_BASE_URL
                       endPoint:CHANGE_PHONE_END_POINT
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
                                        
                                        [[NSUserDefaults standardUserDefaults]setObject:_TxtMobilenumber.text forKey:@"NEWNUM"];
                                        [[NSUserDefaults standardUserDefaults]setObject:_txtCountryCode.text forKey:@"NEWCOUTNRYCODE"];
                                        
                                        
                                        SubmitOTPVC *vc = ControllerFromMainStoryBoard(@"SubmitOTPVC");
                                        [self.navigationController pushViewController:vc animated:YES];
                                        
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
