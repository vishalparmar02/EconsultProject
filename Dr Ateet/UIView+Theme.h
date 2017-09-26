//
//  UIView+Theme.h
//  user
//
//  Created by Shashank Patel on 20/10/16.
//  Copyright © 2016 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Theme)

- (void)makeCircular;
- (void)applyShadow;
- (void)applyDarkShadow;
- (void)removeShadow;
- (void)addBorder;
- (void)addBorder:(UIColor*)color width:(CGFloat)width;
- (void)removeBorder;
- (void)addRoundedBorderOnTop;
- (void)addRoundedBorderOnBottom;
- (void)roundLeft:(CGFloat)radius;

@end
