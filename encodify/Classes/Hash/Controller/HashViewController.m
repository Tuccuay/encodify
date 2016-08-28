//
//  HashViewController.m
//  encodify
//
//  Created by 洪朔 on 16/8/28.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import "HashViewController.h"

#import "HashDataSource.h"

@interface HashViewController ()

@property (weak, nonatomic) IBOutlet UITextView *inputTextView;

@property (nonatomic, copy) NSString *kHashTableViewCellIdentifier;
@property (nonatomic, strong) HashDataSource *dataSource;

@property (weak, nonatomic) IBOutlet UISegmentedControl *showTypeSegmentedControl;

@end

@implementation HashViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepareTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initinals

- (void)prepareTableView {
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:self.kHashTableViewCellIdentifier];
    HashDataSource *dataSource = [[HashDataSource alloc] initWithIdentifier:self.kHashTableViewCellIdentifier
                                                          cellSelectedBlock:^(NSString *hashSteing) {
                                                              // TODO didSelectedCell
                                                          }
                                                            reloadDataBlock:^{
                                                                [self.tableView reloadData];
                                                            }];
    self.tableView.dataSource = dataSource;
    self.tableView.delegate = dataSource;
    self.dataSource = dataSource;
}

#pragma mark - Actions

- (IBAction)copyButtonAction:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.inputTextView.text;
}

- (IBAction)pasteButtonAction:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    self.inputTextView.text = pasteboard.string;
    [self hashButtonAction:nil];
}

- (IBAction)clearButtonAction:(id)sender {
    self.inputTextView.text = @"";
}

- (IBAction)hashButtonAction:(id)sender {
    //    self.dataSource. = [self.inputTextView.text copy];

    [self.dataSource hashWithSourceString:[self.inputTextView.text copy] showType:(NSUInteger)self.showTypeSegmentedControl.selectedSegmentIndex];
}

- (IBAction)showTypeSegmentedControlAction:(id)sender {
    [self hashButtonAction:nil];
}

#pragma mark - Getter / Setter

- (NSString *)kHashTableViewCellIdentifier {
    if (!_kHashTableViewCellIdentifier) {
        _kHashTableViewCellIdentifier = @"kHashTableViewCellIdentifier";
    }
    
    return _kHashTableViewCellIdentifier;
}

@end
