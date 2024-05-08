//
//  ImgEdittingScreen+CroppingView.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 8/5/24.
//

import Foundation

extension ImgEditingScreen: TOCropViewDelegate {
    
    func setupCroppingView() {
        self.reCreateCroppingView()
        guard let cropView = self.cropView else { return }
        cropView.simpleRenderMode = true
    }
    
    func reCreateCroppingView() {
        if let cropView = self.cropView { cropView.removeFromSuperview() }
        let image = self.getViewModel().getLastProcessedImg()
        let style = self.getViewModel().getCroppingStyle()
        let cropView = TOCropView.init(croppingStyle: style, image: image)
        cropView.delegate = self
        cropView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.viewContainerOfCropping.addSubview(cropView)
        self.cropView = cropView
    }
    
    func reLayoutCroppingView() {
        guard let cropView = self.cropView else { return }
        cropView.frame = self.viewContainerOfCropping.bounds
        cropView.cropRegionInsets = .zero
        cropView.performInitialSetup()
        cropView.moveCroppedContentToCenter(animated: false)
        AppLogger.d(ImgEditingScreen.typeName, String.init(describing: cropView.frame), #fileID, #line)
        cropView.simpleRenderMode = false
    }
    
    /**
     - (void)setAspectRatioPreset:(TOCropViewControllerAspectRatioPreset)aspectRatioPreset animated:(BOOL)animated
     {
         CGSize aspectRatio = CGSizeZero;
         
         _aspectRatioPreset = aspectRatioPreset;
         
         switch (aspectRatioPreset) {
             case TOCropViewControllerAspectRatioPresetOriginal:
                 aspectRatio = CGSizeZero;
                 break;
             case TOCropViewControllerAspectRatioPresetSquare:
                 aspectRatio = CGSizeMake(1.0f, 1.0f);
                 break;
             case TOCropViewControllerAspectRatioPreset3x2:
                 aspectRatio = CGSizeMake(3.0f, 2.0f);
                 break;
             case TOCropViewControllerAspectRatioPreset5x3:
                 aspectRatio = CGSizeMake(5.0f, 3.0f);
                 break;
             case TOCropViewControllerAspectRatioPreset4x3:
                 aspectRatio = CGSizeMake(4.0f, 3.0f);
                 break;
             case TOCropViewControllerAspectRatioPreset5x4:
                 aspectRatio = CGSizeMake(5.0f, 4.0f);
                 break;
             case TOCropViewControllerAspectRatioPreset7x5:
                 aspectRatio = CGSizeMake(7.0f, 5.0f);
                 break;
             case TOCropViewControllerAspectRatioPreset16x9:
                 aspectRatio = CGSizeMake(16.0f, 9.0f);
                 break;
             case TOCropViewControllerAspectRatioPresetCustom:
                 aspectRatio = self.customAspectRatio;
                 break;
         }
         
         // If the aspect ratio lock is not enabled, allow a swap
         // If the aspect ratio lock is on, allow a aspect ratio swap
         // only if the allowDimensionSwap option is specified.
         BOOL aspectRatioCanSwapDimensions = !self.aspectRatioLockEnabled ||
                                     (self.aspectRatioLockEnabled && self.aspectRatioLockDimensionSwapEnabled);
         
         //If the image is a portrait shape, flip the aspect ratio to match
         if (self.cropView.cropBoxAspectRatioIsPortrait &&
             aspectRatioCanSwapDimensions)
         {
             CGFloat width = aspectRatio.width;
             aspectRatio.width = aspectRatio.height;
             aspectRatio.height = width;
         }
         
         [self.cropView setAspectRatio:aspectRatio animated:animated];
     }
     */
    func setAspectRatioPreset(aspectRatioPreset: TOCropViewControllerAspectRatioPreset, animated: Bool) {
        var aspectRatio = CGSize.zero
        self.aspectRatioPreset = aspectRatioPreset
        
        guard let cropView = self.cropView else { return }
        
        switch (aspectRatioPreset) {
        case .presetOriginal:
            aspectRatio = .zero
        case .presetSquare:
            aspectRatio = .init(width: 1, height: 1)
        case .preset3x2:
            aspectRatio = .init(width: 3, height: 2)
        case .preset5x3:
            aspectRatio = .init(width: 5, height: 3)
        case .preset4x3:
            aspectRatio = .init(width: 4, height: 3)
        case .preset5x4:
            aspectRatio = .init(width: 5, height: 4)
        case .preset7x5:
            aspectRatio = .init(width: 7, height: 5)
        case .preset16x9:
            aspectRatio = .init(width: 16, height: 9)
        case .presetCustom:
            aspectRatio = self.customAspectRatio
        }
        
        // If the aspect ratio lock is not enabled, allow a swap
        // If the aspect ratio lock is on, allow a aspect ratio swap
        // only if the allowDimensionSwap option is specified.
        let aspectRatioCanSwapDimensions = !cropView.aspectRatioLockEnabled ||
        (cropView.aspectRatioLockEnabled && cropView.aspectRatioLockDimensionSwapEnabled)
        
        //If the image is a portrait shape, flip the aspect ratio to match
        if cropView.cropBoxAspectRatioIsPortrait && aspectRatioCanSwapDimensions {
            let width = aspectRatio.width
            aspectRatio.width = aspectRatio.height
            aspectRatio.height = width
        }
        
        cropView.setAspectRatio(aspectRatio, animated: animated)
    }
    
    // MARK: - TOCropViewDelegate -
//    - (void)cropViewDidBecomeResettable:(TOCropView *)cropView
//    {
//        self.toolbar.resetButtonEnabled = YES;
//    }
    func cropViewDidBecomeResettable(_ cropView: TOCropView) {
        AppLogger.d(ImgEditingScreen.typeName, "cropViewDidBecomeResettable", "", #line)
        self.buttonResetCropping.interactable = true
    }
    
//    - (void)cropViewDidBecomeNonResettable:(TOCropView *)cropView
//    {
//        self.toolbar.resetButtonEnabled = NO;
//    }
    func cropViewDidBecomeNonResettable(_ cropView: TOCropView) {
        AppLogger.d(ImgEditingScreen.typeName, "cropViewDidBecomeNonResettable", "", #line)
        self.buttonResetCropping.interactable = false
    }
    
    /**
     - (void)resetCropViewLayout
     {
         BOOL animated = (self.cropView.angle == 0);
         
         if (self.resetAspectRatioEnabled) {
             self.aspectRatioLockEnabled = NO;
         }
         
         [self.cropView resetLayoutToDefaultAnimated:animated];
     }
     */
    
    func resetCropViewLayout() {
        guard let cropView = self.cropView else { return }
        let animated = cropView.angle == 0
        if cropView.resetAspectRatioEnabled {
            cropView.aspectRatioLockEnabled = false
        }
        cropView.resetLayoutToDefault(animated: animated)
    }
    
    func confirmCropping() {
        guard let cropView = self.cropView else { return }
        let cropFrame = cropView.imageCropFrame
        let angle = cropView.angle
        self.getViewModel().cropTo(rect: cropFrame, angle: angle)
    }
}
