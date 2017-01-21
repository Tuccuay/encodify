//
//  EncodePagerViewController.m
//  encodify
//
//  Created by 洪朔 on 16/8/31.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import "EncodePagerViewController.h"

#import "EncodeViewController.h"
#import "DecodeViewController.h"

#import "UIColor+Helper.h"

@interface EncodePagerViewController ()<XLPagerTabStripViewControllerDataSource>

@end

@implementation EncodePagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self preparePager];
}

- (void)preparePager {
    CGRect oldFrame = self.buttonBarView.frame;
    CGRect newFrame = CGRectMake(oldFrame.origin.x,
                                 oldFrame.origin.y + 20,
                                 oldFrame.size.width,
                                 oldFrame.size.height);
    self.buttonBarView.frame = newFrame;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.buttonBarView.shouldCellsFillAvailableWidth = YES;
    self.isProgressiveIndicator = YES;
    self.buttonBarView.backgroundColor = [UIColor navigationBarDefaultColor];
    self.buttonBarView.selectedBar.backgroundColor = [UIColor encodifyTintColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)childViewControllersForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController {
    EncodeViewController *encodeViewController = [[EncodeViewController alloc] init];
    DecodeViewController *decodeViewController = [[DecodeViewController alloc] init];
    return @[encodeViewController, decodeViewController];
}

@end
