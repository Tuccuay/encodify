//
//  ImageEncodeViewController.m
//  encodify
//
//  Created by 洪朔 on 2016/11/30.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import "ImageEncodeViewController.h"

#import "EToast.h"

#import <Masonry/Masonry.h>

@interface ImageEncodeViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) UITextView *textView;

@end

@implementation ImageEncodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Copy" style:UIBarButtonItemStylePlain target:self action:@selector(copyResult)];
}

- (void)copyResult {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.textView.text;
    [EToast showStatus:@"Copied"];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = (UIImage *)info[UIImagePickerControllerOriginalImage];
    
    if (!image) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [EToast showStatus:@"Encoding, please wait."];
    
    typeof(self) __weak weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *string = [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        dispatch_sync(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            
            strongSelf.textView.text = string;
        });
    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [EToast showErrorWithStatus:@"Canceled"];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        [self.view addSubview:_textView];
        _textView.editable = NO;
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    return _textView;
}

@end
