//
//  SlotCell.m
//  Dr Ateet
//
//  Created by Shashank Patel on 05/09/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "SlotCell.h"

@implementation SlotCell

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.container applyShadow];
    self.container.layer.cornerRadius = 10;
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (void)setSlot:(Slot *)slot{
    _slot = slot;
    self.slotTimeLabel.text = [slot startTime];
    if ([slot hasPassedForDate:self.date]) {
        self.container.backgroundColor = [UIColor colorWithHex:0xAAAAAA];
    }else if ([slot[@"book"] boolValue]) {
        self.container.backgroundColor = [UIColor colorWithHex:0xFF333A];
    }else{
        self.container.backgroundColor = [UIColor colorWithHex:0x22BF64];
    }
}

@end

