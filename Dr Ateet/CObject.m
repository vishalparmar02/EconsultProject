//
//  CObject.m
//  Chilap
//
//  Created by Shashank Patel on 14/04/16.
//  Copyright © 2017 Chilap. All rights reserved.
//

#import "CObject.h"

@implementation CObject

- (instancetype)init{
    if (self = [super init]) {
        internalObject = [[NSMutableDictionary alloc] init];
        updateObject = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dict{
    if (self = [self init]) {
        for (NSString *key in dict.allKeys) {
            if([dict[key] isKindOfClass:[NSNull class]]){
                internalObject[key] = @"";
            }else{
                internalObject[key] = dict[key];
            }
            
        }
    }
    return self;
}

- (NSString*)objectId{
    return self[@"id"];
}

- (void)resetDetails:(NSDictionary*)dict{
    for (NSString *key in dict.allKeys) {
        internalObject[key] = dict[key];
    }
}

- (nullable id)objectForKey:(NSString *)key{
    return updateObject[key] ? updateObject[key] : (internalObject[key] ? internalObject[key] : @"");;
}

- (void)setObject:(id)object forKey:(NSString *)key{
    if ([object isKindOfClass:[NSArray class]]) {
        updateObject[key] = [object componentsJoinedByString:@","];
    }else{
        updateObject[key] = object;
    }
}

- (nullable id)objectForKeyedSubscript:(NSString *)key{
    return updateObject[key] ? updateObject[key] : (internalObject[key] ? internalObject[key] : @"");
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key{
    if ([object isKindOfClass:[NSArray class]]) {
        updateObject[key] = [object componentsJoinedByString:@","];
    }else{
        updateObject[key] = object;
    }
}

- (void)deleteInBackgroundWithBlock:(nullable BooleanResultBlock)block{
    NSError *error = [NSError errorWithDomain:@"Local" code:-101 userInfo:@{@"Error" : @"Not implemented yet"}];
    block(NO, error);
}

- (void)updateInBackgroundWithBlock:(nullable BooleanResultBlock)block{
    NSError *error = [NSError errorWithDomain:@"Local" code:-101 userInfo:@{@"Error" : @"Not implemented yet"}];
    block(NO, error);
}

- (void)updateInBackground{
    [self updateInBackgroundWithBlock:nil];
}

- (void)saveInBackgroundWithBlock:(nullable BooleanResultBlock)block{
    NSLog(@"Not implemented");
}

- (void)saveInBackground{
    [self saveInBackgroundWithBlock:nil];
}

@end
