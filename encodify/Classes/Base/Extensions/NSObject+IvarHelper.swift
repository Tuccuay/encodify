//
//  NSObject+IvarHelper.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import Foundation

// MARK: - NSObject Runtime Helpers
// source: https://mp.weixin.qq.com/s/r8_eJxyFvWCzkN63EfrYxw

public extension NSObject {
    func getIvar(forKey key: String) -> Any? {
        guard let _ivar = class_getInstanceVariable(type(of: self), key) else {
            assertionFailure()
            return nil
        }

        return object_getIvar(self, _ivar)
    }

    func setIvar(_ value: Any?, forKey key: String) {
        guard let _ivar = class_getInstanceVariable(type(of: self), key) else {
            assertionFailure()
            return
        }

        object_setIvar(self, _ivar, value)
    }
}
