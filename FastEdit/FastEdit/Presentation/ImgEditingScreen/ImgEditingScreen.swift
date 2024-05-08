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
    }
    
    private func resetUIToDefault() {
        self.viewContainerSlider.isHidden = true
        self.stackViewCropping.isHidden = true
        guard let cropView else { return }
        cropView.removeFromSuperview()
    }
    
    private func updateUIByToolType(val: DWrapper.Entity.ImgToolType) {
        switch val {
        case .crop:
            self.reCreateCroppingView()
            self.reLayoutCroppingView()
            self.stackViewCropping.isHidden = false
            self.viewContainerSlider.isHidden = true
        case .rotate:
            break
        default:
            self.viewContainerSlider.isHidden = false
            self.stackViewCropping.isHidden = true
            guard let cropView else { return }
            cropView.removeFromSuperview()
        }
    }
    
    private func setupUIAction() {
        self.buttonBack
            .onClick { _ in
                NavigationCenter.back()
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

extension ImgEditingScreen: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func getPadding() -> UIEdgeInsets {
        return .init(top: 10, left: 20, bottom: 10, right: 20)
    }
    
    func getCellSize(container: UIView, padding: UIEdgeInsets) -> CGSize {
        let height = container.bounds.height
        let padding = padding.bottom + padding.top
        let width = height - padding
        return CGSize.init(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return self.getPadding()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.getCellSize(container: collectionView, padding: self.getPadding())
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.getViewModel().getListImgToolCount()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imgTool = self.getViewModel().getImgToolAt(index: indexPath.item)
        let cell: EditingToolCollectionCell = collectionView.dequeueCell(indexPath)
        cell.imgToolIcon.image = imgTool.type.getIcon()
        
        let cellSize = self.getCellSize(container: collectionView, padding: self.getPadding())
        cell.layer.cornerRadius = cellSize.height / 2
        cell.clipsToBounds = true
        
        let isSelecting = self.getViewModel().isSelectingToolAt(index: indexPath.item)
        cell.layer.borderWidth = isSelecting ? 4 : 0
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        self.getViewModel().selectImgToolAt(index: indexPath.item)
        collectionView.reloadData()
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
//            if let first = self.collectionView.indexPathsForVisibleItems.sorted(by: { $0.item < $1.item }).first {
//                self.lastVisibleIndexPath = first
//            }
//            
//            let shouldLoadNextByUI = scrollView.contentOffset.y + scrollView.frame.height + 50 >= scrollView.contentSize.height
//            
//            let totalassetCount = self.getListAssetCount()
//            if totalassetCount > 0 && totalassetCount % AssetRepository.assetPageSize != 0 { return }
//            
//            if shouldLoadNextByUI {
//                let albumDocId = self.albums[self.indexAlbum].document_id
//                self.loadAsset(albumDocId: albumDocId)
//            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if let first = self.collectionView.indexPathsForVisibleItems.sorted(by: { $0.item < $1.item }).first {
//            self.lastVisibleIndexPath = first
//        }
        
//        let shouldLoadNextByUI = scrollView.contentOffset.y + scrollView.frame.height + 50 >= scrollView.contentSize.height
//        let totalassetCount = self.getListAssetCount()
//
//        if totalassetCount > 0 && totalassetCount % AssetRepository.assetPageSize != 0 { return }
//        if shouldLoadNextByUI {
//            let albumDocId = self.albums[self.indexAlbum].document_id
//            self.loadAsset(albumDocId: albumDocId)
//        }
    }
}
