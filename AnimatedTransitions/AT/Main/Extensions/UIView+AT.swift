import UIKit

class SnapshotWrapperView: UIView {
  let contentView: UIView
  init(contentView: UIView) {
    self.contentView = contentView
    super.init(frame: contentView.frame)
    addSubview(contentView)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    contentView.bounds.size = bounds.size
    contentView.center = bounds.center
  }
}

extension UIView: ATCompatible { }
public extension ATExtension where Base: UIView {

   var id: String? {
    get { return objc_getAssociatedObject(base, &type(of: base).AssociatedKeys.atID) as? String }
    set { objc_setAssociatedObject(base, &type(of: base).AssociatedKeys.atID, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  var isEnabled: Bool {
    get { return objc_getAssociatedObject(base, &type(of: base).AssociatedKeys.atEnabled) as? Bool ?? true }
    set { objc_setAssociatedObject(base, &type(of: base).AssociatedKeys.atEnabled, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }


  var isEnabledForSubviews: Bool {
    get { return objc_getAssociatedObject(base, &type(of: base).AssociatedKeys.atEnabledForSubviews) as? Bool ?? true }
    set { objc_setAssociatedObject(base, &type(of: base).AssociatedKeys.atEnabledForSubviews, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }


  var modifiers: [ATModifier]? {
    get { return objc_getAssociatedObject(base, &type(of: base).AssociatedKeys.atModifiers) as? [ATModifier] }
    set { objc_setAssociatedObject(base, &type(of: base).AssociatedKeys.atModifiers, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }


  var modifierString: String? {
    get { fatalError("Reverse lookup is not supported") }
    set { modifiers = newValue?.parse() }
  }

  internal var storedAlpha: CGFloat? {
    get {
      if let doubleValue = (objc_getAssociatedObject(base, &type(of: base).AssociatedKeys.atStoredAlpha) as? NSNumber)?.doubleValue {
        return CGFloat(doubleValue)
      }
      return nil
    }
    set {
      if let newValue = newValue {
        objc_setAssociatedObject(base, &type(of: base).AssociatedKeys.atStoredAlpha, NSNumber(value: newValue.native), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      } else {
        objc_setAssociatedObject(base, &type(of: base).AssociatedKeys.atStoredAlpha, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      }
    }
  }
}

public extension UIView {
  fileprivate struct AssociatedKeys {
    static var atID    = "atID"
    static var atModifiers = "atModifers"
    static var atStoredAlpha = "atStoredAlpha"
    static var atEnabled = "atEnabled"
    static var atEnabledForSubviews = "atEnabledForSubviews"
  }

  @available(*, renamed: "at.id")
  @IBInspectable var atID: String? {
    get { return at.id }
    set { at.id = newValue }
  }

  @available(*, renamed: "at.isEnabled")
  @IBInspectable var isATEnabled: Bool {
    get { return at.isEnabled }
    set { at.isEnabled = newValue }
  }

  @available(*, renamed: "at.isEnabledForSubviews")
  @IBInspectable var isATEnabledForSubviews: Bool {
    get { return at.isEnabledForSubviews }
    set { at.isEnabledForSubviews = newValue }
  }

  @available(*, renamed: "at.modifiers")
  var atModifiers: [ATModifier]? {
    get { return at.modifiers }
    set { at.modifiers = newValue }
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  @available(*, renamed: "at.modifierString")
  @IBInspectable var atModifierString: String? {
    get { fatalError("Reverse lookup is not supported") }
    set { at.modifiers = newValue?.parse() }
  }

  internal func slowSnapshotView() -> UIView {
    UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
    guard let currentContext = UIGraphicsGetCurrentContext() else {
      UIGraphicsEndImageContext()
      return UIView()
    }
    layer.render(in: currentContext)

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    let imageView = UIImageView(image: image)
    imageView.frame = bounds
    return SnapshotWrapperView(contentView: imageView)
  }

  internal func snapshotView() -> UIView? {
    let snapshot = snapshotView(afterScreenUpdates: true)
    if #available(iOS 11.0, *), let oldSnapshot = snapshot {
      // in iOS 11, the snapshot taken by snapshotView(afterScreenUpdates) won't contain a container view
      return SnapshotWrapperView(contentView: oldSnapshot)
    } else {
      return snapshot
    }
  }

  internal var flattenedViewHierarchy: [UIView] {
    guard at.isEnabled else { return [] }
    if #available(iOS 9.0, *), isHidden && (superview is UICollectionView || superview is UIStackView || self is UITableViewCell) {
      return []
    } else if isHidden && (superview is UICollectionView || self is UITableViewCell) {
      return []
    } else if at.isEnabledForSubviews {
      return [self] + subviews.flatMap { $0.flattenedViewHierarchy }
    } else {
      return [self]
    }
  }

  @available(*, renamed: "at.storedAplha")
  internal var atStoredAlpha: CGFloat? {
    get { return at.storedAlpha }
    set { at.storedAlpha = newValue }
  }
}
