//
//  EncodeBaseViewController.m
//  encodify
//
//  Created by 洪朔 on 16/8/31.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import "EncodeBaseViewController.h"

#import "EToast.h"

#import <Masonry/Masonry.h>

@interface EncodeBaseViewController ()

@property (nonatomic, strong) UISegmentedControl *methodSegmentedControl;
@property (nonatomic, strong) UITextView *inputTextView;
@property (nonatomic, strong) UITextView *outputTextView;

@end

@implementation EncodeBaseViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self prepareUserInterface];
    [self prepareGesture];
}

#pragma mark - Prepare
- (void)prepareUserInterface {
    UIView *storeButtonsView = [[UIView alloc] init];

    [self.view addSubview:self.methodSegmentedControl];
    [self.view addSubview:self.inputTextView];
    [self.view addSubview:storeButtonsView];
    [self.view addSubview:self.outputTextView];

    [self.methodSegmentedControl addTarget:self action:@selector(methodSegmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
    [self.methodSegmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view).mas_offset(UIEdgeInsetsMake(8, 8, 0, 8));
    }];

    [self.inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.methodSegmentedControl.mas_bottom).offset(8);
        make.left.right.equalTo(self.view);
    }];

    [storeButtonsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.inputTextView.mas_bottom).offset(8);
        make.left.equalTo(self.view).offset(8);
        make.right.equalTo(self.view).offset(-8);
        make.height.equalTo(@30);
    }];

    [self.outputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(storeButtonsView.mas_bottom).offset(8);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.height.equalTo(self.inputTextView);
    }];

    UIStackView *storeButtonsStackView = [[UIStackView alloc] init];
    storeButtonsStackView.axis = UILayoutConstraintAxisHorizontal;
    storeButtonsStackView.distribution = UIStackViewDistributionFillEqually;
    storeButtonsStackView.alignment = UIStackViewAlignmentCenter;
    
    [storeButtonsView addSubview:storeButtonsStackView];
    [storeButtonsStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(storeButtonsView);
    }];
    
    UIButton *copyUpButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIButton *copyDownButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIButton *pasteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIButton *encodeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [copyUpButton addTarget:self action:@selector(copyUpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [copyDownButton addTarget:self action:@selector(copyDownButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [pasteButton addTarget:self action:@selector(pasteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [clearButton addTarget:self action:@selector(clearButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [encodeButton addTarget:self action:@selector(encodeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [copyUpButton setTitle:@"Copy↑" forState:UIControlStateNormal];
    [copyDownButton setTitle:@"Copy↓" forState:UIControlStateNormal];
    [pasteButton setTitle:@"Paste" forState:UIControlStateNormal];
    [clearButton setTitle:@"Clean" forState:UIControlStateNormal];
    // Needed override in subclass
    [encodeButton setTitle:@"Encode" forState:UIControlStateNormal];
    
    [storeButtonsStackView addArrangedSubview:copyUpButton];
    [storeButtonsStackView addArrangedSubview:copyDownButton];
    [storeButtonsStackView addArrangedSubview:pasteButton];
    [storeButtonsStackView addArrangedSubview:clearButton];
    [storeButtonsStackView addArrangedSubview:encodeButton];
}

- (void)prepareGesture {
    UITapGestureRecognizer *tapToResignGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToResign)];
    [self.view addGestureRecognizer:tapToResignGesture];
}

#pragma mark - Function
- (void)tapToResign {
    [self.inputTextView resignFirstResponder];
}

#pragma mark - Action
- (void)methodSegmentedControlChanged:(UISegmentedControl *)sender {
    [self encode];
}

- (void)copyUpButtonAction:(id)sender {
    [self.inputTextView resignFirstResponder];
    
    if (self.inputTextView.text == nil || [self.inputTextView.text isEqual: @""]) {
        [EToast showErrorWithStatus:@"No text in input box."];
        return;
    }
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.inputTextView.text;
    [EToast showStatus:@"Copied"];
}

- (void)copyDownButtonAction:(id)sender {
    [self.inputTextView resignFirstResponder];

    if (self.outputTextView.text == nil || [self.outputTextView.text isEqualToString:@""]) {
        [EToast showErrorWithStatus:@"No text in input box."];
        return;
    }

    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.outputTextView.text;
    [EToast showStatus:@"Copied"];
}

- (void)pasteButtonAction:(id)sender {
    [self.inputTextView resignFirstResponder];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    if (pasteboard.string == nil || [pasteboard.string isEqual: @""]) {
        [EToast showErrorWithStatus:@"No text in pasteboard."];
        return;
    }
    
    self.inputTextView.text = pasteboard.string;
    [self encode];
    [EToast showStatus:@"Pasted"];
}

- (void)clearButtonAction:(id)sender {
    [self.inputTextView resignFirstResponder];
    
    self.inputTextView.text = @"";
    [EToast showStatus:@"Cleared"];
}

- (void)encodeButtonAction:(id)sender {
    [self encode];
}

#pragma mark - Encode
- (void)encode {
    [self.inputTextView resignFirstResponder];

    NSString *inputString = self.inputTextView.text;
    NSString *result;
    switch (self.methodSegmentedControl.selectedSegmentIndex) {
        case 0:
            result = [self encodeWithBase64:inputString];
            break;
            
        case 1:
            result = [self encodeWithUnicode:inputString];
            break;
            
        case 2:
            result = [self encodeWithMorse:inputString];
            break;
            
        case 3:
            result = [self encodeWithURI:inputString];
            break;

        default:
            break;
    }

    self.outputTextView.text = result;
}

#pragma mark - Override in subclass
- (NSString *)encodeWithBase64:(NSString *)inputString {
    return @"";
}

- (NSString *)encodeWithUnicode:(NSString *)inputString {
    return @"";
}

- (NSString *)encodeWithMorse:(NSString *)inputString {
    return @"";
}

- (NSString *)encodeWithURI:(NSString *)inputString {
    return @"";
}

#pragma mark - Lazy load
- (UISegmentedControl *)methodSegmentedControl {
    if (!_methodSegmentedControl) {
        _methodSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Base64", @"Unicode", @"Morse", @"URI"]];
        _methodSegmentedControl.selectedSegmentIndex = 0;
    }
    
    return _methodSegmentedControl;
}

- (UITextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[UITextView alloc] init];
    }
    
    return _inputTextView;
}

- (UITextView *)outputTextView {
    if (!_outputTextView) {
        _outputTextView = [[UITextView alloc] init];
        
        _outputTextView.editable = NO;
    }
    
    return _outputTextView;
}

#pragma mark - custem values
- (NSString *)encodeButtonTitle {
    return @"";
}

@end
