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

    @IBOutlet weak var stackViewCropping: UIStackView!
    @IBOutlet weak var buttonCancelCropping: UIButton!
    @IBOutlet weak var buttonRotateLeft: UIButton!
    @IBOutlet weak var buttonResetCropping: UIButton!
    @IBOutlet weak var buttonRotateRight: UIButton!
    @IBOutlet weak var buttonConfirmCropping: UIButton!

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
        cropView.cropRegionInsets = .zero
        AppLogger.d(ImgEditingScreen.typeName, String.init(describing: cropView.frame), #fileID, #line)
        cropView.performInitialSetup()
        cropView.moveCroppedContentToCenter(animated: false)
    }
    
    // MARK: - Internal setup
    private func setupCollectionView() {
        self.collectionViewTool.register(EditingToolCollectionCell.self)
        self.collectionViewTool.delegate = self
        self.collectionViewTool.dataSource = self
        self.collectionViewTool.showsHorizontalScrollIndicator = false
    }
    
    private func setupResultImgView() {
        self.imgViewResult.backgroundColor = UIColor.init(hex: "#F0F0F0")
    }
    
    override func binding() {
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
    
    private func resetUIToDefault() {
        self.viewContainerSlider.isHidden = true
        self.stackViewCropping.isHidden = true
        self.collectionViewTool.reloadData()
        self.collectionViewTool.isHidden = false
        self.viewHeader.isHidden = false
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
            self.reCreateCroppingView()
            self.reLayoutCroppingView()
        default:
            self.viewHeader.isHidden = false
            self.viewContainerSlider.isHidden = false
            self.stackViewCropping.isHidden = true
            guard let cropView else { return }
            cropView.removeFromSuperview()
            self.cropView = nil
        }
    }
    
    private func setupUIAction() {
        self.buttonBack
            .onClick { _ in
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
            .onClick { _ in
                CustomLoading.show()
                self.getViewModel().saveProcessedImgToGallery {
                    CustomLoading.hide()
                    NavigationCenter.showToast(error: "Successfully saved to Gallery!", success: true)
                    NavigationCenter.back()
                }
            }
        
        self.buttonUndo
            .onClick { _ in
                self.getViewModel().undo()
            }
        
        self.buttonRedo
            .onClick { _ in
                self.getViewModel().redo()
            }
        
        // MARK: - Cropping UI action
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
                cropView.rotateImageNinetyDegrees(animated: true, clockwise: true)
            }
        
        self.buttonRotateLeft
            .onClick {[unowned self] _ in
                guard let cropView else { return }
                cropView.rotateImageNinetyDegrees(animated: true, clockwise: false)
            }
        
        self.buttonResetCropping.interactable = false
        self.buttonResetCropping
            .onClick {[unowned self] _ in
                self.resetCropViewLayout()
            }
    }
}
