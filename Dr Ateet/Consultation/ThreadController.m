//
//  ThreadController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 30/05/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "ThreadController.h"
#import "DemoMessagesViewController.h"

@implementation ThreadCell

- (void)setChatThread:(ChatThread *)chatThread{
    _chatThread = chatThread;
    [self.threadImageView makeCircular];
    [self.threadImageView sd_setImageWithURL:chatThread.imageURL
                      placeholderImage:nil
                               options:SDWebImageRefreshCached | SDWebImageProgressiveDownload
                             completed:nil];
    self.titleLabel.text = chatThread.otherPartyName;
    self.descriptionLabel.text = chatThread.lastConversationText;
}

@end


@interface ThreadController ()

@property (nonatomic, strong)   NSArray     *threads;

@end

@implementation ThreadController

+ (ThreadController*)controller{
    return ControllerFromStoryBoard(@"Consultation", @"ThreadController");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Consultation";
    self.threads = @[[ChatThread new],
                     [ChatThread new],
                     [ChatThread new],
                     [ChatThread new],
                     [ChatThread new]];
    
    UIButton *composeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [composeButton setImage:[UIImage imageNamed:@"compose"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:composeButton];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.threads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ThreadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThreadCell"
                                                       forIndexPath:indexPath];
    cell.chatThread = self.threads[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DemoMessagesViewController *vc = [DemoMessagesViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
