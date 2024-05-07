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
    func cropTo(rect: CGRect)
    func cropToCenterSquare(source: UIImage)
    func cropToCenterCircle()
}

protocol IImgEditingViewModel: IImgEditingAction {
    typealias ProcessedImgPub = CurrentValueSubject<UIImage?, Never>
    typealias CurrentToolNamePub = CurrentValueSubject<String, Never>
    typealias SingleToolValuePub = CurrentValueSubject<Double, Never>
    typealias ListToolPub = PassthroughSubject<Void, Never>

    func load()
    func getListImgToolCount() -> Int
    func getImgToolAt(index: Int) -> DWrapper.Entity.ImgToolInfo
    func selectImgToolAt(index: Int)
    func isSelectingToolAt(index: Int) -> Bool
    
    func getListToolPub() -> ListToolPub
    func getProcessedImgPub() -> ProcessedImgPub
    func getCurrentToolNamePub() -> CurrentToolNamePub
    func getCurrentSingleToolValue() -> SingleToolValuePub
}

class ImgEditingViewModel {
    
    private let originalImg: UIImage
    private var proccesedImg: UIImage?
    
    private var listImgTool: [DWrapper.Entity.ImgToolInfo] = []
    private var currentToolIndex: Int = 0 // First tool is default
    
    private let processedImgPub = ProcessedImgPub.init(nil)
    private let currentToolNamePub = CurrentToolNamePub.init("")
    private let singleToolValuePub = SingleToolValuePub.init(0)
    private let listToolPub = ListToolPub.init()
    
    init(originalImg: UIImage) { self.originalImg = originalImg }

    private var cropUseCase: ICropUseCase!
    func setCropUseCase(val: ICropUseCase) {
        self.cropUseCase = val
    }
    
}

extension ImgEditingViewModel: IImgEditingViewModel {
    
    func load() {
        self.listImgTool = DWrapper.Entity.ImgToolType.allCases.map({ type in
            return .init(name: type.getToolName(), type: type)
        })
        self.listToolPub.send(())
        
        self.processedImgPub.send(self.originalImg)
        
        let item = self.getImgToolAt(index: self.currentToolIndex)
        let name = item.type.getToolName()
        self.currentToolNamePub.send(name)
    }
    
    func getListToolPub() -> ListToolPub {
        return self.listToolPub
    }
    
    func getProcessedImgPub() -> ProcessedImgPub {
        return self.processedImgPub
    }
    
    func getCurrentToolNamePub() -> CurrentToolNamePub {
        return self.currentToolNamePub
    }
    
    func getCurrentSingleToolValue() -> SingleToolValuePub {
        return self.singleToolValuePub
    }
    
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
    }
    
    func isSelectingToolAt(index: Int) -> Bool {
        return self.currentToolIndex == index
    }

    func getLastProcessedImg() -> UIImage {
        if let proccesedImg { return proccesedImg }
        return self.originalImg
    }

    // MARK: - IImgEditingAction
    func cropTo(rect: CGRect) {
        let image = self.getLastProcessedImg()
        let result = self.cropUseCase.cropTo(source: image, rect: rect)
        self.proccesedImg = result
        self.processedImgPub.send(result)
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
        case .rotate:
            return R.image.icon_rotate.callAsFunction()
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
        case .rotate:
            return "Rotate"
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
