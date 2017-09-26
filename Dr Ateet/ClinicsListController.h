//
//  ClinicsListController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 08/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "BaseController.h"
#import "Clinic.h"

@protocol ClinicCellDelegate <NSObject>

- (void)deleteClinic:(Clinic*)clinic;

@end

@interface ClinicCell : UITableViewCell

@property (nonatomic, strong) IBOutlet  UILabel     *clinicNameField;
@property (nonatomic, strong) IBOutlet  UILabel     *clinicDetailsField;
@property (nonatomic, strong) IBOutlet  UIView      *container;
@property (nonatomic, strong)           Clinic      *clinic;
@property (nonatomic, strong)           id<ClinicCellDelegate>  delegate;

@end

@interface ClinicsListController : BaseController

@end
