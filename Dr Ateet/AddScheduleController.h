//
//  AddScheduleController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 18/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DLRadioButton/DLRadioButton.h>
#import <BEMCheckBox/BEMCheckBox.h>
#import "Clinic.h"
#import "Schedule.h"

@interface ScheduleDayCell : UITableViewCell <BEMCheckBoxDelegate>

@property (nonatomic, strong) IBOutlet      UIView          *dayButtonContainer;
@property (nonatomic, strong) IBOutlet      UILabel         *dayLabel;
@property (nonatomic, strong) IBOutlet      UIView          *view1, *view2;
@property (nonatomic, strong) IBOutlet      UIView          *view3, *view4;

@end

@interface AddScheduleController : UIViewController

@property (nonatomic, strong)   Schedule    *schedule;
@property (nonatomic, strong)   NSString    *clinicID,  *clinicName;

@end
