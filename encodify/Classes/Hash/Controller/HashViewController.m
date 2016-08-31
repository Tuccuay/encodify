//
//  HashViewController.m
//  encodify
//
//  Created by 洪朔 on 16/8/28.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import "HashViewController.h"

#import "HashDataSource.h"
#import "EToast.h"

@interface HashViewController ()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *inputTextView;

@property (nonatomic, copy) NSString *kHashResultTableViewCellIdentifier;
@property (nonatomic, strong) HashDataSource *dataSource;

@property (weak, nonatomic) IBOutlet UISegmentedControl *showTypeSegmentedControl;

@end

@implementation HashViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepareTableView];
    [self prepareGestures];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initinals

- (void)prepareTableView {
    
    HashCellSelectedBlock selectedBlock = ^(NSString *resultString) {
        [self.inputTextView resignFirstResponder];
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = resultString;
        
        [EToast showStatus:@"Copied"];
    };
    
    __weak typeof(*&self) weakSelf = self;
    HashReloadDataBlock reloadBlock = ^{
        [weakSelf.tableView reloadData];
    };
    
    HashDataSource *dataSource = [[HashDataSource alloc] initWithIdentifier:weakSelf.kHashTableViewCellIdentifier
                                                          cellSelectedBlock:selectedBlock
                                                            reloadDataBlock:reloadBlock];
    
    self.tableView.estimatedRowHeight = 44;
    self.tableView.dataSource = dataSource;
    self.tableView.delegate = dataSource;
    self.dataSource = dataSource;
}

- (void)prepareGestures {
    UITapGestureRecognizer *tapViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignInputTextViewFirstResponder)];
    tapViewGesture.delegate = self;
    [self.view addGestureRecognizer:tapViewGesture];
    
    UITapGestureRecognizer *tapNavigationGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignInputTextViewFirstResponder)];
    tapNavigationGesture.delegate = self;
    [self.navigationController.navigationBar addGestureRecognizer:tapNavigationGesture];
}

#pragma mark - Actions

- (IBAction)copyButtonAction:(id)sender {
    [self.inputTextView resignFirstResponder];
    
    if (self.inputTextView.text == nil || [self.inputTextView.text isEqual: @""]) {
        [EToast showErrorWithStatus:@"No text in input box."];
        return;
    }
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.inputTextView.text;
    [EToast showStatus:@"Copied"];
}

- (IBAction)pasteButtonAction:(id)sender {
    [self.inputTextView resignFirstResponder];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    if (pasteboard.string == nil || [pasteboard.string isEqual: @""]) {
        [EToast showErrorWithStatus:@"No text in pasteboard."];
        return;
    }
    
    self.inputTextView.text = pasteboard.string;
    [self hashButtonAction:nil];
    [EToast showStatus:@"Pasted"];
}

- (IBAction)clearButtonAction:(id)sender {
    [self.inputTextView resignFirstResponder];
    
    self.inputTextView.text = @"";
    [EToast showStatus:@"Cleared"];
}

- (IBAction)hashButtonAction:(id)sender {
    [self.inputTextView resignFirstResponder];
    
    if (self.inputTextView.text == nil || [self.inputTextView.text isEqual: @""]) {
        [EToast showErrorWithStatus:@"No text in input box."];
        return;
    }
    
    [self.dataSource hashWithSourceString:[self.inputTextView.text copy] showType:(NSUInteger)self.showTypeSegmentedControl.selectedSegmentIndex];
    [EToast showStatus:@"Hashed"];
}

- (IBAction)showTypeSegmentedControlAction:(id)sender {
    [self.inputTextView resignFirstResponder];
    
    [self hashButtonAction:nil];
}

- (void)resignInputTextViewFirstResponder {
    [self.inputTextView resignFirstResponder];
}

#pragma mark - Getter / Setter

- (NSString *)kHashTableViewCellIdentifier {
    if (!_kHashResultTableViewCellIdentifier) {
        _kHashResultTableViewCellIdentifier = @"kHashResultTableViewCellIdentifier";
    }
    
    return _kHashResultTableViewCellIdentifier;
}

#pragma mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    
    return YES;
}

@end
