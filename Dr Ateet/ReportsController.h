//
//  ReportsController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 24/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "BaseController.h"
#import "Report.h"

@interface ReportCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet  UIImageView     *reportImageView;
@property (nonatomic, strong) IBOutlet  UILabel         *reportLabel;
@property (nonatomic, strong) IBOutlet  UIView          *container;
@property (nonatomic, strong)           Report          *report;

@end

@interface ReportsController : BaseController

@property (nonatomic, strong)   Patient    *patient;

@end
