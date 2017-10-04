//
//  PDFController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 04/10/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Report.h"

@interface PDFController : UIViewController

@property (nonatomic, strong)   Report      *report;

+ (PDFController*)controller;

@end
