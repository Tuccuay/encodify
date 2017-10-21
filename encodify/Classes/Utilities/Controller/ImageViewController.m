//
//  ImageViewController.m
//  encodify
//
//  Created by 洪朔 on 2016/11/30.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import "ImageViewController.h"

#import "EToast.h"

#import <Masonry/Masonry.h>

#import <Photos/Photos.h>

@interface ImageViewController ()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;

@end

@implementation ImageViewController

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        self.image = image;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    [self.scrollView addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
    }];
    
    self.scrollView.maximumZoomScale = 5;
    CGFloat widthScale = [UIScreen mainScreen].bounds.size.width / self.imageView.bounds.size.width;
    CGFloat navigationBarMaxY = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    CGFloat heightScale = [UIScreen mainScreen].bounds.size.height / (self.imageView.bounds.size.height - navigationBarMaxY);
    CGFloat minScale = MIN(widthScale, heightScale);
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.zoomScale = minScale;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateInsets];
        });
    });
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveImage)];
}

- (void)saveImage {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusNotDetermined: {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self saveImageToAlbum];
                } else {
                    [self changeSettings];
                }
            }];
            break;
        }
        case PHAuthorizationStatusRestricted: {
            [self changeSettings];
            break;
        }
        case PHAuthorizationStatusDenied: {
            [self changeSettings];
            break;
        }
        case PHAuthorizationStatusAuthorized: {
            [self saveImageToAlbum];
            break;
        }
    }
}

- (void)saveImageToAlbum {
    UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
    [EToast showStatus:@"Saved"];
}

- (void)changeSettings {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Premission denied" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    [self updateInsets];
}

- (void)updateInsets {
    
    CGFloat navigationBarMaxY = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    CGFloat insetTop;
    if (self.imageView.frame.size.height > self.scrollView.bounds.size.height - navigationBarMaxY) {
        insetTop = navigationBarMaxY;
    } else {
        insetTop = (self.scrollView.bounds.size.height - self.imageView.frame.size.height) / 2 + navigationBarMaxY;
    }
    
    CGFloat insetLeft = 0.0;
    if (self.imageView.frame.size.width > self.scrollView.bounds.size.width) {
        insetTop = 0;
    } else {
        insetLeft = (self.scrollView.bounds.size.width - self.imageView.frame.size.width) / 2;
    }
    
    UIEdgeInsets inset = UIEdgeInsetsMake(insetTop, insetLeft, 0, 0);
    
    self.scrollView.contentInset = inset;
}

@end
