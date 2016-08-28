//
//  HashDataSource.m
//  encodify
//
//  Created by 洪朔 on 16/8/28.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import "HashDataSource.h"

#import <CommonCrypto/CommonCrypto.h>

//#import "CocoaSecurity_HashMothod.h"
#import "CocoaSecurity+HashMothod.h"

@interface HashDataSource()

@property (nonatomic, strong) NSArray <NSString *> *hashResult;
@property (nonatomic, strong) NSArray <NSString *> *methodList;
@property (nonatomic, copy) NSString *kHashCellIdentifier;

@end

@implementation HashDataSource

- (instancetype)initWithIdentifier:(NSString *)identifier
                 cellSelectedBlock:(HashCellSelectedBlock)cellSelectedBlock
                   reloadDataBlock:(HashReloadDataBlock)reloaDataBlock {
    if (self = [super init]) {
        self.kHashCellIdentifier = identifier;
        self.cellSelectedBlock = cellSelectedBlock;
        self.reloadDataBlock = reloaDataBlock;
    }
    
    return self;
}

#pragma mark - Actions

- (void)hashWithSourceString:(NSString *)sourceString showType:(HashShowType)type {
    NSMutableArray <NSString *>* resultStringArray  = [NSMutableArray array];
    NSMutableArray <CocoaSecurityResult *> *resultArray = [NSMutableArray arrayWithObjects:
                                                      [CocoaSecurity md2:sourceString],
                                                      [CocoaSecurity md4:sourceString],
                                                      [CocoaSecurity md5:sourceString],
                                                      [CocoaSecurity sha1:sourceString],
                                                      [CocoaSecurity sha224:sourceString],
                                                      [CocoaSecurity sha256:sourceString],
                                                      [CocoaSecurity sha384:sourceString],
                                                      [CocoaSecurity sha512:sourceString],
                                                      nil];
    
    switch (type) {
        case HashShowTypeUpperString:
            for (CocoaSecurityResult *result in resultArray) {
                [resultStringArray addObject:result.hex];
            }
            break;
        case HashShowTypeLowerString:
            for (CocoaSecurityResult *result in resultArray) {
                [resultStringArray addObject:result.hexLower];
            }
            break;
        case HashShowTypeBase64:
            for (CocoaSecurityResult *result in resultArray) {
                [resultStringArray addObject:result.base64];
            }
            break;
    }

    self.hashResult = resultStringArray;
    
    self.reloadDataBlock();
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.hashResult.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.methodList[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.kHashCellIdentifier];
    cell.textLabel.text = self.hashResult[indexPath.section];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Getter / Setter

- (NSArray<NSString *> *)methodList {
    if (_methodList) {
        return _methodList;
    }
    
    _methodList = @[@"MD2", @"MD4", @"MD5",
                    @"SHA1", @"SHA224", @"SHA256", @"SHA384", @"SHA512"];
    return _methodList;
}



@end
