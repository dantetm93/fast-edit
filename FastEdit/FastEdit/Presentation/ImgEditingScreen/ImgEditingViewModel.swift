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
    func saveProcessedImgToGallery(done: @escaping (Bool, String) -> Void)
    func needConfirmBeforeQuit() -> Bool
    
    func setStepHolder(val: IEdittingStepHolder)
    func undo()
    func redo()
    
    func setColorFilterUseCase(val: IColorFilterUseCase)
    func changeColorFilter(val: Double)
}

protocol IImgEditingViewModel: IImgEditingAction {
    typealias ProcessedImgPub = CurrentValueSubject<UIImage, Never>
    typealias ToolTypeChangedPub = PassthroughSubject<DWrapper.Entity.ImgToolType, Never>
    typealias ColorFilterRangePub = PassthroughSubject<DWrapper.Entity.ColorFilterRange, Never>

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
    func getColorFilterRangePub() -> ColorFilterRangePub
}

class ImgEditingViewModel {
    
    private let originalImg: UIImage
    private var croppingStyle = TOCropViewCroppingStyle.default
    private var proccesedImg: UIImage?
    private var lastResizedImg: UIImage?

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
    private let colorFilterRangePub = ColorFilterRangePub.init()

    init(originalImg: UIImage) { self.originalImg = originalImg }

    private var cropUseCase: ICropUseCase!
    func setCropUseCase(val: ICropUseCase) {
        self.cropUseCase = val
    }
    
    private var stepHolder: IEdittingStepHolder!
    func setStepHolder(val: IEdittingStepHolder) {
        self.stepHolder = val
    }
    
    private var isColorFilterTriggeredByUndoRedo = false
    private var isStartSavingImgToAlbum = false
    private var cancellable = Set<AnyCancellable>()
    private let defaultSerialQueue = DispatchQueue.init(label: "ImgEditingViewModel")
    private var colorFilterDebouncing = PassthroughSubject<DWrapper.Entity.ImgToolInfo, Never>()
    private var colorFilterUseCase: IColorFilterUseCase!
    func setColorFilterUseCase(val: IColorFilterUseCase) {
        self.colorFilterUseCase = val
        self.colorFilterUseCase.setOnPreviewing 
        {[unowned self] filteredImage in
            if self.isStartSavingImgToAlbum {
                return
            }
            // Just for previewing
            self.proccesedImg = filteredImage
            self.processedImgPub.send(filteredImage)
            
            if self.currentToolIndex == -1 { return } // This is unselected value
            let item = self.getImgToolAt(index: self.currentToolIndex)
            self.colorFilterDebouncing.send(item)
        }
        
        self.colorFilterDebouncing
            .debounce(for: 0.3, scheduler: self.defaultSerialQueue)
            .sink {[weak self] toolType in
                guard let self else { return }
                
                if self.isColorFilterTriggeredByUndoRedo {
                    self.isColorFilterTriggeredByUndoRedo = false
                    return
                }
                
                let range = self.colorFilterUseCase.getColorFilterRangeBy(type: toolType.type)
                AppLogger.d("ImgEditingViewModel", "User just applied: \(toolType.name) with value: \(range.current)", "", #line)
                let brightness = self.colorFilterUseCase.getCurrentBrightLevel()
                let constrast = self.colorFilterUseCase.getCurrentConstrastLevel()
                self.stepHolder.addStep(new: .init(type: toolType.type,
                                                   result: UIImage.init(),
                                                   brightness: brightness,
                                                   constrast: constrast))
                self.updateStateForUndoRedo()
                
            }.store(in: &self.cancellable)
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
        
        let brightness = self.colorFilterUseCase.getCurrentBrightLevel()
        let constrast = self.colorFilterUseCase.getCurrentConstrastLevel()
        let firstStep: EdittingStep = .init(type: .crop,
                                            result: self.originalImg,
                                            isFirst: true,
                                            brightness: brightness,
                                            constrast: constrast)
        self.stepHolder.addStep(new: firstStep)
        self.updateStateForUndoRedo()
        
        self.colorFilterUseCase.updateSourceImageForPreviewing(source: self.originalImg)
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
    
    private func getLastResizedImg() -> UIImage {
        if let lastResizedImg { return lastResizedImg }
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
    
    func getColorFilterRangePub() -> ColorFilterRangePub {
        return self.colorFilterRangePub
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
        let range = self.colorFilterUseCase.getColorFilterRangeBy(type: item.type)
        AppLogger.d("ImgEditingViewModel", "User just selected: \(item.type.getToolName()) with range: \(range)", "", #line)
        self.colorFilterRangePub.send(range)
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
    func saveProcessedImgToGallery(done: @escaping (Bool, String) -> Void) {
        self.isStartSavingImgToAlbum = true
        if let validUIImage = self.colorFilterUseCase.getValidUIImageForSavingInAlbum() {
            // Crop first then apply filter, so the final img will be processed by ColorFilter
            self.proccesedImg = validUIImage
        } else {
            // If we can not get a Valid Image from Color Filter, just take last resize Img
            self.proccesedImg = self.getLastResizedImg()
        }
        
        AlbumManager.current.save(image: self.getLastProcessedImg()) 
        {[weak self] error in
            self?.isStartSavingImgToAlbum = false
            switchToMain {
                if error == nil {
                    let mess = "Successfully saved your beautiful image to Gallery!"
                    done(true, mess)
                } else {
                    let rawString = String.init(describing: error)
                    if rawString.contains("3303") {
                        let mess = "Failed to save your image. The image's size was too big, in wrong format or Photo Gallery could not hold more image!"
                        done(true, mess)
                    } else {
                        done(false, String.init(describing: error))
                    }
                }
            }
        }
    }
    
    func needConfirmBeforeQuit() -> Bool {
        return true
    }
    
    // MARK: - Undo & Redo
    func getResetUIPub() -> VoidNoValuePub {
        return self.resetUIPub
    }
    
    func getCanUndoPub() -> BoolNoValuePub {
        return self.canUndoPub
    }
    
    func getCanRedoPub() -> BoolNoValuePub {
        return self.canRedoPub
    }
    
    private func updateStateForUndoRedo() {
        self.canUndoPub.send(self.stepHolder.canUndo())
        self.canRedoPub.send(self.stepHolder.canRedo())
    }
    
    func undo() {
        if let newCurrentStep = self.stepHolder.undo() {
            // Still can go back
            self.isColorFilterTriggeredByUndoRedo = true
            self.postHandleAfterUndoRedo(newStep: newCurrentStep)
        }
        self.updateStateForUndoRedo()
    }
    
    func redo() {
        if let newCurrentStep = self.stepHolder.redo() {
            // Still can go next
            self.isColorFilterTriggeredByUndoRedo = true
            self.postHandleAfterUndoRedo(newStep: newCurrentStep)
        }
        self.updateStateForUndoRedo()
    }
    
    private func postHandleAfterUndoRedo(newStep: EdittingStep) {
        switch newStep.type {
        case .crop:
            self.lastResizedImg = newStep.result
            // Re-apply filtering
            let newSourceForFiltering = self.getLastResizedImg()
            self.colorFilterUseCase.updateSourceImageForPreviewing(source: newSourceForFiltering)

        case .brightness:
            self.colorFilterUseCase.changeBrightLevel(to: newStep.brightness, applying: true)
        case .constrast:
            self.colorFilterUseCase.changeConstrastLevel(to: newStep.constrast, applying: true)
        case .exposure: break
            // TODO: exposure
        case .temperature: break
            // TODO: temperature
        case .saturation: break
            // TODO: saturation
        }
        
    }
    
    // MARK: - Image's frame/side handlers
    func cropTo(rect: CGRect, angle: Int) {
        let lastResizedImg = self.getLastResizedImg()
        let result = self.cropUseCase.cropTo(source: lastResizedImg, angle: angle, rect: rect)
        self.lastResizedImg = result // For original img that is used as source img of ColorFiltering
        self.proccesedImg = result // For displaying the final cut and filtered img
        self.colorFilterUseCase.updateSourceImageForPreviewing(source: result)
        
        self.resetUIToDefault()
        
        let brightness = self.colorFilterUseCase.getCurrentBrightLevel()
        let constrast = self.colorFilterUseCase.getCurrentConstrastLevel()
        self.stepHolder.addStep(new: .init(type: .crop,
                                           result: result,
                                           brightness: brightness,
                                           constrast: constrast))
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
    
    // MARK: - Color Filter handlers
    func changeColorFilter(val: Double) {
        let item = self.getImgToolAt(index: self.currentToolIndex)
        switch item.type {
        case .crop: break
        case .brightness:
            self.colorFilterUseCase.changeBrightLevel(to: val, applying: true)
        case .constrast:
            self.colorFilterUseCase.changeConstrastLevel(to: val, applying: true)
        case .exposure: break
            // TODO: exposure
        case .temperature: break
            // TODO: temperature
        case .saturation: break
            // TODO: saturation
        }
    }
}

extension DWrapper.Entity.ImgToolType {
    func getIcon() -> UIImage? {
        switch self {
        case .brightness: 
            return R.image.icon_brightness.callAsFunction()
        case .crop:
            return R.image.icon_cut.callAsFunction()
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
