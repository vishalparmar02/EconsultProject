//
//  PatientsListController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 22/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Patient.h"
#import "UIView+Theme.h"
#import "BaseController.h"

@interface PatientCell : UITableViewCell

@property (nonatomic, strong) IBOutlet  UIImageView     *patientImageView;
@property (nonatomic, strong) IBOutlet  UILabel         *titleLabel;
@property (nonatomic, strong) IBOutlet  UILabel         *descriptionLabel;
@property (nonatomic, strong)           Patient         *patient;

@end

@interface PatientsListController : BaseController

+ (id)controller;
+ (id)navigationController;

@end
