//
//  ChatThread.h
//  Dr Ateet
//
//  Created by Shashank Patel on 30/05/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatThread : NSObject

@property (nonatomic, strong) NSURL     *imageURL;
@property (nonatomic, strong) NSString  *otherPartyName;
@property (nonatomic, strong) NSString  *lastConversationText;

@end
