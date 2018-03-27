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

@interface CallController ()<CXProviderDelegate, ARTCVideoChatDelegate,PKPushRegistryDelegate>

@property (nonatomic, strong) IBOutlet  UIButton    *answerButton, *rejectButton;
@property (nonatomic, strong) IBOutlet  UILabel     *callDetailLabel;
@property (nonatomic, strong)           ARTCVideoChatViewController     *videoChatController;
@property (nonatomic, strong)           CXProvider              *callKitProvider;
@property (nonatomic, strong)           CXCallController        *callKitCallController;
@property (nonatomic, strong)           PKPushRegistry          *voipRegistry;
@property (nonatomic, strong)           NSUUID                  *currentCallUUID;
@property (nonatomic, strong)           NSDictionary            *currentCallDict;
@property (nonatomic)                   BOOL                    scheduleAnswer;

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
    [self configureCallKit];
    [self configurePushKit];
}

- (void)configurePushKit{
    PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    pushRegistry.delegate = self;
    pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type{
    if([credentials.token length] == 0) {
        NSLog(@"voip token NULL");
        return;
    }
    
    NSLog(@"PushCredentials: %@", credentials.token);
    
    NSData *oldToken = [[NSUserDefaults standardUserDefaults] dataForKey:@"DeviceToken"];
    if (oldToken && [oldToken isEqualToData:credentials.token]) {
        return;
    }
    NSString *token = [[[[credentials.token description]
                         stringByReplacingOccurrencesOfString: @"<" withString: @""]
                        stringByReplacingOccurrencesOfString: @">" withString: @""]
                       stringByReplacingOccurrencesOfString: @" " withString: @""];
    DDLogVerbose(@"P Token: %@", token);
    
    // remove old token from all PubNub channels for push notifications
    [[PubNubManager sharedManager].client removeAllPushNotificationsFromDeviceWithPushToken:oldToken
                                                                              andCompletion:^(PNAcknowledgmentStatus *status) {
                                                                                  DDLogVerbose(@"status: %@", status);
                                                                              }];
    
    defaults_set_object(DEVICE_TOKEN, credentials.token);
    [PubNubManager updateChannels];
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type{
    NSLog(@"didReceiveIncomingPushWithPayload");
    NSDictionary *callDict = payload.dictionaryPayload[@"aps"][@"call_payload"];
    
    NSString *payloadType = callDict[@"type"];
    if ([payloadType isEqualToString:@"v_call"]) {
        [self reportCall:callDict];
    }else if ([payloadType isEqualToString:@"v_call_end"]) {
        [self endCall:callDict];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            NSLog(@"Permission granted");
        }
        else {
            NSLog(@"Permission denied");
        }
    }];
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

- (void)record{
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    
    [session setActive:YES error:nil];
    
    // Start recording
    [recorder record];
}

- (void)viewDidAppear:(BOOL)animated{
    if (self.scheduleAnswer) {
        self.scheduleAnswer = NO;
        [self.navigationController pushViewController:self.videoChatController animated:NO];
        [self.callKitProvider reportOutgoingCallWithUUID:self.currentCallUUID connectedAtDate:nil];
    }
}

- (void)receiveAsCaller{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ApplicationDelegate currentNavigationController] pushViewController:(self)
                                                                     animated:NO];
        self.scheduleAnswer = YES;
    });
}

- (IBAction)answerTapped{
    [self.navigationController pushViewController:self.videoChatController animated:YES];
}

- (IBAction)rejectTapped{
    if (self.currentCallUUID != nil) {
        NSString *calleeChannel = self.currentCallDict[@"channel"];
        NSNumber *senderID = [[CUser currentUser] isPatient] ? [CUser currentUser][@"patient_id"] : @-1;
        NSDictionary *callRejectDict = @{@"description" : @"User busy.",
                                         @"room_id" : self.currentCallDict[@"room_id"],
                                         @"sender_id" : senderID,
                                         @"type" : @"v_call_end",
                                         @"channel" : calleeChannel};
        
        [PubNubManager sendMessage:callRejectDict toChannel:calleeChannel];
        self.currentCallUUID = nil;
        self.currentCallDict = nil;
        self.videoChatController = nil;
    }
}

- (void)callEndTapped{
    if (!self.currentCallUUID)  return;
    CXEndCallAction *action = [[CXEndCallAction alloc] initWithCallUUID:self.currentCallUUID];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:action];

    [self.callKitCallController requestTransaction:transaction completion:^(NSError *error) {
        if (error) {
            self.currentCallUUID = nil;
            self.videoChatController = nil;
            NSLog(@"EndCallAction transaction request failed: %@", [error localizedDescription]);
        }
        else {
            self.currentCallUUID = nil;
            self.videoChatController = nil;
            NSLog(@"EndCallAction transaction request successful");
        }
    }];
}


- (void)configureCallKit {
    CXProviderConfiguration *configuration = [[CXProviderConfiguration alloc] initWithLocalizedName:@"Dr. Ateet Sharma"];
    configuration.maximumCallGroups = 1;
    configuration.supportsVideo = YES;
    configuration.maximumCallsPerCallGroup = 1;
//    UIImage *callkitIcon = [UIImage imageNamed:@"Knee Icon"];
//    configuration.iconTemplateImageData = UIImagePNGRepresentation(callkitIcon);
    
    _callKitProvider = [[CXProvider alloc] initWithConfiguration:configuration];
    [_callKitProvider setDelegate:self queue:nil];
    
    _callKitCallController = [[CXCallController alloc] init];
}

- (void)endCall:(NSDictionary *)callDict{
    if (self.currentCallUUID != nil &&
        [callDict[@"room_id"] isEqualToString:self.currentCallDict[@"room_id"]]) {
        NSInteger controllerIndex = self.navigationController.viewControllers.count - 3;
        UIViewController *target = self.navigationController.viewControllers[controllerIndex];
        [self.navigationController popToViewController:target animated:YES];
        
        [self.videoChatController disconnect];
        [ApplicationDelegate showNotificationWithTitle:callDict[@"description"] description:@""];
        [self.callKitProvider reportCallWithUUID:self.currentCallUUID
                                     endedAtDate:[NSDate date]
                                          reason:CXCallEndedReasonRemoteEnded];
        self.currentCallUUID = nil;
        self.videoChatController = nil;
    }
}

- (void)reportCall:(NSDictionary*)callDict{
    if([callDict[@"room_id"] isEqualToString:self.currentCallDict[@"room_id"]])return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentCallUUID = [NSUUID UUID];
        self.currentCallDict = [callDict copy];
        self.callDetailLabel.text = callDict[@"description"];
        
        self.videoChatController = [ARTCVideoChatViewController controller];
        self.videoChatController.delegate = self;
        [self.videoChatController setRoomName:self.currentCallDict[@"room_id"]];
        self.videoChatController.call = self.currentCallDict;
        
        NSError *err;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
        if (err) {
            NSLog(@"error setting audio category %@",err);
        }
        [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeVideoChat error:&err];
        if (err) {
            NSLog(@"error setting audio Mode %@",err);
        }
        double sampleRate = 44100.0;
        [audioSession setPreferredSampleRate:sampleRate error:&err];
        if (err) {
            NSLog(@"Error %ld, %@",(long)err.code, err.localizedDescription);
        }
        
        NSTimeInterval bufferDuration = .005;
        [audioSession setPreferredIOBufferDuration:bufferDuration error:&err];
        
        if ([[CUser currentUser] isPatient] && [callDict[@"sender_id"] isEqual:[CUser currentUser][@"patient_id"]]){
            [self reportOutgoingCall];
        }else if (![[CUser currentUser] isPatient] && [callDict[@"sender_id"] integerValue] == -1) {
            [self reportOutgoingCall];
        }else{
            [self reportIncomingCall];
        }
    });
}

- (void)reportOutgoingCall{
    NSString *from = self.currentCallDict[@"caller"];
    CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:from];

    CXStartCallAction *startCallAction = [[CXStartCallAction alloc] initWithCallUUID:self.currentCallUUID
                                                                              handle:handle];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:startCallAction];
    
    [self.callKitCallController requestTransaction:transaction completion:^(NSError *error) {
        if (error) {
            NSLog(@"StartCallAction transaction request failed: %@", [error localizedDescription]);
        }
        
        if (!error || IS_SIMULATOR) {
            [self receiveAsCaller];
            NSLog(@"StartCallAction transaction request successful");
        }
    }];
}

- (void)reportIncomingCall{
    if(IS_SIMULATOR){
        [self receiveAsCaller];
    }else{
        NSString *from = self.currentCallDict[@"caller"];
        if (![from isKindOfClass:[NSString class]]) {
            from = @"Dr. Ateet Sharma";
        }
        CXHandle *callHandle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:from];
        
        CXCallUpdate *update = [[CXCallUpdate alloc] init];
        update.localizedCallerName = from;
        update.remoteHandle = callHandle;
        update.supportsDTMF = NO;
        update.supportsHolding = NO;
        update.supportsGrouping = NO;
        update.supportsUngrouping = NO;
        update.hasVideo = YES;
        NSLog(@"Registering with callkit");
        
        [self.callKitProvider reportNewIncomingCallWithUUID:self.currentCallUUID
                                                     update:update
                                                 completion:^(NSError *error) {
                                                     if (!error) {
                                                         NSLog(@"Incoming call successfully reported.");
                                                     }
                                                     else {
                                                         NSLog(@"Failed to report incoming call successfully: %@.", [error localizedDescription]);
                                                     }
                                                 }];
        
    }
}

- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action{
    NSLog(@"Start Call");
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action{
    NSLog(@"performAnswerCallAction");
    self.scheduleAnswer = YES;
    UINavigationController *navigationController = [ApplicationDelegate currentNavigationController];
    [navigationController pushViewController:self animated:NO];
    [self.callKitProvider reportOutgoingCallWithUUID:self.currentCallUUID startedConnectingAtDate:nil];
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action{
    NSLog(@"performEndCallAction");
    [self rejectTapped];
    [action fulfill];
}

- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession{
    NSLog(@"didActivateAudioSession");
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession{
    NSLog(@"didDeactivateAudioSession");
}


- (void)providerDidReset:(CXProvider *)provider{
    
}

@end
