//
//  CUser.h
//  Chilap
//
//  Created by Shashank Patel on 14/04/16.
//  Copyright © 2017 Chilap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CObject.h"
#import "Patient.h"

@interface CUser : CObject

@property (nonatomic, strong, nonnull)  NSString    *mobile, *authHeader, *firstName, *lastName;
@property (nonatomic, strong, nonnull)  UIImage     *image;

typedef void (^UserResultBlock)(CUser *_Nullable user, NSError *_Nullable error);

+ (nullable CUser*)currentUser;
+ (void)logOut;
+ (void)registerMobile:(nonnull NSString *)phone
               country:(NSString*)country
 inBackgroundWithBlock:(nullable BooleanResultBlock)block;
+ (void)verifyMobile:(nonnull NSString *)phone country:(NSString*)country
                 OTP:(NSString*)OTP inBackgroundWithBlock:(nullable UserResultBlock)block;
+ (void)fetchDoctorProfileInBackgroundWithBlock:(DictionaryResultBlock)block;

- (void)setCurrent;


- (void)saveInBackgroundWithBlock:(nullable BooleanResultBlock)block;
- (void)saveInBackground;
- (void)saveFirstName:(NSString*)fName lastName:(NSString*)lName InBackgroundWithBlock:(BooleanResultBlock)block;
- (void)updateProfileImageInBackgroundWithBlock:(nullable BooleanResultBlock)block;
- (void)fetchMyPatientsInBackgroundWithBlock:(nullable ArrayResultBlock)block;
- (void)fetchMyStaffInBackgroundWithBlock:(nullable ArrayResultBlock)block;
- (void)addStaff:(NSDictionary*) staff withBlock:(nullable BooleanResultBlock)block;
- (void)deleteStaffInBackgroundWithBlock:(nullable BooleanResultBlock)block;


- (NSURL*)profileImageURL;
- (BOOL)isPatient;
- (BOOL)isStaff;
- (BOOL)isDoctor;
- (NSString*)fullName;
- (Patient*)patient;

@end
