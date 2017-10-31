//
//  MyVacationController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 31/10/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseController.h"
#import "Vacation.h"

@protocol VacationCellDelegate <NSObject>

- (void)deleteVacation:(Vacation*)vacation;

@end

@interface VacationCell : UITableViewCell

@property (nonatomic, strong) IBOutlet  UILabel     *vacationNameField;
@property (nonatomic, strong) IBOutlet  UILabel     *vacationDetailsField;
@property (nonatomic, strong) IBOutlet  UIView      *container;
@property (nonatomic, strong)           Vacation      *vacation;
@property (nonatomic, strong)           id<VacationCellDelegate>  delegate;

@end

@interface MyVacationController : BaseController

@end
