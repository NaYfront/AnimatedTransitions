import CoreGraphics
import QuartzCore

public enum ATSnapshotType {
  case optimized
  case normal
  case layerRender
  case noSnapshot
}

public enum ATCoordinateSpace {
  case global
  case local
}

public struct ATTargetState {
  public var beginState: [ATModifier]?
  public var conditionalModifiers: [((ATConditionalContext) -> Bool, [ATModifier])]?

  public var position: CGPoint?
  public var size: CGSize?
  public var transform: CATransform3D?
  public var opacity: Float?
  public var cornerRadius: CGFloat?
  public var backgroundColor: CGColor?
  public var zPosition: CGFloat?
  public var anchorPoint: CGPoint?

  public var contentsRect: CGRect?
  public var contentsScale: CGFloat?

  public var borderWidth: CGFloat?
  public var borderColor: CGColor?

  public var shadowColor: CGColor?
  public var shadowOpacity: Float?
  public var shadowOffset: CGSize?
  public var shadowRadius: CGFloat?
  public var shadowPath: CGPath?
  public var masksToBounds: Bool?
  public var displayShadow: Bool = true

  public var overlay: (color: CGColor, opacity: CGFloat)?

  public var spring: (CGFloat, CGFloat)?
  public var delay: TimeInterval = 0
  public var duration: TimeInterval?
  public var timingFunction: CAMediaTimingFunction?

  public var arc: CGFloat?
  public var source: String?
  public var cascade: (TimeInterval, CascadeDirection, Bool)?

  public var ignoreSubviewModifiers: Bool?
  public var coordinateSpace: ATCoordinateSpace?
  public var useScaleBasedSizeChange: Bool?
  public var snapshotType: ATSnapshotType?

  public var nonFade: Bool = false
  public var forceAnimate: Bool = false
  public var custom: [String: Any]?

  init(modifiers: [ATModifier]) {
    append(contentsOf: modifiers)
  }

  public mutating func append(_ modifier: ATModifier) {
    modifier.apply(&self)
  }

  public mutating func append(contentsOf modifiers: [ATModifier]) {
    for modifier in modifiers {
      modifier.apply(&self)
    }
  }

  /**
   - Returns: custom item for a specific key
   */
  public subscript(key: String) -> Any? {
    get {
      return custom?[key]
    }
    set {
      if custom == nil {
        custom = [:]
      }
      custom![key] = newValue
    }
  }
}

extension ATTargetState: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: ATModifier...) {
    append(contentsOf: elements)
  }
}
