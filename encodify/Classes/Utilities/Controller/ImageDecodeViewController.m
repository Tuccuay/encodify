//
//  ImageDecodeViewController.m
//  encodify
//
//  Created by 洪朔 on 2016/11/30.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import "ImageDecodeViewController.h"

#import "ImageViewController.h"
#import "EToast.h"

#import <Masonry/Masonry.h>

@interface ImageDecodeViewController ()

@property (strong, nonatomic) UITextView *textView;

@end

@implementation ImageDecodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textView = [[UITextView alloc] init];
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.navigationItem.rightBarButtonItems = @[
                                                [[UIBarButtonItem alloc] initWithTitle:@"Decode" style:UIBarButtonItemStylePlain target:self action:@selector(decodeString)],
                                                [[UIBarButtonItem alloc] initWithTitle:@"Paste" style:UIBarButtonItemStylePlain target:self action:@selector(pasteString)]
                                                ];
    
    [self.textView becomeFirstResponder];
}

- (void)pasteString {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *string = pasteboard.string;
    if (string && ![string isEqualToString:@""]) {
        [EToast showStatus:@"Pasted"];
        self.textView.text = string;
        
    } else {
        [EToast showStatus:@"Pasteboard is empty."];
    }
}

- (void)decodeString {
    
    NSString *string = self.textView.text;
    
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];;
    if (data == nil) {
        [EToast showStatus:@"Decode failure."];
        return;
    }
    
    UIImage *image = [UIImage imageWithData:data];
    if (image == nil) {
        [EToast showStatus:@"Decode failure."];
        return;
    }
    
    ImageViewController *imageViewController = [[ImageViewController alloc] initWithImage:image];
    [self.navigationController pushViewController:imageViewController animated:YES];
}

@end
