//
//  ReportUploadController.m
//  Dr Ateet
//
//  Created by Shashank Patel on 24/08/17.
//  Copyright © 2017 Shashank Patel. All rights reserved.
//

#import "ReportUploadController.h"

@interface ReportUploadController ()

@property (nonatomic, strong)   IBOutlet    UITableView     *tableView;
@property (nonatomic, strong)   IBOutlet    UITextView      *descriptionView;
@property (nonatomic, strong)               NSArray         *reportTypes;

@end

@implementation ReportUploadController

+ (id)controller{
    return ControllerFromMainStoryBoard([self description]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.descriptionView.layer.cornerRadius = 5;
    self.descriptionView.layer.borderWidth = 1;
    self.descriptionView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TypeCell"];
    self.reportTypes = @[@"X-Ray", @"Other"];
    self.reportTypes = @[];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Upload"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(uploadTapped)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.reportTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TypeCell"
                                                            forIndexPath:indexPath];
    NSString *reportType = self.reportTypes[indexPath.row];
    cell.textLabel.text = reportType;
    cell.accessoryType = [self.report.reportType isEqualToString:reportType] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.report.reportType = self.reportTypes[indexPath.row];
    [tableView reloadData];
}

- (void)uploadTapped{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.report.reportDescription = self.descriptionView.text;
    [self.report saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (succeeded){
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}


@end
