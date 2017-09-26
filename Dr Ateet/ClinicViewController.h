//
//  ClinicViewController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 08/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XLForm/XLForm.h>
#import "Clinic.h"

@interface ClinicViewController : XLFormViewController

@property (nonatomic, strong) Clinic    *clinic;

@end
