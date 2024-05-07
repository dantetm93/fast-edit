//
//  UIListView+Extension.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 7/5/24.
//

import UIKit

extension UITableView {
    
    func register(_ cell: UITableViewCell.Type) {
        let nib = UINib(nibName: cell.typeName, bundle: nil)
        register(nib, forCellReuseIdentifier: cell.typeName)
    }

    func dequeueCell<T: NSObject>(_ indexPath: IndexPath) -> T {
        let cell = dequeueReusableCell(withIdentifier: T.typeName, for: indexPath) as! T
        return cell
    }
}

extension UICollectionView {
    
    func register(_ cell: UICollectionViewCell.Type) {
        let nib = UINib(nibName: cell.typeName, bundle: nil)
        register(nib, forCellWithReuseIdentifier: cell.typeName)
    }

    func dequeueCell<T: NSObject>(_ indexPath: IndexPath) -> T {
        let cell = dequeueReusableCell(withReuseIdentifier: T.typeName, for: indexPath) as! T
        return cell
    }
    
    var contentHeight: CGFloat {
        return self.collectionViewLayout.collectionViewContentSize.height
    }
}

class DynamicHeightColllectionView: UICollectionView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !(__CGSizeEqualToSize(bounds.size,self.intrinsicContentSize)){
            self.invalidateIntrinsicContentSize()
        }
    }
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}

extension UICollectionView {
    enum SupplementaryViewKind {
        case header
        case footer

        var rawValue: String {
            switch self {
            case .header:
                return UICollectionView.elementKindSectionHeader
            case .footer:
                return UICollectionView.elementKindSectionFooter
            }
        }
    }
}
