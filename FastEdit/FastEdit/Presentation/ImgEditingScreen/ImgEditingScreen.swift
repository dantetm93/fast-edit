//
//  ImgEditingScreen.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 7/5/24.
//

import UIKit
import Combine

class ImgEditingScreen: BaseScreen {

    @IBOutlet weak var collectionViewTool: UICollectionView!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonUndo: UIButton!
    @IBOutlet weak var buttonRedo: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var imgViewProcessing: UIImageView!
    @IBOutlet weak var labelCurrentTool: UILabel!
    @IBOutlet weak var sliderToolValue: UIView!
    @IBOutlet weak var viewContainerSlider: UIView!
    
    private var cancellable = Set<AnyCancellable>()
    private var viewModel: IImgEditingViewModel!
    func setViewModel(val: IImgEditingViewModel) { self.viewModel = val }
    func getViewModel() -> IImgEditingViewModel { return self.viewModel }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        self.viewModel.load()
    }
    
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
                self?.imgViewProcessing.image = value
            }
            .store(in: &self.cancellable)
        
        self.viewModel.getCurrentToolNamePub()
            .receive(on: DispatchQueue.main)
            .sink {[weak self] value in
                self?.labelCurrentTool.text = value
            }
            .store(in: &self.cancellable)
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
