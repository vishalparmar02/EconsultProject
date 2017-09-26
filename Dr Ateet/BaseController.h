//
//  BaseController.h
//  Chilap
//
//  Created by Shashank Patel on 24/03/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseController : UIViewController

@property (nonatomic)         BOOL          isChild;

+ (id)controller;
+ (id)navigationController;

- (void)menuTapped;

@end
