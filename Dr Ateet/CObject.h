//
//  CMObject.h
//  Chroma
//
//  Created by Shashank Patel on 14/04/16.
//  Copyright © 2016 Themeefy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DeviceInfo.h"

@interface CObject : NSObject{
    
    NSMutableDictionary *internalObject, *updateObject;
}


@property (nullable, nonatomic, strong) NSString *objectId;


typedef void (^BooleanResultBlock)(BOOL succeeded, NSError *_Nullable error);
typedef void (^StringResultBlock)(NSString *responseString, NSError *_Nullable error);
typedef void (^ArrayResultBlock)(NSArray *_Nullable objects, NSError *_Nullable error);
typedef void (^DictionaryResultBlock)(NSDictionary *_Nullable object, NSError *_Nullable error);



- (nullable instancetype)initWithDictionary:(nonnull NSDictionary*)dict;
- (void)resetDetails:(nonnull NSDictionary*)dict;
- (nullable id)objectForKeyedSubscript:(nonnull NSString *)key;
- (void)setObject:(nullable id)object forKeyedSubscript:(nonnull NSString *)key;

- (void)updateInBackgroundWithBlock:(nullable BooleanResultBlock)block;
- (void)updateInBackground;
- (void)saveInBackgroundWithBlock:(nullable BooleanResultBlock)block;
- (void)saveInBackground;
- (void)deleteInBackgroundWithBlock:(nullable BooleanResultBlock)block;


@end
