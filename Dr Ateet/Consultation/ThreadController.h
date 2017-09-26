//
//  ThreadController.h
//  Dr Ateet
//
//  Created by Shashank Patel on 30/05/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatThread.h"

@interface ThreadCell : UITableViewCell

@property (nonatomic, strong) IBOutlet  UIImageView     *threadImageView;
@property (nonatomic, strong) IBOutlet  UILabel         *titleLabel;
@property (nonatomic, strong) IBOutlet  UILabel         *descriptionLabel;
@property (nonatomic, strong)           ChatThread      *chatThread;

@end

@interface ThreadController : UITableViewController

+ (ThreadController*)controller;

@end
