//
//  HashDataSource.h
//  encodify
//
//  Created by 洪朔 on 16/8/28.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^HashCellSelectedBlock)(NSString *resultString);
typedef void(^HashReloadDataBlock)();

typedef NS_ENUM(NSUInteger, HashShowType) {
    HashShowTypeUpperString = 0,
    HashShowTypeLowerString = 1,
    HashShowTypeBase64 = 2,
};

@interface HashDataSource : NSObject<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) HashCellSelectedBlock cellSelectedBlock;
@property (nonatomic, copy) HashReloadDataBlock reloadDataBlock;

- (instancetype)initWithIdentifier:(NSString *)identifier
                 cellSelectedBlock:(HashCellSelectedBlock)cellSelectedBlock
                   reloadDataBlock:(HashReloadDataBlock)reloaDataBlock;

- (void)hashWithSourceString:(NSString *)sourceString showType:(HashShowType)type;

@end
