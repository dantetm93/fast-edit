//
//  ImgEditingViewModel.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 7/5/24.
//

import UIKit
import Combine

protocol IImgEditingAction {
    
    func setCropUseCase(val: ISizeEditing)
    func cropTo(rect: CGRect, angle: Int)
    func cropToCenterSquare(source: UIImage)
    func cropToCenterCircle()
    func saveProcessedImgToGallery(done: @escaping (Bool, String) -> Void)
    func needConfirmBeforeQuit() -> Bool
    
    func setStepHolder(val: IEditingStepHolder)
    func undo()
    func redo()
    
    func setColorCombiningUseCase(val: IColorFilterCombiningUseCase)
    func changeColorFilter(val: Double)
}

protocol IImgEditingViewModel: IImgEditingAction {
    typealias ProcessedImgPub = CurrentValueSubject<UIImage, Never>
    typealias ToolTypeChangedPub = PassthroughSubject<DWrapper.Entity.ImgToolType, Never>
    typealias ColorFilterRangePub = PassthroughSubject<DWrapper.Entity.ColorFilterRange, Never>
    typealias ColorFilterValueTrendPub = PassthroughSubject<ColorFilterValueTrend, Never>

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
    func getColorFilterTrendPub() -> ColorFilterValueTrendPub
    func getUndoRedoStatusPub() -> StringValuePub
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
    private let colorFilterValueTrendPub = ColorFilterValueTrendPub.init()
    private let undoRedoStatus = StringValuePub.init("")
    
    private lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter.init()
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.positivePrefix = "+"
        numberFormatter.negativePrefix = "-"
        return numberFormatter
    }()

    init(originalImg: UIImage) { 
        self.originalImg = originalImg
    }

    private var sizeEditingUseCase: ISizeEditing!
    func setCropUseCase(val: ISizeEditing) {
        self.sizeEditingUseCase = val
    }
    
    private var stepHolder: IEditingStepHolder!
    func setStepHolder(val: IEditingStepHolder) {
        self.stepHolder = val
    }
    
    private var isColorFilterTriggeredByUndoRedo = false
    private var isStartSavingImgToAlbum = false
    private var cancellable = Set<AnyCancellable>()
    private let defaultSerialQueue = DispatchQueue.init(label: "ImgEditingViewModel")
    private var colorFilterDebouncing = PassthroughSubject<DWrapper.Entity.ImgToolInfo, Never>()
    private var colorFilterUseCase: IColorFilterCombiningUseCase!
    func setColorCombiningUseCase(val: IColorFilterCombiningUseCase) {
        self.colorFilterUseCase = val
        self.colorFilterUseCase.setOnChangeFilterValue
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
            .debounce(for: 0.2, scheduler: self.defaultSerialQueue)
            .sink {[weak self] tool in
                guard let self else { return }
                
                if self.isColorFilterTriggeredByUndoRedo {
                    self.isColorFilterTriggeredByUndoRedo = false
                    return
                }
                
                self.addColorFilterToEditingStep(type: tool.type)
                self.updateStateForUndoRedo()
                
            }.store(in: &self.cancellable)
    }
    
    private func addSizeEdittingToEditingStep(image: UIImage) {
        let croppingType = DWrapper.Entity.ImgToolType.crop
        AppLogger.d("ImgEditingViewModel", "User just applied: \(croppingType.getToolName()) with value: \(String.init(describing: image.size))", "", #line)
        
        let filterParam = self.colorFilterUseCase.getCurrentFilterParam()
        self.stepHolder.addStep(new: .init(type: croppingType,
                                           result: image,
                                           filterParam: filterParam))
    }
    
    private func addColorFilterToEditingStep(type: DWrapper.Entity.ImgToolType) {
        let range = self.colorFilterUseCase.getColorFilterRangeBy(type: type)
        AppLogger.d("ImgEditingViewModel", "User just applied: \(type.getToolName()) with value: \(range.current)", "", #line)
        
        let filterParam = self.colorFilterUseCase.getCurrentFilterParam()
        self.stepHolder.addStep(new: .init(type: type,
                                           result: UIImage.init(),
                                           filterParam: filterParam))
    }
    
    deinit {
        print("ImgEditingViewModel deinit" )
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
        
        self.addSizeEdittingToEditingStep(image: self.originalImg)
        self.updateStateForUndoRedo()
        
        self.colorFilterUseCase.updateSourceImage(source: self.originalImg, applying: false)
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
    
    func getColorFilterTrendPub() -> ColorFilterValueTrendPub {
        return self.colorFilterValueTrendPub
    }
    
    func getUndoRedoStatusPub() -> StringValuePub {
        return self.undoRedoStatus
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
        self.showCurrentToolWithValue()
        
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
        if self.needConfirmBeforeQuit() {
            // User already made some changes
            if let validUIImage = self.colorFilterUseCase.exportValidImgForGallery() {
                // Crop first then apply filter, so the final img will be processed by ColorFilter
                self.proccesedImg = validUIImage
            } else {
                // If we can not get a Valid Image from Color Filter, just take last resize Img
                self.proccesedImg = self.getLastResizedImg()
            }
        } else {
            // User doesnt make any change or undo until there is no change
            self.proccesedImg = self.getOriginalImg()
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
        return self.stepHolder.canUndo() || self.stepHolder.canRedo()
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
        AppLogger.d("ImgEditingViewModel", "User clicks [UNDO]", "", #line)
        if let newCurrentStep = self.stepHolder.undo() {
            // Still can go back
            self.isColorFilterTriggeredByUndoRedo = true
            self.postHandleAfterUndoRedo(newStep: newCurrentStep)
            self.undoRedoStatus.send("[Undo] \(newCurrentStep.type.getToolName())")
            if self.needUpdateColorFilterUIAfterUndoRedo(step: newCurrentStep) {
                self.updateColorFilterSlider(step: newCurrentStep)
                self.showCurrentToolWithValue()
            }
        }
        self.updateStateForUndoRedo()
    }
    
    func redo() {
        AppLogger.d("ImgEditingViewModel", "User clicks [REDO]", "", #line)
        if let newCurrentStep = self.stepHolder.redo() {
            // Still can go next
            self.isColorFilterTriggeredByUndoRedo = true
            self.postHandleAfterUndoRedo(newStep: newCurrentStep)
            self.undoRedoStatus.send("[Redo] \(newCurrentStep.type.getToolName())")
            if self.needUpdateColorFilterUIAfterUndoRedo(step: newCurrentStep) {
                self.updateColorFilterSlider(step: newCurrentStep)
                self.showCurrentToolWithValue()
            }
        }
        self.updateStateForUndoRedo()
    }
    
    private func postHandleAfterUndoRedo(newStep: EditingStep) {
        switch newStep.type {
        case .crop:
            self.lastResizedImg = newStep.result
            // Re-apply filtering
            let newSourceForFiltering = self.getLastResizedImg()
            self.colorFilterUseCase.updateSourceImage(source: newSourceForFiltering, applying: true)
        default:
            let value = newStep.filterParam.getValueBy(type: newStep.type)
            self.colorFilterUseCase.changeFilterValueByType(value: value, type: newStep.type)
        }
    }
    
    // MARK: - Image's frame/side handlers
    func cropTo(rect: CGRect, angle: Int) {
        let lastResizedImg = self.getLastResizedImg()
        let result = self.sizeEditingUseCase.cropTo(source: lastResizedImg, angle: angle, rect: rect)
        self.lastResizedImg = result // For original img that is used as source img of ColorFiltering
        self.proccesedImg = result // For displaying the final cut and filtered img
        self.colorFilterUseCase.updateSourceImage(source: result, applying: true)
        
        self.resetUIToDefault()
    
        self.addSizeEdittingToEditingStep(image: result)
        self.updateStateForUndoRedo()
    }
    
    func cropToCenterSquare(source: UIImage) {
        let image = self.getLastProcessedImg()
        let result = self.sizeEditingUseCase.cropToCenterSquare(source: image)
        self.proccesedImg = result
        self.processedImgPub.send(result)
    }
    
    func cropToCenterCircle() {
        let image = self.getLastProcessedImg()
        let result = self.sizeEditingUseCase.cropToCenterCircle(source: image)
        self.proccesedImg = result
        self.processedImgPub.send(result)
    }
    
    // MARK: - Color Filter handlers
    func changeColorFilter(val: Double) {
        let rounded = round(val * 100) / 100
        if !rounded.isEqual(to: val) { return }
        let item = self.getImgToolAt(index: self.currentToolIndex)
        switch item.type {
        case .crop: break
        default: self.colorFilterUseCase.changeFilterValueByType(value: rounded, type: item.type)
        }
        
        // Update on UI
        self.showCurrentToolWithValue()
    }
    
    private func needUpdateColorFilterUIAfterUndoRedo(step: EditingStep) -> Bool {
        let item = self.getImgToolAt(index: self.currentToolIndex)
        return step.type == item.type
    }
    
    private func updateColorFilterSlider(step: EditingStep) {
        let range = self.colorFilterUseCase.getColorFilterRangeBy(type: step.type)
        self.singleToolValuePub.send(range.current)
    }
  
    private func showCurrentToolWithValue() {
        let item = self.getImgToolAt(index: self.currentToolIndex)
        let range = self.colorFilterUseCase.getColorFilterRangeBy(type: item.type)
        
        // Color for label of current value
        let trend: ColorFilterValueTrend
        = range.current.isEqual(to: range.center)
        ? .base : (range.current > range.center ? .increase : .decrease)
        self.colorFilterValueTrendPub.send(trend)
        
        // Text for label of current value
        let diffValue = range.current - range.center
        let percentValue = round(diffValue / range.distance * 100)
        if percentValue.isEqual(to: 0) {
            self.currentToolNamePub.send("\(item.type.getToolName()): --")
            return
        }
        
        let simpleFormattedValue = String.init(format: "%0.0f", percentValue)
        let formattedValue = self.numberFormatter.string(from: NSNumber.init(floatLiteral: percentValue)) ?? simpleFormattedValue
        
        switch item.type {
        case .crop:
            self.currentToolNamePub.send("")
        default:
            self.currentToolNamePub.send("\(item.type.getToolName()): \(formattedValue)%")
        }
    }
}
