//
//  D_ImgTool+ColorFilterUseCaseDefinition.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 13/5/24.
//

import Foundation
import CoreImage
import UIKit

public protocol IColorSimpleFilterUseCase {
    func changeFilter(source: CIImage, value: Double, hasPreview: Bool) -> DWrapper.Entity.FilteredImgInfo
    func getColorFilterType() -> DWrapper.Entity.ImgToolType
    func getCurrentFilterValue() -> Double
    func getColorFilterRange() -> DWrapper.Entity.ColorFilterRange
}

public protocol IColorFilterCombiningUseCase {
    func addFilterTool(val: IColorSimpleFilterUseCase)
    func removeFilterToolByType(type: DWrapper.Entity.ImgToolType)
    func changeFilterValueByType(value: Double, type: DWrapper.Entity.ImgToolType)
    func getColorFilterRangeBy(type: DWrapper.Entity.ImgToolType) -> DWrapper.Entity.ColorFilterRange
    func getCurrentFilterValueBy(type: DWrapper.Entity.ImgToolType) -> Double
    func getCurrentFilterParam() -> DWrapper.Entity.ColorFilterParam

    func updateSourceImage(source: UIImage, applying: Bool)
    func applyAllFilter() -> UIImage
    func exportValidImgForGallery() -> UIImage?
    func setOnChangeFilterValue(done: @escaping (UIImage) -> Void)
}
