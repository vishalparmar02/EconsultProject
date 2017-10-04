//
//  CallController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 30/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "CallController.h"
#import "AppDelegate.h"
#import "ARTCVideoChatViewController.h"
#import "PubNubManager.h"
#import <CallKit/CallKit.h>
#import <PushKit/PushKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CallController ()<CXProviderDelegate>{
    AVAudioPlayer *ringPlayer;
}

@property (nonatomic, strong) IBOutlet  UIButton    *answerButton, *rejectButton;
@property (nonatomic, strong) IBOutlet  UILabel     *callDetailLabel;
@property (nonatomic, strong)           ARTCVideoChatViewController     *videoChatController;
@property (nonatomic, strong)           CXProvider              *callKitProvider;
@property (nonatomic, strong)           CXCallController        *callKitCallController;
@property (nonatomic, strong)           PKPushRegistry          *voipRegistry;

@end

@implementation CallController

+ (void)load{
    [self sharedController];
}

+ (instancetype)sharedController{
    static dispatch_once_t onceToken;
    static CallController *controller;
    dispatch_once(&onceToken, ^{
        controller = ControllerFromStoryBoard(@"Main", @"CallController");
    });
    
    return controller;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callReceived:) name:@"INCOMING_CALL_NOTIFICATION"
                                               object:nil];
    
    NSURL *ringURL = [[NSBundle mainBundle] URLForResource:@"ring" withExtension:@"wav"];
    
    ringPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:ringURL error:NULL];
    
    [self configureCallKit];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    self.answerButton.layer.cornerRadius = 50;
    [self.answerButton applyShadow];
    [self.answerButton addBorder:[UIColor whiteColor] width:2];
    
    self.rejectButton.layer.cornerRadius = 50;
    [self.rejectButton applyShadow];
    [self.rejectButton addBorder:[UIColor whiteColor] width:2];
    
    
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:blurEffectView atIndex:0];
}


- (void)callReceived:(NSNotification*)notification{
    NSDictionary *callDict = notification.userInfo;
    
    if (self.isOnCall) {
        NSString *calleeChannel = callDict[@"channel"];
        NSNumber *senderID = [[CUser currentUser] isPatient] ? [CUser currentUser][@"patient_id"] : @-1;
        NSString *message = [[CUser currentUser] isPatient] ? @"User busy" : @"Dr Ateet Sharma is busy with another call, please try later or He will call you.";
        NSDictionary *callRejectDict = @{@"description" : message,
                                         @"room_id" : callDict[@"room_id"],
                                         @"sender_id" : senderID,
                                         @"type" : @"v_call_end",
                                         @"channel" : calleeChannel};
        
        [PubNubManager sendMessage:callRejectDict toChannel:calleeChannel];
    }else{
        self.videoChatController = [ARTCVideoChatViewController controller];
        [self.videoChatController setRoomName:callDict[@"room_id"]];
        self.videoChatController.call = callDict;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.callDetailLabel.text = callDict[@"description"];
        });
        
        if ([[CUser currentUser] isPatient] &&
            [callDict[@"sender_id"] isEqual:[CUser currentUser][@"patient_id"]]){
            [self receiveAsCaller];
        }else if (![[CUser currentUser] isPatient] && [callDict[@"sender_id"] integerValue] == -1) {
            [self receiveAsCaller];
        }else{
            [self showIncomingCall:callDict];
        }
    }
}

- (void)showIncomingCall:(NSDictionary*)callDict{
    ringPlayer.numberOfLoops = 0;
    [ringPlayer play];
    [self reportIncomingCallFrom:callDict[@"caller"] withUUID:[NSUUID UUID]];
    UINavigationController *navVC = NavigationControllerWithController(self);
    navVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [ApplicationDelegate.window.rootViewController presentViewController:navVC
                                                                animated:YES
                                                              completion:nil];
}

- (void)receiveAsCaller{
    if (self.expectingCall) {
        [ApplicationDelegate.window.rootViewController presentViewController:NavigationControllerWithController(self.videoChatController)
                                                                    animated:YES
                                                                  completion:nil];
        self.expectingCall = NO;
    }
    
}

- (IBAction)answerTapped{
    [ringPlayer stop];
    [self.navigationController pushViewController:self.videoChatController animated:YES];
}

- (IBAction)rejectTapped{
    [ringPlayer stop];
    NSString *calleeChannel = self.videoChatController.call[@"channel"];
    NSNumber *senderID = [[CUser currentUser] isPatient] ? [CUser currentUser][@"patient_id"] : @-1;
    NSDictionary *callRejectDict = @{@"description" : @"User busy.",
                                     @"room_id" : self.videoChatController.call[@"room_id"],
                                     @"sender_id" : senderID,
                                     @"type" : @"v_call_end",
                                     @"channel" : calleeChannel};
    
    [PubNubManager sendMessage:callRejectDict toChannel:calleeChannel];
    
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
    
//    [self reportMissedCall:self.videoChatController.call[@"caller"] withUUID:[NSUUID UUID]];
}


- (void)configureCallKit {
    CXProviderConfiguration *configuration = [[CXProviderConfiguration alloc] initWithLocalizedName:@"Dr."];
    configuration.maximumCallGroups = 1;
    configuration.maximumCallsPerCallGroup = 1;
    UIImage *callkitIcon = [UIImage imageNamed:@"iconMask80"];
    configuration.iconTemplateImageData = UIImagePNGRepresentation(callkitIcon);
    
    _callKitProvider = [[CXProvider alloc] initWithConfiguration:configuration];
    [_callKitProvider setDelegate:self queue:nil];
    
    _callKitCallController = [[CXCallController alloc] init];
}

- (void)reportMissedCall:(NSString *) from withUUID:(NSUUID *)uuid {
   
    CXHandle *callHandle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:from];
    
    CXCallUpdate *callUpdate = [[CXCallUpdate alloc] init];
    callUpdate.remoteHandle = callHandle;
    callUpdate.supportsDTMF = YES;
    callUpdate.supportsHolding = NO;
    callUpdate.supportsGrouping = NO;
    callUpdate.supportsUngrouping = NO;
    callUpdate.hasVideo = NO;
    
    [self.callKitProvider reportCallWithUUID:uuid
                                     updated:callUpdate];
    
    
    [self.callKitProvider reportCallWithUUID:uuid
                                 endedAtDate:[NSDate date]
                                      reason:CXCallEndedReasonUnanswered];
    
    CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:uuid];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:endCallAction];
    
    [self.callKitCallController requestTransaction:transaction completion:^(NSError *error) {
        if (error) {
            NSLog(@"EndCallAction transaction request failed: %@", [error localizedDescription]);
        }
        else {
            NSLog(@"EndCallAction transaction request successful");
        }
    }];
}

- (void)reportIncomingCallFrom:(NSString *) from withUUID:(NSUUID *)uuid {
    return;
    CXHandle *callHandle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:from];
    
    CXCallUpdate *callUpdate = [[CXCallUpdate alloc] init];
    callUpdate.remoteHandle = callHandle;
    callUpdate.supportsDTMF = YES;
    callUpdate.supportsHolding = NO;
    callUpdate.supportsGrouping = NO;
    callUpdate.supportsUngrouping = NO;
    callUpdate.hasVideo = NO;
    
    [self.callKitProvider reportNewIncomingCallWithUUID:uuid update:callUpdate completion:^(NSError *error) {
        if (!error) {
            NSLog(@"Incoming call successfully reported.");
        }
        else {
            NSLog(@"Failed to report incoming call successfully: %@.", [error localizedDescription]);
        }
    }];
}

- (void)performEndCallActionWithUUID:(NSUUID *)uuid {
    if (uuid == nil) {
        return;
    }
    
    CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:uuid];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:endCallAction];
    
    [self.callKitCallController requestTransaction:transaction completion:^(NSError *error) {
        if (error) {
            NSLog(@"EndCallAction transaction request failed: %@", [error localizedDescription]);
        }
        else {
            NSLog(@"EndCallAction transaction request successful");
        }
    }];
}

- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action{
    
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action{
    [self.navigationController pushViewController:self.videoChatController animated:YES];
}

- (void)providerDidReset:(CXProvider *)provider{
    
}

@end
