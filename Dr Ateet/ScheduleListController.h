//
//  ScheduleListController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 09/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "BaseController.h"
#import "Schedule.h"

@protocol ScheduleCellDelegate <NSObject>

- (void)deleteSchedule:(Schedule*)schedule;

@end

@interface ScheduleCell : UITableViewCell

@property (nonatomic, strong) IBOutlet  UILabel     *scheduleNameLabel;
@property (nonatomic, strong) IBOutlet  UILabel     *scheduleDetailsLabel;
@property (nonatomic, strong) IBOutlet  UILabel     *timePerPatientLabel;

@property (nonatomic, strong) IBOutlet  NSLayoutConstraint  *detailsHeight;

@property (nonatomic, strong) IBOutlet  UIView      *container;
@property (nonatomic, strong)           Schedule    *schedule;
@property (nonatomic, strong)           id<ScheduleCellDelegate>    delegate;

@end

@interface ScheduleListController : BaseController

@end
