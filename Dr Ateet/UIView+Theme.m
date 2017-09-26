//
//  UIView+Theme.m
//  user
//
//  Created by Shashank Patel on 20/10/16.
//  Copyright © 2016 iOS. All rights reserved.
//

#import "UIView+Theme.h"

@implementation UIView (Theme)

- (void)makeCircular{
    self.layer.cornerRadius = self.frame.size.width / 2;
}

- (void)applyShadow{
    self.layer.masksToBounds = NO;
//    self.layer.cornerRadius = self.frame.size.width / 2;
//    self.layer.cornerRadius = 5;
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowRadius = 5.0;
    self.layer.shadowOffset = CGSizeMake(0, 3.0);
    self.layer.shadowOpacity = 0.75;
}

- (void)applyDarkShadow{
    self.layer.masksToBounds = NO;
    //    self.layer.cornesrRadius = self.frame.size.width / 2;
    self.layer.cornerRadius = 5;
    self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.layer.shadowRadius = 5.0;
    self.layer.shadowOffset = CGSizeMake(0, 3.0);
    self.layer.shadowOpacity = 0.75;
}

- (void)removeShadow{
    self.layer.masksToBounds = NO;
    self.layer.cornerRadius = 0;
    self.layer.shadowColor = [UIColor clearColor].CGColor;
    self.layer.shadowRadius = 0.0;
    self.layer.shadowOffset = CGSizeMake(0, 0.0);
    self.layer.shadowOpacity = 0.0;
    
}

- (void)addBorder{
    self.layer.borderWidth  = 1;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)addBorder:(UIColor*)color width:(CGFloat)width{
    self.layer.borderWidth  = width;
    self.layer.borderColor = color.CGColor;
}

- (void)addRoundedBorderOnTop{
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                     byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                           cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = borderPath.CGPath;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    shapeLayer.lineWidth = 1;
    
    [self.layer addSublayer:shapeLayer];
}

- (void)addRoundedBorderOnBottom{
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                     byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                           cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = borderPath.CGPath;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    shapeLayer.lineWidth = 1;
    
    [self.layer addSublayer:shapeLayer];
}

- (void)roundLeft:(CGFloat)radius{
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                     byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft
                                                           cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = borderPath.CGPath;
    shapeLayer.fillColor = [UIColor redColor].CGColor;
    shapeLayer.lineWidth = 1;
    self.layer.mask = shapeLayer;
    self.clipsToBounds = YES;
}


- (void)removeBorder{
    self.layer.borderWidth  = 0;
    self.layer.borderColor = [UIColor clearColor].CGColor;
    for (CALayer *sublayer in self.layer.sublayers) {
        if ([sublayer isKindOfClass:[CAShapeLayer class]]) {
            [sublayer removeFromSuperlayer];
        }
    }
}

@end
