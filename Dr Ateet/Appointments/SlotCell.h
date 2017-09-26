//
//  SlotCell.h
//  Dr Ateet
//
//  Created by Shashank Patel on 05/09/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Slot.h"
#define kSlotCellWidth ((CGRectGetWidth(collectionView.frame) / 4) - 0)

@interface SlotCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet  UILabel         *slotTimeLabel;
@property (nonatomic, strong) IBOutlet  UIView          *container;
@property (nonatomic, strong)           Slot            *slot;
@property (nonatomic, strong)           NSDate          *date;

@end
