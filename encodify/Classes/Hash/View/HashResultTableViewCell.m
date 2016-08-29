//
//  HashResultTableViewCell.m
//  encodify
//
//  Created by 洪朔 on 16/8/29.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import "HashResultTableViewCell.h"

@interface HashResultTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation HashResultTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setResultString:(NSString *)resultString {
    self.resultLabel.text = resultString;
}

@end
