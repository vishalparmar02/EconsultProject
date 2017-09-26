//
//  ChatThread.m
//  Dr Ateet
//
//  Created by Shashank Patel on 30/05/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "ChatThread.h"

@implementation ChatThread

- (NSString*)otherPartyName{
    return @"Shashank Patel";
}

- (NSString*)lastConversationText{
    return @"Ok I will do my MRI and send you on this chat.";
}

- (NSURL*)imageURL{
    return [NSURL URLWithString:@"https://res.cloudinary.com/dzwbe98ep/image/upload/dummy-photo"];
}

@end
