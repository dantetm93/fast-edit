//
//  ImgEditingViewModel.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 7/5/24.
//

import UIKit
import Combine

protocol IImgEditingAction {
    
    func setCropUseCase(val: ICropUseCase)
    func cropTo(rect: CGRect, angle: Int)
    func cropToCenterSquare(source: UIImage)
    func cropToCenterCircle()
    func saveProcessedImgToGallery(done: Closure_Void_Void?)
    func needConfirmBeforeQuit() -> Bool
    
    func setStepHolder(val: IEdittingStepHolder)
    func undo()
    func redo()
}

protocol IImgEditingViewModel: IImgEditingAction {
    typealias ProcessedImgPub = CurrentValueSubject<UIImage, Never>
    typealias ToolTypeChangedPub = PassthroughSubject<DWrapper.Entity.ImgToolType, Never>

    func load()
    func getOriginalImg() -> UIImage
    func getLastProcessedImg() -> UIImage
    func getCroppingStyle() -> TOCropViewCroppingStyle
    
    func getListImgToolCount() -> Int
    func getImgToolAt(index: Int) -> DWrapper.Entity.ImgToolInfo
    func selectImgToolAt(index: Int)
    func isSelectingToolAt(index: Int) -> Bool
    func resetUIToDefault()
    
    func getListToolPub() -> VoidNoValuePub
    func getSliderDisplayPub() -> BoolNoValuePub
    func getToolTypeChangedPub() -> ToolTypeChangedPub
    func getProcessedImgPub() -> ProcessedImgPub
    func getCurrentToolNamePub() -> StringValuePub
    func getCurrentSingleToolValue() -> DoubleValuePub
    func getResetUIPub() -> VoidNoValuePub
    func getCanUndoPub() -> BoolNoValuePub
    func getCanRedoPub() -> BoolNoValuePub
}

class ImgEditingViewModel {
    
    private let originalImg: UIImage
    private var croppingStyle = TOCropViewCroppingStyle.default
    private var proccesedImg: UIImage?
    
    private var listImgTool: [DWrapper.Entity.ImgToolInfo] = []
    private var currentToolIndex: Int = -1
    
    private let processedImgPub = ProcessedImgPub.init(UIImage())
    private let currentToolNamePub = StringValuePub.init("")
    private let singleToolValuePub = DoubleValuePub.init(0)
    private let listToolPub = VoidNoValuePub.init()
    private let sliderDisplayPub = BoolNoValuePub.init()
    private let toolTypeChangedPub = ToolTypeChangedPub.init()
    private let resetUIPub = VoidNoValuePub.init()
    private let canUndoPub = BoolNoValuePub.init()
    private let canRedoPub = BoolNoValuePub.init()

    init(originalImg: UIImage) { self.originalImg = originalImg }

    private var cropUseCase: ICropUseCase!
    func setCropUseCase(val: ICropUseCase) {
        self.cropUseCase = val
    }
    
    private var stepHolder: IEdittingStepHolder!
    func setStepHolder(val: IEdittingStepHolder) {
        self.stepHolder = val
    }
    
}

extension ImgEditingViewModel: IImgEditingViewModel {
    
    func load() {
        self.listImgTool = DWrapper.Entity.ImgToolType.allCases.map({ type in
            return .init(name: type.getToolName(), type: type)
        })
        self.listToolPub.send(())
        self.sliderDisplayPub.send(false)
        self.processedImgPub.send(self.originalImg)
        self.currentToolNamePub.send("")
        
        self.stepHolder.addStep(new: .init(type: .crop, value: 0, result: self.originalImg, isFirst: true))
        self.updateStateForUndoRedo()
    }
    
    func getOriginalImg() -> UIImage {
        return self.originalImg
    }
    
    func getCroppingStyle() -> TOCropViewCroppingStyle {
        return self.croppingStyle
    }
    
    func getLastProcessedImg() -> UIImage {
        if let proccesedImg { return proccesedImg }
        return self.originalImg
    }
    
    // MARK: - Pub-Sub binding
    func getListToolPub() -> VoidNoValuePub {
        return self.listToolPub
    }
    
    func getSliderDisplayPub() -> BoolNoValuePub {
        return self.sliderDisplayPub
    }
    
    func getToolTypeChangedPub() -> ToolTypeChangedPub {
        return self.toolTypeChangedPub
    }
    
    func getProcessedImgPub() -> ProcessedImgPub {
        return self.processedImgPub
    }
    
    func getCurrentToolNamePub() -> StringValuePub {
        return self.currentToolNamePub
    }
    
    func getCurrentSingleToolValue() -> DoubleValuePub {
        return self.singleToolValuePub
    }
    
    func getResetUIPub() -> VoidNoValuePub {
        return self.resetUIPub
    }
    
    func getCanUndoPub() -> BoolNoValuePub {
        return self.canUndoPub
    }
    
    func getCanRedoPub() -> BoolNoValuePub {
        return self.canRedoPub
    }
    
    // MARK: - List view handlers
    func getListImgToolCount() -> Int {
        return self.listImgTool.count
    }
    
    func getImgToolAt(index: Int) -> DWrapper.Entity.ImgToolInfo {
        return self.listImgTool[index]
    }
    
    func selectImgToolAt(index: Int) {
        self.currentToolIndex = index
        let item = self.getImgToolAt(index: index)
        let name = item.type.getToolName()
        self.currentToolNamePub.send(name)
        
        let needShowSlider = self.needShowSliderValue(type: item.type)
        self.sliderDisplayPub.send(needShowSlider)
        
        self.toolTypeChangedPub.send(item.type)
    }
    
    func isSelectingToolAt(index: Int) -> Bool {
        return self.currentToolIndex == index
    }
    
    // MARK: - Main UI handlers
    func resetUIToDefault() {
        self.currentToolIndex = -1
        self.currentToolNamePub.send("")
        self.sliderDisplayPub.send(false)
        self.resetUIPub.send()
    }
    
    private func needShowSliderValue(type: DWrapper.Entity.ImgToolType) -> Bool {
        switch type {
//        case .crop, .rotate: return false
        case .crop: return false
        default: return true
        }
    }

    // MARK: - IImgEditingAction
    func saveProcessedImgToGallery(done: Closure_Void_Void?) {
        AlbumManager.current.save(image: self.getLastProcessedImg()) {
            switchToMain {
                done?()
            }
        }
    }
    
    func needConfirmBeforeQuit() -> Bool {
        return true
    }
    
    private func updateStateForUndoRedo() {
        self.canUndoPub.send(self.stepHolder.canUndo())
        self.canRedoPub.send(self.stepHolder.canRedo())
    }
    
    func undo() {
        if let newCurrentStep = self.stepHolder.undo() {
            // Still can go back
            self.proccesedImg = newCurrentStep.result
            self.processedImgPub.send(newCurrentStep.result)
        } else {
            // Cant go back
            self.proccesedImg = nil
            self.processedImgPub.send(self.originalImg)
        }
        self.updateStateForUndoRedo()
    }
    
    func redo() {
        if let newCurrentStep = self.stepHolder.redo() {
            // Still can go next
            self.proccesedImg = newCurrentStep.result
            self.processedImgPub.send(newCurrentStep.result)
        } else {
            // Cant go next
        }
        self.updateStateForUndoRedo()
    }
    
    func cropTo(rect: CGRect, angle: Int) {
        let image = self.getLastProcessedImg()
        let result = self.cropUseCase.cropTo(source: image, angle: angle, rect: rect)
        self.proccesedImg = result
        self.processedImgPub.send(result)
        self.resetUIToDefault()
        self.stepHolder.addStep(new: .init(type: .crop, value: 0, result: result))
        self.updateStateForUndoRedo()
    }
    
    func cropToCenterSquare(source: UIImage) {
        let image = self.getLastProcessedImg()
        let result = self.cropUseCase.cropToCenterSquare(source: image)
        self.proccesedImg = result
        self.processedImgPub.send(result)
    }
    
    func cropToCenterCircle() {
        let image = self.getLastProcessedImg()
        let result = self.cropUseCase.cropToCenterCircle(source: image)
        self.proccesedImg = result
        self.processedImgPub.send(result)
    }
}

extension DWrapper.Entity.ImgToolType {
    func getIcon() -> UIImage? {
        switch self {
        case .brightness: 
            return R.image.icon_brightness.callAsFunction()
        case .crop:
            return R.image.icon_cut.callAsFunction()
//        case .rotate:
//            return R.image.icon_rotate.callAsFunction()
        case .constrast:
            return R.image.icon_constrast.callAsFunction()
        case .exposure:
            return R.image.icon_exposure.callAsFunction()
        case .temperature:
            return R.image.icon_temperature.callAsFunction()
        case .saturation:
            return R.image.icon_saturation.callAsFunction()
        }
    }
    
    func getToolName() -> String {
        switch self {
        case .brightness:
            return "Brightness"
        case .crop:
            return "Crop"
//        case .rotate:
//            return "Rotate"
        case .constrast:
            return "Constrast"
        case .exposure:
            return "Exposure"
        case .temperature:
            return "Temperature"
        case .saturation:
            return "Saturation"
        }
    }
}
