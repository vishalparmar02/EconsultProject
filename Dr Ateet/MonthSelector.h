//
//  MonthSelector.h
//  Dr Ateet
//
//  Created by Shashank Patel on 06/01/18.
//  Copyright © 2018 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MonthSelectorDelegate
@required
- (void)monthsUpdated:(NSMutableArray*)selectedMonths;

@end

@interface MonthSelector : UITableViewController

@property (nonatomic, strong)   NSMutableArray                  *selectedMonths;
@property (nonatomic, strong)   NSObject<MonthSelectorDelegate> *delegate;

+ (NSArray*)allMonths;

@end
