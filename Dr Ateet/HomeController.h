//
//  ViewController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 29/05/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseController.h"

@interface MenuCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet  UIImageView     *menuImageView;
@property (nonatomic, strong) IBOutlet  UILabel         *menuTitleLabel;
@property (nonatomic, strong) IBOutlet  UIView          *container;
@property (nonatomic, strong)           NSDictionary    *menuDetails;

@end

@interface HomeController : BaseController

+ (HomeController*)controller;
+ (UINavigationController *)navigationController;

@end

