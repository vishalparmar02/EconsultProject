//
//  AppDelegate.h
//  Dr Ateet
//
//  Created by Shashank Patel on 29/05/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MSDynamicsDrawerViewController/MSDynamicsDrawerViewController.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) MSDynamicsDrawerViewController    *drawerController;

- (void)setController;
- (void)toggleMenu;
- (void)showNotificationWithTitle:(NSString*)title description:(NSString*)description;

@end

