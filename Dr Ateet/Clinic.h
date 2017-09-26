//
//  Clinic.h
//  Dr Ateet
//
//  Created by Shashank Patel on 08/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "CObject.h"

@interface Clinic : CObject

+ (void)fetchClinicsInBackgroundWithBlock:(nullable ArrayResultBlock)block;
- (void)forceDeleteInBackgroundWithBlock:(nullable BooleanResultBlock)block;

@end
