//
//  MenuController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 08/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuCell : UITableViewCell

@property (nonatomic, strong)   IBOutlet    UILabel             *badgeLabel, *menuLabel;
@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint  *badgePaddingConstraint;

- (void)setMenuText:(NSString*)text badge:(NSInteger)badge;


@end

@interface MenuController : UIViewController

+ (id)controller;
- (void)reload;

- (void)bookAppointmentTapped;
- (void)myAppointmentsTapped;
- (void)reportsTapped;

@end
