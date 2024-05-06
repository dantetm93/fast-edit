//
//  NSObject+Extension.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 6/5/24.
//

import Foundation

public extension NSObject {
    
    static var typeName: String {
        return String(describing: self)
    }
    var objectName: String {
        return String(describing: type(of: self))
    }
    
    static func cancel(target: Any, selector: Selector, object: Any? = nil) {
        NSObject.cancelPreviousPerformRequests(withTarget: target, selector: selector, object: nil)
    }
}

func associatedObject<ValueType: AnyObject>(
    base: AnyObject,
    key: UnsafePointer<UInt8>,
    initialiser: () -> ValueType)
    -> ValueType {
        if let associated = objc_getAssociatedObject(base, key)
            as? ValueType { return associated }
        let associated = initialiser()
        objc_setAssociatedObject(base, key, associated,
                                 .OBJC_ASSOCIATION_RETAIN)
        return associated
}
func associateObject<ValueType: AnyObject>(
    base: AnyObject,
    key: UnsafePointer<UInt8>,
    value: ValueType) {
    objc_setAssociatedObject(base, key, value,
                             .OBJC_ASSOCIATION_RETAIN)
}
