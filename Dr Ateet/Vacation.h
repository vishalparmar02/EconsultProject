//
//  Vacation.h
//  Dr Ateet
//
//  Created by Shashank Patel on 31/10/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "CObject.h"

@interface Vacation : CObject

+ (void)fetchVacationsInBackgroundWithBlock:(nullable ArrayResultBlock)block;

@end
