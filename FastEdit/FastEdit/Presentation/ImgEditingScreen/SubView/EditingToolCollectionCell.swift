//
//  EditingToolCollectionCell.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 7/5/24.
//

import UIKit

class EditingToolCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imgToolIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let colorValue: CGFloat = 235 / 255
        self.backgroundColor = .init(red: colorValue, green: colorValue, blue: colorValue, alpha: 1)
        self.layer.borderColor = .init(red: 1, green: 0, blue: 0, alpha: 1)
    }

}
