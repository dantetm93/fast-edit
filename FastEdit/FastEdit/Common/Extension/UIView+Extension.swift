//
//  UIView+Extension.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 7/5/24.
//

import UIKit

extension UIView {
    
    public class func loadNib<T: UIView>(_ viewType: T.Type) -> T {
        let className = viewType.typeName
        return Bundle(for: viewType).loadNibNamed(className, owner: nil, options: nil)!.first as! T
    }

    public class func loadNib() -> Self {
        return loadNib(self)
    }
    
    public class func cellNib() -> UINib {
        let frameworkBundle = Bundle(for: self)
        return UINib(nibName: self.typeName, bundle: frameworkBundle)
    }
    
    func startHeartbeat(needRemove: Bool = true) {
        if let _ = self.layer.animation(forKey: "hearbeatAnimation") {
            return
        }
        
        let pulse1 = CABasicAnimation(keyPath: "transform.scale")
        pulse1.duration = 0.5
        pulse1.fromValue = 1.0
        pulse1.toValue = 1.10
        pulse1.autoreverses = true
        pulse1.repeatCount = .infinity
        pulse1.isRemovedOnCompletion = true
        pulse1.setValue("hearbeatAnimation", forKey: "animationID")
        self.layer.add(pulse1, forKey: "hearbeatAnimation")
    }

    func endHeartbeat() {
        self.layer.removeAnimation(forKey: "hearbeatAnimation")
    }
    
    func dropCommonShadow() {
        self.dropShadow(color: UIColor.black.withAlphaComponent(0.1), offSet: CGSize.zero, radius: 6, isRouned: true)
    }
    
    func dropShadow(color: UIColor, opacity: Float = 1, offSet: CGSize, radius: CGFloat, scale: Bool = true, isRouned: Bool = false) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        if isRouned {
            layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: layer.cornerRadius).cgPath
        } else {
            layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        }
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func makeSketelon(corner: CGFloat = 0) {
        let grayView = UIView()
        grayView.backgroundColor = .systemGray5
        grayView.translatesAutoresizingMaskIntoConstraints = false
        grayView.tag = 100000
        self.addSubview(grayView)
        let constraint = [
            grayView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            grayView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            grayView.widthAnchor.constraint(equalTo: self.widthAnchor),
            grayView.heightAnchor.constraint(equalTo: self.heightAnchor),
        ]
        grayView.layer.cornerRadius = corner
        NSLayoutConstraint.activate(constraint)
        grayView.layoutIfNeeded()
    }
    
    func hideSkeleton() {
        self.viewWithTag(100000)?.removeFromSuperview()
    }
    
    var interactable: Bool {
        get { return self.isUserInteractionEnabled }
        set {
            self.isUserInteractionEnabled = newValue
            self.alpha = newValue ? 1 : 0.4
        }
    }
    
    
    func toImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0)
        defer { UIGraphicsEndImageContext() }
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
    
    func toImageView() -> UIImageView {
        let imageView = UIImageView(frame: self.bounds)
        imageView.image = self.toImage()
        return imageView
    }
    
    func toSnapshotImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        self.snapshotView(afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }

    // OUTPUT 1
    func dropBottomShadow(color: UIColor = UIColor.lightGray, scale: Bool = true, offSet: CGFloat = 2, radius: CGFloat = 2, opacity: Float = 0.5) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize(width: 0, height: offSet)
        layer.shadowRadius = radius

        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }

    // OUTPUT 1
    func dropTopShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowRadius = 2

        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func hideShadow() {
        layer.shadowOpacity = 0
    }
    
    func changeEnable(_ isEnable: Bool) {
        self.isUserInteractionEnabled = isEnable
        self.alpha = isEnable ? 1 : 0.4
    }
    
    @IBInspectable var shadowColor: UIColor? {
        get {
            guard let color = layer.shadowColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    /// SwifterSwift: Shadow opacity of view; also inspectable from Storyboard.
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    /// SwifterSwift: Shadow radius of view; also inspectable from Storyboard.
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }

    // different inner shadow styles
    public enum InnerShadowSide {
        case all, left, right, top, bottom, topAndLeft, topAndRight, bottomAndLeft, bottomAndRight, exceptLeft, exceptRight, exceptTop, exceptBottom
    }

    // define function to add inner shadow
    public func addInnerShadow(
        onSide: InnerShadowSide, shadowColor: UIColor,
        shadowSize: CGFloat, cornerRadius: CGFloat = 0.0,
        shadowOpacity: Float, customFrame: CGRect?) {

        // define and set a shaow layer
        let shadowLayer = CAShapeLayer()
        shadowLayer.frame = (customFrame != nil) ? customFrame! : bounds
        shadowLayer.shadowColor = shadowColor.cgColor
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        shadowLayer.shadowOpacity = shadowOpacity
        shadowLayer.shadowRadius = shadowSize
        shadowLayer.fillRule = CAShapeLayerFillRule.evenOdd

        // define shadow path
        let shadowPath = CGMutablePath()

        // define outer rectangle to restrict drawing area
        let insetRect = bounds.insetBy(dx: -shadowSize * 2.0, dy: -shadowSize * 2.0)

        // define inner rectangle for mask
        let innerFrame: CGRect = { () -> CGRect in
            switch onSide {
            case .all:
                return CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height)
            case .left:
                return CGRect(x: 0.0, y: -shadowSize * 2.0, width: frame.size.width + shadowSize * 2.0, height: frame.size.height + shadowSize * 4.0)
            case .right:
                return CGRect(x: -shadowSize * 2.0,
                              y: -shadowSize * 2.0,
                              width: frame.size.width + shadowSize * 2.0,
                              height: frame.size.height + shadowSize * 4.0)
            case .top:
                return CGRect(x: -shadowSize * 2.0, y: 0.0, width: frame.size.width + shadowSize * 4.0, height: frame.size.height + shadowSize * 2.0)
            case.bottom:
                return CGRect(x: -shadowSize * 2.0,
                              y: -shadowSize * 2.0,
                              width: frame.size.width + shadowSize * 4.0,
                              height: frame.size.height + shadowSize * 2.0)
            case .topAndLeft:
                return CGRect(x: 0.0, y: 0.0, width: frame.size.width + shadowSize * 2.0, height: frame.size.height + shadowSize * 2.0)
            case .topAndRight:
                return CGRect(x: -shadowSize * 2.0, y: 0.0, width: frame.size.width + shadowSize * 2.0, height: frame.size.height + shadowSize * 2.0)
            case .bottomAndLeft:
                return CGRect(x: 0.0, y: -shadowSize * 2.0, width: frame.size.width + shadowSize * 2.0, height: frame.size.height + shadowSize * 2.0)
            case .bottomAndRight:
                return CGRect(x: -shadowSize * 2.0,
                              y: -shadowSize * 2.0,
                              width: frame.size.width + shadowSize * 2.0,
                              height: frame.size.height + shadowSize * 2.0)
            case .exceptLeft:
                return CGRect(x: -shadowSize * 2.0, y: 0.0, width: frame.size.width + shadowSize * 2.0, height: frame.size.height)
            case .exceptRight:
                return CGRect(x: 0.0, y: 0.0, width: frame.size.width + shadowSize * 2.0, height: frame.size.height)
            case .exceptTop:
                return CGRect(x: 0.0, y: -shadowSize * 2.0, width: frame.size.width, height: frame.size.height + shadowSize * 2.0)
            case .exceptBottom:
                return CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height + shadowSize * 2.0)
            }
        }()

        // add outer and inner rectangle to shadow path
        shadowPath.addRect(insetRect)
        shadowPath.addRect(innerFrame)

        // set shadow path as show layer's
        shadowLayer.path = shadowPath

        // add shadow layer as a sublayer
        layer.addSublayer(shadowLayer)

        // hide outside drawing area
        clipsToBounds = true
    }

    func fadeIn(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(_: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)
    }

    func fadeOutAndIn(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(_: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.5
        }, completion: { end in
            self.alpha = 1.0
            completion(end)
        })
    }

    func fadeOut(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(_: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
    
    func rounded(_ corners: UIRectCorner, _ radius: CGFloat = 8) {
        let maskPath1 = UIBezierPath(roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        maskLayer1.masksToBounds = true
        layer.mask = maskLayer1
    }

    func removeAllSubViews() {
        subviews.forEach({ $0.removeFromSuperview() })
    }
}

// MARK: - For handler onlick
class ViewClickListener: NSObject, CAAnimationDelegate {
    fileprivate weak var view: UIView?
    fileprivate var handler: Closure_View_Void?
    fileprivate var handlerAnimation: Closure_View_Void?
    fileprivate var handlerHoldClick: Closure_View_Void?

    var finishSetup = false

    @objc private func trigger(sender: NSObject) {
        if handlerAnimation != nil { self.view?.isUserInteractionEnabled = false }
        if sender is UILongPressGestureRecognizer {
            if (sender as! UILongPressGestureRecognizer).state == .began {
                handlerHoldClick?(view)
            }
        } else {
            handler?(view)
        }
    }
    
    func clearHandler() {
        view?.gestureRecognizers?.forEach({ view?.removeGestureRecognizer($0) })
        handler = nil
        handlerAnimation = nil
    }

    fileprivate func set(_ target: UIView, _ handler: @escaping Closure_View_Void) {
        self.view = target
        self.handler = handler
        if !finishSetup {
            if self.view is UIButton {
                (self.view as! UIButton).removeTarget(self, action: #selector(trigger(sender:)), for: .touchUpInside)
                (self.view as! UIButton).addTarget(self, action: #selector(trigger(sender:)), for: .touchUpInside)
            } else {
                self.view?.gestureRecognizers?.forEach({[weak self] gesture in
                    if gesture is UITapGestureRecognizer { self?.view?.removeGestureRecognizer(gesture) }
                })
                let ges = UITapGestureRecognizer(target: self, action: #selector(trigger(sender:)))
                ges.cancelsTouchesInView = true
                self.view?.addGestureRecognizer(ges)
            }
            finishSetup = true
        }
    }
    
    fileprivate func setHoldClick(duration: Double, _ target: UIView, _ handler: @escaping Closure_View_Void) {
        self.view = target
        self.handlerHoldClick = handler
        if self.view is UIButton {
            (self.view as! UIButton).removeTarget(self, action: #selector(trigger(sender:)), for: .touchUpInside)
            (self.view as! UIButton).addTarget(self, action: #selector(trigger(sender:)), for: .touchUpInside)
        } else {
            self.view?.gestureRecognizers?.forEach({[weak self] gesture in
                if gesture is UILongPressGestureRecognizer { self?.view?.removeGestureRecognizer(gesture) }
            })
            let ges = UILongPressGestureRecognizer(target: self, action: #selector(trigger(sender:)))
            ges.cancelsTouchesInView = true
            ges.delaysTouchesBegan = true
            ges.allowableMovement = 15 // 15 points
            ges.minimumPressDuration = duration
            self.view?.addGestureRecognizer(ges)
        }
        finishSetup = true
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let animationID = anim.value(forKey: "animationID") as? String, animationID == "touchAnimation" {
            handlerAnimation?(view)
            if handlerAnimation != nil { self.view?.isUserInteractionEnabled = true }
        }
    }
}

private var listenerKey: UInt8 = 0 // We still need this boilerplate
extension UIView {
    private var listener: ViewClickListener { // listener is *effectively* a stored property
        get {
            return associatedObject(base: self, key: &listenerKey) { return ViewClickListener() } // Set the initial value of the var
        }
        set { associateObject(base: self, key: &listenerKey, value: newValue) }
    }
    
    func triggerOnClick() {
        listener.handler?(self)
    }
    
    func clearOnClick() {
        listener.clearHandler()
    }

    @objc func onClick(_ handler: @escaping Closure_View_Void) {
        self.isUserInteractionEnabled = true
        listener.set(self, handler)
    }
    
    @objc func onHoldClick(duration: Double, _ handler: @escaping Closure_View_Void) {
        self.isUserInteractionEnabled = true
        listener.setHoldClick(duration: duration, self, handler)
    }

    @objc func onMotionClick(_ handler: @escaping Closure_View_Void) {
        self.isUserInteractionEnabled = true
        listener.set(self, { [weak self] _ in self?.startTouchAnimation(UIView.defaultTouchAnimationDuration, delegate: self?.listener) })
        listener.handlerAnimation = handler
    }
}

// MARK: - Touch animation
extension UIView: CAAnimationDelegate {
    static var defaultTouchAnimationDuration = TimeInterval(0.4)

    @objc func startTouchAnimation(_ duration: TimeInterval = UIView.defaultTouchAnimationDuration, delegate: CAAnimationDelegate? = nil) {
        self.layer.removeAllAnimations()

        let pulse1 = CABasicAnimation(keyPath: "transform.scale")
        pulse1.duration = duration / 2
        pulse1.fromValue = 1.0
        pulse1.toValue = 1.05
        pulse1.autoreverses = true
        pulse1.repeatCount = 1
        pulse1.isRemovedOnCompletion = true
        pulse1.delegate = delegate
        pulse1.setValue("touchAnimation", forKey: "animationID")

        self.layer.add(pulse1, forKey: "touchAnimation")
    }
    
    @objc func startDownwardAnimation(delegate: CAAnimationDelegate? = nil) {
        self.layer.removeAllAnimations()

        let pulse1 = CABasicAnimation(keyPath: "transform.translation.y")
        pulse1.duration = 1.5
        pulse1.fromValue = -30
        pulse1.toValue = 30
        pulse1.autoreverses = false
        pulse1.repeatCount = 1000000
        pulse1.isRemovedOnCompletion = true
        pulse1.delegate = delegate
        pulse1.setValue("positionAnimation", forKey: "animationID")

        self.layer.add(pulse1, forKey: "positionAnimation")
    }

    @objc func endTouchAnimation() {
        self.layer.removeAllAnimations()
    }
}

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
