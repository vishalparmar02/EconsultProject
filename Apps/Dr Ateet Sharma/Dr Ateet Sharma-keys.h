//
//  Dr Ateet Sharma-keys.h
//  Dr Ateet Sharma
//
//  Created by Shashank Patel on 06/12/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#ifndef Dr_Ateet_Sharma_keys_h
#define Dr_Ateet_Sharma_keys_h

#define DEBUG_PUBLISH_KEY                   @"pub-c-457a7ff0-70b4-46ed-8d40-4d21fabeaf01"
#define DEBUG_SUB_KEY                       @"sub-c-0e556e0a-8e25-11e7-b947-aae040ae6b45"

#define RELEASE_PUBLISH_KEY                 @"pub-c-8a2b71e5-abba-4100-a82f-0b711a688164"
#define RELEASE_SUB_KEY                     @"sub-c-c445e564-7c05-11e7-8bd1-0619f8945a4f"

#define DEBUG_PAY_URL                       @"https://econsult.jshealthtech.com/pay-for-mobile-appointments/%@"
#define RELEASE_PAY_URL                     @"https://consult.drateetsharma.com/pay-for-mobile-appointments/%@"

#define DEBUG_API_URL                       @"http://beta.app.drateetsharma.com/api/v2"
#define RELEASE_API_URL                     @"https://app.drateetsharma.com/api"

#define API_URL                             DEBUG ? DEBUG_API_URL : RELEASE_API_URL

#define APP_NAME                            @"Dr Ateet Sharma"

#endif /* Dr_Ateet_Sharma_keys_h */
