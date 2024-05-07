//
//  D_ImgTool+CropUseCase.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 7/5/24.
//

import UIKit
import CoreImage

protocol ICropUseCase {
    func cropTo(source: UIImage, rect: CGRect) -> UIImage
    func cropToCenterSquare(source: UIImage) -> UIImage
    func cropToCenterCircle(source: UIImage) -> UIImage
}

extension DWrapper.UseCase {
    class CropImage {
        
        fileprivate func getSquareInImage(size: CGSize) -> CGRect {
            // The shortest side
            let sideLength = min(
                size.width,
                size.height
            )

            // Determines the x,y coordinate of a centered
            // sideLength by sideLength square
            let sourceSize = size
            let xOffset = (sourceSize.width - sideLength) / 2.0
            let yOffset = (sourceSize.height - sideLength) / 2.0

            // The cropRect is the rect of the image to keep,
            // in this case centered
            let cropRect = CGRect(
                x: xOffset,
                y: yOffset,
                width: sideLength,
                height: sideLength
            ).integral
            
            return cropRect
        }
    }
}

extension DWrapper.UseCase.CropImage: ICropUseCase {
    func cropTo(source: UIImage, rect: CGRect) -> UIImage {
        let sourceImage = source
        let cropRect = rect
        
        let sourceCGImage = sourceImage.cgImage!
        let croppedCGImage = sourceCGImage.cropping(
            to: cropRect
        )!

        // Use the cropped cgImage to initialize a cropped
        // UIImage with the same image scale and orientation
        let croppedImage = UIImage(
            cgImage: croppedCGImage,
            scale: sourceImage.imageRendererFormat.scale,
            orientation: sourceImage.imageOrientation
        )

        return croppedImage
    }
    
    func cropToCenterCircle(source: UIImage) -> UIImage {
       
        let sourceImage = source
        let cropRect = self.getSquareInImage(size: sourceImage.size)

        // A circular crop results in some transparency in the
        // cropped image, so set opaque to false to ensure the
        // cropped image does not include a background fill
        let imageRendererFormat = sourceImage.imageRendererFormat
        imageRendererFormat.opaque = false

        // UIGraphicsImageRenderer().image provides a block
        // interface to draw into in a new UIImage
        let circleCroppedImage = UIGraphicsImageRenderer(
            // The cropRect.size is the size of
            // the resulting circleCroppedImage
            size: cropRect.size,
            format: imageRendererFormat).image { context in
           
            // The drawRect is the cropRect starting at (0,0)
            let drawRect = CGRect(
                origin: .zero,
                size: cropRect.size
            )
         
            // addClip on a UIBezierPath will clip all contents
            // outside of the UIBezierPath drawn after addClip
            // is called, in this case, drawRect is a circle so
            // the UIBezierPath clips drawing to the circle
            UIBezierPath(ovalIn: drawRect).addClip()

            // The drawImageRect is offsets the image’s bounds
            // such that the circular clip is at the center of
            // the image
            let drawImageRect = CGRect(
                origin: CGPoint(
                    x: -cropRect.minX,
                    y: -cropRect.minY
                ),
                size: sourceImage.size
            )

            // Draws the sourceImage inside of the
            // circular clip
            sourceImage.draw(in: drawImageRect)
        }

        return circleCroppedImage
    }
    
    func cropToCenterSquare(source: UIImage) -> UIImage {
        let sourceImage = source
        let cropRect = self.getSquareInImage(size: sourceImage.size)

        // Center crop the image
        let sourceCGImage = sourceImage.cgImage!
        let croppedCGImage = sourceCGImage.cropping(
            to: cropRect
        )!

        // Use the cropped cgImage to initialize a cropped
        // UIImage with the same image scale and orientation
        let croppedImage = UIImage(
            cgImage: croppedCGImage,
            scale: sourceImage.imageRendererFormat.scale,
            orientation: sourceImage.imageOrientation
        )

        return croppedImage
    }
}
