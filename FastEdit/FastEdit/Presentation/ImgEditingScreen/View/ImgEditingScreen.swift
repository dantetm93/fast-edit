//
//  ImgEditingScreen.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 7/5/24.
//

import UIKit
import Combine

class ImgEditingScreen: BaseScreen {

    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonUndo: UIButton!
    @IBOutlet weak var buttonRedo: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    
    @IBOutlet weak var labelCurrentTool: UILabel!
    @IBOutlet weak var sliderToolValue: UISlider!
    @IBOutlet weak var viewContainerSlider: UIView!
    
    @IBOutlet weak var imgViewResult: UIImageView!
    @IBOutlet weak var viewContainerOfCropping: UIView!
    
    @IBOutlet weak var collectionViewTool: UICollectionView!

    @IBOutlet weak var labelUndoRedoStatus: PaddingLabel!
    @IBOutlet weak var stackViewCropping: UIStackView!
    @IBOutlet weak var buttonCancelCropping: UIButton!
    @IBOutlet weak var buttonRotateLeft: UIButton!
    @IBOutlet weak var buttonResetCropping: UIButton!
    @IBOutlet weak var buttonRotateRight: UIButton!
    @IBOutlet weak var buttonConfirmCropping: UIButton!
    @IBOutlet weak var buttonSetRatio: UIButton!
    
    /**
     - (TOCropView *)cropView
     {
         // Lazily create the crop view in case we try and access it before presentation, but
         // don't add it until our parent view controller view has loaded at the right time
         if (!_cropView) {
             _cropView = [[TOCropView alloc] initWithCroppingStyle:self.croppingStyle image:self.image];
             _cropView.delegate = self;
             _cropView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
             [self.view addSubview:_cropView];
         }
         return _cropView;
     }
     */
    var cropView: TOCropView?
    
    // MARK: - [START] TOCropView's Property
    var isFinishedSetupCroppingView = false
    var aspectRatioPreset = TOCropViewControllerAspectRatioPreset.presetOriginal
    var customAspectRatio = CGSize.init(width: 16, height: 10)
    // MARK: [END] TOCropView's Property -

    private var cancellable = Set<AnyCancellable>()
    private var viewModel: IImgEditingViewModel!
    func setViewModel(val: IImgEditingViewModel) { self.viewModel = val }
    func getViewModel() -> IImgEditingViewModel { return self.viewModel }

    // MARK: - View Lifecyle -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        self.setupResultImgView()
        self.resetUIToDefault()
        self.setupUIAction()
        self.viewModel.load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // If an initial aspect ratio was set before presentation, set it now once the rest of
        // the setup will have been done
        
        if self.cropView == nil { return }
        if (self.aspectRatioPreset != .presetOriginal) {
            self.setAspectRatioPreset(aspectRatioPreset: self.aspectRatioPreset, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let cropView else { return }
        cropView.simpleRenderMode = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let cropView else { return }
        cropView.frame = self.viewContainerOfCropping.bounds
        
        // Avoid tapping and triggering Notification center, App Switcher,...
        cropView.cropRegionInsets = .init(top: 20, left: 0, bottom: 20, right: 0)
        
        cropView.performInitialSetup()
        cropView.moveCroppedContentToCenter(animated: false)
        
        AppLogger.d(ImgEditingScreen.typeName, String.init(describing: cropView.frame), #fileID, #line)
    }
    
    // MARK: - Binding -
    override func binding() {
        
        // -- UI content --
        self.viewModel.getListToolPub()
            .receive(on: DispatchQueue.main)
            .sink {[weak self] in
                self?.collectionViewTool.reloadData()
            }
            .store(in: &self.cancellable)
        
        self.viewModel.getProcessedImgPub()
            .receive(on: DispatchQueue.main)
            .sink {[weak self] value in
                self?.imgViewResult.image = value
            }
            .store(in: &self.cancellable)
        
        self.viewModel.getCurrentToolNamePub()
            .receive(on: DispatchQueue.main)
            .sink {[weak self] value in
                self?.labelCurrentTool.text = value
            }
            .store(in: &self.cancellable)
        
        self.viewModel.getCurrentSingleToolValue()
            .receive(on: DispatchQueue.main)
            .sink {[weak self] currentValue in
                self?.sliderToolValue.value = Float(currentValue)
            }
            .store(in: &self.cancellable)
        
        self.viewModel.getColorFilterRangePub()
            .receive(on: DispatchQueue.main)
            .sink {[weak self] range in
                self?.sliderToolValue.maximumValue = Float(range.max)
                self?.sliderToolValue.minimumValue = Float(range.min)
                self?.sliderToolValue.value = Float(range.current)
            }
            .store(in: &self.cancellable)
        
        self.viewModel.getColorFilterTrendPub()
            .receive(on: DispatchQueue.main)
            .sink {[weak self] trend in
                guard let self else { return }
                switch trend {
                case .base:
                    self.labelCurrentTool.textColor = self.sliderToolValue.thumbTintColor
                case .decrease:
                    self.labelCurrentTool.textColor = self.sliderToolValue.minimumTrackTintColor
                case .increase:
                    self.labelCurrentTool.textColor = self.sliderToolValue.maximumTrackTintColor
                }
            }
            .store(in: &self.cancellable)
        
        self.viewModel.getUndoRedoStatusPub()
            .receive(on: DispatchQueue.main)
            .sink {[weak self] statusText in
                guard let self else { return }
                self.labelUndoRedoStatus.isHidden = statusText.isEmpty
                self.labelUndoRedoStatus.text = statusText
            }
            .store(in: &self.cancellable)
        
        self.viewModel.getUndoRedoStatusPub()
            .debounce(for: 3, scheduler: DispatchQueue.main)
            .sink {[weak self] statusText in
                guard let self else { return }
                self.labelUndoRedoStatus.isHidden = true
            }
            .store(in: &self.cancellable)
        
        // -- UI visibility --
        self.viewModel.getSliderDisplayPub()
            .receive(on: DispatchQueue.main)
            .sink {[weak self] value in
                self?.sliderToolValue.isHidden = !value
            }
            .store(in: &self.cancellable)
        
        self.viewModel.getToolTypeChangedPub()
            .receive(on: DispatchQueue.main)
            .sink {[weak self] value in
                self?.updateUIByToolType(val: value)
            }
            .store(in: &self.cancellable)
        
        self.viewModel.getResetUIPub()
            .receive(on: DispatchQueue.main)
            .sink {[weak self] in
                self?.resetUIToDefault()
            }
            .store(in: &self.cancellable)
        
        // -- Undo & Redo --
        self.viewModel.getCanUndoPub()
            .receive(on: DispatchQueue.main)
            .sink {[weak self] doable in
                self?.buttonUndo.interactable = doable
            }
            .store(in: &self.cancellable)
        
        self.viewModel.getCanRedoPub()
            .receive(on: DispatchQueue.main)
            .sink {[weak self] doable in
                self?.buttonRedo.interactable = doable
            }
            .store(in: &self.cancellable)
    }
    
    // MARK: - UI Setup -
    private func setupCollectionView() {
        self.collectionViewTool.register(EditingToolCollectionCell.self)
        self.collectionViewTool.delegate = self
        self.collectionViewTool.dataSource = self
        self.collectionViewTool.showsHorizontalScrollIndicator = false
    }
    
    private func setupResultImgView() {
        self.imgViewResult.backgroundColor = UIColor.init(hex: "#F0F0F0")
    }
    
    private func resetUIToDefault() {
        self.viewContainerSlider.isHidden = true
        self.stackViewCropping.isHidden = true
        self.collectionViewTool.reloadData()
        self.collectionViewTool.isHidden = false
        self.viewHeader.isHidden = false
        self.labelUndoRedoStatus.text = ""
        guard let cropView else { return }
        cropView.removeFromSuperview()
        self.cropView = nil
    }
    
    private func updateUIByToolType(val: DWrapper.Entity.ImgToolType) {
        switch val {
        case .crop:
            self.viewHeader.isHidden = true
            self.stackViewCropping.isHidden = false
            self.viewContainerSlider.isHidden = true
            self.collectionViewTool.isHidden = true
            self.view.layoutIfNeeded()
            self.reCreateCroppingView()
            self.reLayoutCroppingView()
        default:
            self.viewHeader.isHidden = false
            self.viewContainerSlider.isHidden = false
            self.stackViewCropping.isHidden = true
            self.view.layoutIfNeeded()
            guard let cropView else { return }
            cropView.removeFromSuperview()
            self.cropView = nil
        }
    }
    
    // MARK: - UI Action -
    private func setupUIAction() {
        self.buttonBack
            .onClick {[unowned self] _ in
                if self.getViewModel().needConfirmBeforeQuit() {
                    let mess = "There are some unsaved changes. Do you want to keep editing or exit without saving?"
                    self.showDestructiveConfirm(mess,
                                     titleConfirm: "Exit",
                                     titleCancel: "Stay",
                                     onConfirm: { _ in NavigationCenter.back() },
                                     onCancel: { _ in })
                    return
                }
                NavigationCenter.back()
            }
        
        self.buttonSave
            .onClick {[unowned self] _ in
                CustomLoading.show()
                self.getViewModel().saveProcessedImgToGallery { success, error in
                    CustomLoading.hide()
                    NavigationCenter.showToast(error: error, success: success)
                    if success {
                        NavigationCenter.back()
                    }
                }
            }
        
        // -- Undo & Redo --
        self.buttonUndo
            .onClick {[unowned self] _ in
                self.getViewModel().undo()
            }
        
        self.buttonRedo
            .onClick {[unowned self] _ in
                self.getViewModel().redo()
            }
        
        // -- Cropping UI action --
        self.buttonCancelCropping
            .onClick {[unowned self] _ in
                self.viewModel.resetUIToDefault()
            }
        
        self.buttonConfirmCropping
            .onClick {[unowned self] _ in
                self.viewModel.resetUIToDefault()
                self.confirmCropping()
            }
        
        self.buttonRotateLeft
            .onClick {[unowned self] _ in
                guard let cropView else { return }
                cropView.rotateImageNinetyDegrees(animated: true, clockwise: false)
            }
        
        self.buttonRotateRight
            .onClick {[unowned self] _ in
                guard let cropView else { return }
                cropView.rotateImageNinetyDegrees(animated: true, clockwise: true)
            }
        
        self.buttonSetRatio
            .onClick {[unowned self] _ in
                guard let cropView else { return }
                self.showActionSheetForCroppingRatio()
            }
        
        self.buttonResetCropping.interactable = false
        self.buttonResetCropping
            .onClick {[unowned self] _ in
                self.resetCropViewLayout()
            }
        
        // -- Cropping UI action --
        self.sliderToolValue.addTarget(self, action: #selector(onSliderChanged), for: .valueChanged)
    }
    
    @objc private func onSliderChanged() {
        let currentColorFilterValue = Double(self.sliderToolValue.value)
        self.getViewModel().changeColorFilter(val: currentColorFilterValue)
    }
    
    private func showActionSheetForCroppingRatio() {
        let alertController = UIAlertController(title: "Select the cropping ratio", message: "", preferredStyle: .actionSheet)
        
        let ratio1 = UIAlertAction(title: "Freeform", style: .default, handler: {[weak self] alert in
            guard let self = self else { return }
            self.setAspectRatioPreset(aspectRatioPreset: .presetOriginal, animated: true)
        })
        
        let ratio2 = UIAlertAction(title: "3:2", style: .default, handler: {[weak self] alert in
            guard let self = self else { return }
            self.setAspectRatioPreset(aspectRatioPreset: .preset3x2, animated: true)
        })
        
        let ratio3 = UIAlertAction(title: "4:3", style: .default, handler: {[weak self] alert in
            guard let self = self else { return }
            self.setAspectRatioPreset(aspectRatioPreset: .preset4x3, animated: true)
        })
        
        let ratio4 = UIAlertAction(title: "7:5", style: .default, handler: {[weak self] alert in
            guard let self = self else { return }
            self.setAspectRatioPreset(aspectRatioPreset: .preset7x5, animated: true)
        })
        
        let ratio5 = UIAlertAction(title: "16:9", style: .default, handler: {[weak self] alert in
            guard let self = self else { return }
            self.setAspectRatioPreset(aspectRatioPreset: .preset16x9, animated: true)
        })
        
        alertController.addAction(ratio1)
        alertController.addAction(ratio2)
        alertController.addAction(ratio3)
        alertController.addAction(ratio4)
        alertController.addAction(ratio5)
        
        let cancelAction = UIAlertAction(title: "Close", style: .cancel, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view //to set the source of your alert
            // you can set this as per your requirement.
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
        }
        
        self.present(alertController, animated: true)
    }
    
    deinit {
        print("\(self.objectName) deinit" )
    }
}
