//
//  AppDelegate.m
//  Dr Ateet
//
//  Created by Shashank Patel on 29/05/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "AppDelegate.h"
#import "CUser.h"
#import "HomeController.h"
#import "MenuController.h"
#import "RegisterMobileController.h"
#import "RTCPeerConnectionFactory.h"
#import "ARTCVideoChatViewController.h"
#import "PubNubManager.h"
#import "CallController.h"
#import "Notification.h"
#import "APIManager.h"

@import LNRSimpleNotifications;


@interface AppDelegate ()

@property (nonatomic)           UIBackgroundTaskIdentifier bgTask;
@property (nonatomic, strong) UIViewController    *loadingController;

@end

@implementation AppDelegate


- (void)tryForPushNotification{
    static BOOL tried = NO;
    if (tried) {
        return;
    }
    tried = YES;
    NSDictionary *pushNotificationsDetails = defaults_object(PushNotificationDetailsKey);
    NSObject *deviceToken = defaults_object(DEVICE_TOKEN);
    
    if(!TARGET_OS_SIMULATOR){
        if(!deviceToken){
            if(pushNotificationsDetails){
                NSDate *askedDate = [NSDate dateWithTimeIntervalSince1970:[pushNotificationsDetails[@"timestamp"] doubleValue]];
                if (fabs([[NSDate date] timeIntervalSinceDate:askedDate]) > (3 * 24 * 60 * 60)) {
                    [self registerForPushNotifications];
                }
            }else{
                [self registerForPushNotifications];
            }
        }
    }
}



- (void)registerForPushNotifications{
    NSString *message = [NSString stringWithFormat:@"Get the most out of %@ App by allowing notifications in the next alert.", APP_NAME];
    [UIAlertController showAlertInViewController:self.window.rootViewController
                                       withTitle:@"Important"
                                         message:message
                               cancelButtonTitle:@"Maybe later"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@[@"OK"]
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            if (buttonIndex != controller.cancelButtonIndex) {
                                                UIUserNotificationType types = UIUserNotificationTypeBadge |
                                                UIUserNotificationTypeSound;
                                                
                                                UIUserNotificationSettings *mySettings =
                                                [UIUserNotificationSettings settingsForTypes:types categories:nil];
                                                
                                                [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
                                                [[UIApplication sharedApplication] registerForRemoteNotifications];
                                            }else{
                                                NSDictionary *pushNotificationsDetails = @{@"timestamp" : @([[NSDate date] timeIntervalSince1970])};
                                                defaults_set_object(PushNotificationDetailsKey, pushNotificationsDetails);
                                            }
                                        }];
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"API: %@", API_URL);
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
    [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    
    NSDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notification) {
        DDLogVerbose(@"app recieved notification from remote%@",notification);
        [self performSelector:@selector(handleNotification:) withObject:notification afterDelay:0.2];
    }else{
        DDLogVerbose(@"app did not recieve notification");
    }
    
    self.loadingController = ControllerFromStoryBoard(@"Main", @"LoadingController");
    [self makeDrawer];
    [RTCPeerConnectionFactory initializeSSL];
    
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    DDLogVerbose(@"Ateet:Resign active");
    self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    DDLogVerbose(@"Ateet:Did enter background");
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    DDLogVerbose(@"Ateet:Will Enter Foreground");
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    DDLogVerbose(@"Ateet:Become Active");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self setController];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    DDLogVerbose(@"Ateet:Will Terminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[PubNubManager sharedManager] setOffline];
    [RTCPeerConnectionFactory deinitializeSSL];
}



- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    return;
    DDLogVerbose(@"deviceToken: %@", deviceToken);
    
    NSData *oldToken = [[NSUserDefaults standardUserDefaults] dataForKey:@"DeviceToken"];
    if (oldToken && [oldToken isEqualToData:deviceToken]) {
        return;
    }
    
    
//    NSString *token = [[NSString alloc] initWithData:deviceToken encoding:NSUTF8StringEncoding];
    NSString *token = [[[[deviceToken description]
                         stringByReplacingOccurrencesOfString: @"<" withString: @""]
                        stringByReplacingOccurrencesOfString: @">" withString: @""]
                       stringByReplacingOccurrencesOfString: @" " withString: @""];
    DDLogVerbose(@"P Token: %@", token);
    
    // remove old token from all PubNub channels for push notifications
    [[PubNubManager sharedManager].client removeAllPushNotificationsFromDeviceWithPushToken:oldToken
                                                                              andCompletion:^(PNAcknowledgmentStatus *status) {
                                                                                  DDLogVerbose(@"status: %@", status);
                                                                              }];
    
    defaults_set_object(DEVICE_TOKEN, deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DDLogVerbose(@"%s with error: %@", __PRETTY_FUNCTION__, error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    if([UIApplication sharedApplication].applicationState != UIApplicationStateActive){
        [self handleNotification:userInfo];
    }else{
    }
    DDLogVerbose(@"Got notification");
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    DDLogVerbose(@"Got local notification");
    if([UIApplication sharedApplication].applicationState != UIApplicationStateActive){
        [self handleLocalNotification:notification.userInfo];
    }else{
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler{
    DDLogVerbose(@"Swilent notification: %@", userInfo.description);
    
    if([UIApplication sharedApplication].applicationState != UIApplicationStateActive){
        NSDictionary *JSON = userInfo[@"aps"][@"call_payload"];
        
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        notification.userInfo = userInfo;
        [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
        notification.soundName = @"ring.wav";
        [notification setAlertBody:JSON[@"description"]];
        NSString *type = JSON[@"type"];
        if ([type isEqualToString:@"v_call"]) {
            [[CallController sharedController] reportCall:JSON];
//            [application setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
        }
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler{
    DDLogVerbose(@"Fetch");
}

- (void)handleNotification:(NSDictionary*)userInfo{
    NSDictionary *aps = userInfo[@"aps"];
    NSDictionary *JSON = aps[@"call_payload"];
    
    if (!JSON) {
        JSON = JSON[@"json_data"];
    }
    
    DDLogVerbose(@"Notification:%@", [userInfo description]);
}

- (void)handleLocalNotification:(NSDictionary*)userInfo{
    NSDictionary *JSON;
    if (userInfo[@"aps"] != nil) {
         JSON = userInfo[@"aps"][@"call_payload"];
    }else{
        JSON = userInfo;
    }
    DDLogVerbose(@"Local Notification:%@", [userInfo description]);
}

- (void)makeDrawer{
    MSDynamicsDrawerShadowStyler *shadowStyler = [MSDynamicsDrawerShadowStyler new];
    shadowStyler.shadowColor = [UIColor grayColor];
    shadowStyler.shadowRadius = 20;
    shadowStyler.shadowOffset = CGSizeMake(10, 10);
    
    MSDynamicsDrawerParallaxStyler *parallaxStyler = [MSDynamicsDrawerParallaxStyler new];
    MSDynamicsDrawerFadeStyler *fadeStyler = [MSDynamicsDrawerFadeStyler new];
    
    self.drawerController = [[MSDynamicsDrawerViewController alloc] init];
    [self.drawerController addStyler:shadowStyler forDirection:MSDynamicsDrawerDirectionLeft];
    [self.drawerController addStyler:parallaxStyler forDirection:MSDynamicsDrawerDirectionLeft];
    [self.drawerController addStyler:fadeStyler forDirection:MSDynamicsDrawerDirectionLeft];
    
    UIViewController *paneViewController = [HomeController navigationController];
    self.drawerController.paneViewController = paneViewController;
    [self.drawerController setDrawerViewController:[MenuController controller] forDirection:MSDynamicsDrawerDirectionLeft];
    
    
    
}

- (void)toggleMenu
{
    
    
    [self.drawerController setPaneState:!self.drawerController.paneState
                            inDirection:MSDynamicsDrawerDirectionLeft
                               animated:YES
                  allowUserInterruption:NO
                             completion:nil];
}


- (void)setController
{
    
    if (![APIManager sharedManager].ready) {
      self.window.rootViewController = self.loadingController;
        [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:NO block:^(NSTimer * _Nonnull timer) {
            [self setController];
        }];
        return;
    }
    if ([CUser currentUser]) {
        self.window.rootViewController = self.drawerController;
    }else{
        if(self.window.rootViewController){
            UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
            if ([navController isKindOfClass:[UINavigationController class]]) {
                if([navController.viewControllers[0] isKindOfClass:[RegisterMobileController class]]){
                    return;
                }
            }
        }
        self.window.rootViewController = [RegisterMobileController navigationController];
    }
    [self tryForPushNotification];
}


- (void)showNotificationWithTitle:(NSString*)title description:(NSString*)description{
    static LNRNotificationManager *notificationsManager;
    if (!notificationsManager) {
        notificationsManager = [[LNRNotificationManager alloc] init];
        notificationsManager.notificationsTitleTextColor = [UIColor whiteColor];
        notificationsManager.notificationsBodyTextColor = [UIColor whiteColor];
        notificationsManager.notificationsTitleFont = [UIFont fontWithName:@"OpenSans-SemiBold" size:25];
        notificationsManager.notificationsBodyFont = [UIFont fontWithName:@"OpenSans-SemiBold" size:20];
    }
    
    notificationsManager.notificationsBackgroundColor = [UIColor orangeColor];
    LNRNotification *notification = [[LNRNotification alloc] initWithTitle:title
                                                                      body:description
                                                                  duration:3
                                                                     onTap:nil
                                                                 onTimeout:nil];
    [notificationsManager showNotificationWithNotification:notification];
    
}

- (UINavigationController*)currentNavigationController{
    return _drawerController.paneViewController;
}


@end
