//
//  Thread+Extension.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 6/5/24.
//

import Foundation

public extension Thread {
    var threadName: String {
        if isMainThread {
            return "main"
        } else if let threadName = Thread.current.name, !threadName.isEmpty {
            return threadName
        } else {
            return description
        }
    }
    
    var queueName: String {
        if let queueName = String(validatingUTF8: __dispatch_queue_get_label(nil)) {
            return queueName
        } else if let operationQueueName = OperationQueue.current?.name, !operationQueueName.isEmpty {
            return operationQueueName
        } else if let dispatchQueueName = OperationQueue.current?.underlyingQueue?.label, !dispatchQueueName.isEmpty {
            return dispatchQueueName
        } else {
            return "n/a"
        }
    }
}

public extension DispatchQueue {
    
    func delay(_ time: TimeInterval, handler: @escaping () -> Void) {
        if time == 0 {
            self.switchTo(handler: handler)
            return
        }
        self.asyncAfter(deadline: DispatchTime.now() + time, execute: handler)
    }

    func switchTo(handler: @escaping () -> Void) {
        if Thread.current.queueName == self.label {
            handler()
            return
        }
        self.async(execute: handler)
    }
}
