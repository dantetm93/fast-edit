//
//  ImgEditingViewModel+Undo.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 8/5/24.
//

import Foundation

struct EditingStep {
    let type: DWrapper.Entity.ImgToolType
    let result: UIImage
    var isFirst: Bool = false
    let brightness: Double
    let constrast: Double
}

protocol IEditingStepHolder {
    func addStep(new: EditingStep)
    func canUndo() -> Bool
    func undo() -> EditingStep?
    func canRedo() -> Bool
    func redo() -> EditingStep?
}

class EditingStepHolder: IEditingStepHolder {
    var listStep: [EditingStep] = []
    var currentStepIndex: Int = -1 // listStep is empty
    
    func addStep(new: EditingStep) {
        if !self.listStep.isEmpty {
            // Remove futute steps if there is a new step added into the list.
            // This new step will be end of the chain.
            let lastIndex = self.listStep.count - 1
            if self.currentStepIndex < lastIndex {
                let countToBeRemoved = lastIndex - self.currentStepIndex
                self.listStep.removeLast(countToBeRemoved)
            }
        }
        self.listStep.append(new)
        self.currentStepIndex = self.listStep.count - 1
    }
    
    func canUndo() -> Bool {
        return self.listStep.count >= 2 && self.currentStepIndex > 0
    }
    
    func undo() -> EditingStep? {
        if self.currentStepIndex < 0 {
            return nil
        }
        self.currentStepIndex -= 1 // Go back
        let newCurrentStep = self.listStep[self.currentStepIndex]
        return newCurrentStep
    }
    
    func canRedo() -> Bool {
        return !self.listStep.isEmpty && self.currentStepIndex < self.listStep.count - 1
    }
    
    func redo() -> EditingStep? {
        let lastIndex = self.listStep.count - 1
        if self.currentStepIndex >= lastIndex {
            return nil
        }
        self.currentStepIndex += 1 // Go next
        let newCurrentStep = self.listStep[self.currentStepIndex]
        return newCurrentStep
    }
}
