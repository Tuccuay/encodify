//
//  UtilitiesViewController.m
//  encodify
//
//  Created by 洪朔 on 2016/11/30.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import "UtilitiesViewController.h"

#import "UtilitiesProvider.h"

#import <Masonry/Masonry.h>

@interface UtilitiesViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray<NSArray<UtilitiesProvider *> *> *provider;

@end

@implementation UtilitiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.provider = @[
                      @[
                          [UtilitiesProvider title:@"Encode image to base64" className:@""],
                          [UtilitiesProvider title:@"Decode base64 to image" className:@""],
                          ],
                      ];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.provider.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.provider.count <= section ? 0 : self.provider[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    
    NSString *title = self.provider[indexPath.section][indexPath.row].title;
    if (title) {
        cell.textLabel.text = title;
    } else {
        cell.textLabel.text = @"";
    }
    
    return cell;
}


@end
