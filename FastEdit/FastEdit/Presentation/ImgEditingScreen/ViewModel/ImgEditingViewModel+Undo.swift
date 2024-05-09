//
//  ImgEditingViewModel+Undo.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 8/5/24.
//

import Foundation

struct EditingStep {
    var type: DWrapper.Entity.ImgToolType
    var result: UIImage
    var isFirst: Bool = false
    var brightness: Double
    var constrast: Double
    var exposure: Double
    var saturation: Double
    var temperature: Double
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
        
        // Undo this current action
        let currentStep = self.listStep[self.currentStepIndex]
        self.currentStepIndex -= 1 // But apply last change of this action
        var previousStep = self.listStep[self.currentStepIndex]
        previousStep.type = currentStep.type
        
        let lastValue = self.getValueByToolType(type: currentStep.type, step: previousStep)
        AppLogger.d("EditingStepHolder", "[UNDO] \(currentStep.type.getToolName()), set value to \(lastValue)", "", #line)
        return previousStep
    }
    
    private func getValueByToolType(type: DWrapper.Entity.ImgToolType, step: EditingStep) -> Double {
        switch type {
        case .crop: return 0
        case .brightness: return step.brightness
        case .constrast: return step.constrast
        case .saturation: return step.saturation
        case .exposure: return step.brightness
        case .temperature: return step.temperature
        }
    }
    
    func canRedo() -> Bool {
        return !self.listStep.isEmpty && self.currentStepIndex < self.listStep.count - 1
    }
    
    func redo() -> EditingStep? {
        let lastIndex = self.listStep.count - 1
        if self.currentStepIndex >= lastIndex {
            return nil
        }
        self.currentStepIndex += 1 // Apply next action
        let newCurrentStep = self.listStep[self.currentStepIndex]
        let nextValue = self.getValueByToolType(type: newCurrentStep.type, step: newCurrentStep)
        AppLogger.d("EditingStepHolder", "[REDO] \(newCurrentStep.type.getToolName()), set value to \(nextValue)", "", #line)
        return newCurrentStep
    }
}
