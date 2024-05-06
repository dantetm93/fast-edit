//
//  Macro.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 6/5/24.
//

import Foundation

public func delayOnMain(_ time: TimeInterval, handler: @escaping () -> Void) {
    if time == 0 {
        switchToMain(handler: handler)
        return
    }
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time, execute: handler)
}

public func switchToMain(handler: @escaping () -> Void) {
    if Thread.isMainThread {
        handler()
        return
    }
    DispatchQueue.main.async(execute: handler)
}

public func delayOnDefaultGlobal(_ time: TimeInterval, handler: @escaping () -> Void) {
    if time == 0 {
        switchToDefaultGlobal(handler: handler)
        return
    }
    DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + time, execute: handler)
}

public func switchToDefaultGlobal(handler: @escaping () -> Void) {
    if Thread.current.queueName == DispatchQueue.global().label {
        handler()
        return
    }
    DispatchQueue.global().async(execute: handler)
}

public class SelfCorrectDispatchGroup {
    let group = DispatchGroup()
    
    var count = 0
    
    public func enter() {
        self.count += 1
        self.group.enter()
    }
    
    public func leave() {
        if count == 0 { return }
        self.count -= 1
        self.group.leave()
    }
    
    public func wait() {
        self.group.wait()
    }
    
    public func notify(qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], queue: DispatchQueue, execute work: @escaping @convention(block) () -> Void) {
        self.group.notify(qos: qos, flags: flags, queue: queue, execute: work)
    }
}

public func makeSelfCorrectGroup() -> SelfCorrectDispatchGroup {
    return SelfCorrectDispatchGroup.init()
}
