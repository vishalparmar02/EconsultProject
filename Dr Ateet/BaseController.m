//
//  BaseController.m
//  Chilap
//
//  Created by Shashank Patel on 24/03/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "BaseController.h"

@interface BaseController ()

@property (nonatomic, strong)  UIButton     *pointsButton;

@end

@implementation BaseController

+ (id)controller{
    return ControllerFromMainStoryBoard([self description]);
}

+ (id)navigationController{
    return [[UINavigationController alloc] initWithRootViewController:[self controller]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self applyTheme];
    [self addNavigationButtons];
}

- (void)applyTheme{
    
}

- (void)addNavigationButtons{
    if (!self.isChild) {
        UIButton *menuIcon = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        [menuIcon setImage:[UIImage imageNamed:@"menu_icon.png"] forState:UIControlStateNormal];
        menuIcon.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [menuIcon addTarget:self action:@selector(menuTapped) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuIcon];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)menuTapped{
    [ApplicationDelegate toggleMenu];
}

@end
