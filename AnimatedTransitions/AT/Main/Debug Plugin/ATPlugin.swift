import UIKit

open class ATPlugin: NSObject, ATPreprocessor, ATAnimator {

  weak public var at: ATTransition!

  public var context: ATContext! {
    return at.context
  }

  open var requirePerFrameCallback = false

  public override required init() {}

  open func process(fromViews: [UIView], toViews: [UIView]) {}

  open func canAnimate(view: UIView, appearing: Bool) -> Bool { return false }

  open func animate(fromViews: [UIView], toViews: [UIView]) -> TimeInterval { return 0 }

  open func clean() {}

  open func seekTo(timePassed: TimeInterval) {}

  open func resume(timePassed: TimeInterval, reverse: Bool) -> TimeInterval { return 0 }

  open func apply(state: ATTargetState, to view: UIView) {}
  open func changeTarget(state: ATTargetState, isDestination: Bool, to view: UIView) {}
}

extension ATPlugin {
  public static var isEnabled: Bool {
    get {
      return ATTransition.isEnabled(plugin: self)
    }
    set {
      if newValue {
        enable()
      } else {
        disable()
      }
    }
  }
  public static func enable() {
    ATTransition.enable(plugin: self)
  }
  public static func disable() {
    ATTransition.disable(plugin: self)
  }
}

// MARK: Plugin Support
internal extension ATTransition {
  static func isEnabled(plugin: ATPlugin.Type) -> Bool {
    return enabledPlugins.firstIndex(where: { return $0 == plugin}) != nil
  }

  static func enable(plugin: ATPlugin.Type) {
    disable(plugin: plugin)
    enabledPlugins.append(plugin)
  }

  static func disable(plugin: ATPlugin.Type) {
    if let index = enabledPlugins.firstIndex(where: { return $0 == plugin}) {
      enabledPlugins.remove(at: index)
    }
  }
}
