//
//  ReportUploadController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 24/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Report.h"

@interface ReportUploadController : UIViewController

@property (nonatomic, strong)   Report  *report;

+ (id)controller;

@end
