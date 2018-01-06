//
//  NotificationsController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 06/01/18.
//  Copyright © 2018 Shashank Patel. All rights reserved.
//

#import "NotificationsController.h"
#import "Notification.h"
#import <NSDate+TimeAgo/NSDate+TimeAgo.h>

@interface NotificationsController (){
    NSDateFormatter *df;
}

@property (nonatomic, strong)   NSArray     *notifications;

@end

@implementation NotificationsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Notifications";
    df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [self fetchNotifications];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self action:@selector(doneTapped)];
}

- (void)doneTapped{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)fetchNotifications{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [Notification fetchNotificationsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.notifications = objects;
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"NotificationCell"];
    }
    Notification *notification = self.notifications[indexPath.row];
    cell.textLabel.text = notification[@"content"];
    cell.detailTextLabel.text = [[df dateFromString:notification[@"created_at"]] timeAgo];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
//    Notification *notification = self.notifications[indexPath.row];
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
