//
//  PatientInfoController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 22/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Patient.h"

@interface PatientInfoController : UIViewController

@property (nonatomic, strong)   Patient     *patient;

+ (id)controller;

@end
