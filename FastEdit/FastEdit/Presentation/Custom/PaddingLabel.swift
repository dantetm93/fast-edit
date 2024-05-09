//
//  PaddingLabel.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 9/5/24.
//

import Foundation

class PaddingLabel: UILabel {
    
    @IBInspectable var top: CGFloat = CGFloat(-2)
    @IBInspectable var left: CGFloat = CGFloat(14)
    @IBInspectable var bottom: CGFloat = CGFloat(-2)
    @IBInspectable var right: CGFloat = CGFloat(14)
    @IBInspectable var cornerRadius: CGFloat = CGFloat(4)

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: top, left: left, bottom: bottom, right: right)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        var origin = super.intrinsicContentSize
        origin.width += left + right
        origin.height += top + bottom
        return origin
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = self.cornerRadius
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.cornerRadius = self.cornerRadius
        self.clipsToBounds = true
    }
}
