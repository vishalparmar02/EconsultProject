//
//  StaffListController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 04/10/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CUser.h"
#import "UIView+Theme.h"
#import "BaseController.h"

@interface StaffCell : UITableViewCell

@property (nonatomic, strong) IBOutlet  UIImageView     *staffImageView;
@property (nonatomic, strong) IBOutlet  UILabel         *titleLabel;
@property (nonatomic, strong) IBOutlet  UILabel         *descriptionLabel;
@property (nonatomic, strong)           CUser           *staff;

@end

@interface StaffListController : BaseController

+ (id)controller;
+ (id)navigationController;

@end
