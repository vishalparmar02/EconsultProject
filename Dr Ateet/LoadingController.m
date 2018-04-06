//
//  LoadingController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 06/04/18.
//  Copyright © 2018 Shashank Patel. All rights reserved.
//

#import "LoadingController.h"

@interface LoadingController ()

@property (nonatomic, strong) IBOutlet  UIImageView *loadingImageView;

@end

@implementation LoadingController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loadingImageView.image = [UIImage imageNamed:@"loading"];
    self.loadingImageView.backgroundColor = BACKGROUND_COLOR;
}

@end
