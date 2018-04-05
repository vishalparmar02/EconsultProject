//
//  PDFController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 04/10/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "PDFController.h"
#import "APIManager.h"

@interface PDFController ()

@property (nonatomic, strong)   IBOutlet    UIWebView   *webView;

@end

@implementation PDFController

+ (PDFController*)controller{
    return ControllerFromMainStoryBoard([self description]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.scalesPageToFit = YES;
    [self loadFile];
}

- (void)loadFile{
    NSString *fileName = self.report[@"file_title"];
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *fileURL = [documentsURL URLByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path]) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:fileURL]];
    }else{
        [self downloadFileAt:fileURL];
    }
}

- (void)downloadFileAt:(NSURL *)fileURL{
    NSURL *remoteURL;
    if (![self.report[@"upload_path"] hasPrefix:@"http"]) {
        NSString *remoteURLString = [[[APIManager sharedManager] baseURL] stringByAppendingPathComponent:self.report[@"upload_path"]];
        remoteURL = [NSURL URLWithString:remoteURLString];
    }else{
        remoteURL = [NSURL URLWithString:self.report[@"upload_path"]];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:remoteURL];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeDeterminate;
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request
                                                                     progress:^(NSProgress * _Nonnull downloadProgress) {
                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                             HUD.progress = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
                                                                         });
    }
                                                                  destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                                                      return fileURL;
    }
                                                            completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                                                [HUD hideAnimated:YES];
                                                                if(!error)[self loadFile];
    }];
    
    [downloadTask resume];
}

@end
