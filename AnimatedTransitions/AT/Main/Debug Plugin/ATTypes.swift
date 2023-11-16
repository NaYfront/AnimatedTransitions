import UIKit

public protocol ATPreprocessor: AnyObject {
  var at: ATTransition! { get set }
  func process(fromViews: [UIView], toViews: [UIView])
}

public protocol ATAnimator: AnyObject {
  var at: ATTransition! { get set }
  func canAnimate(view: UIView, appearing: Bool) -> Bool
  func animate(fromViews: [UIView], toViews: [UIView]) -> TimeInterval
  func clean()

  func seekTo(timePassed: TimeInterval)
  func resume(timePassed: TimeInterval, reverse: Bool) -> TimeInterval
  func apply(state: ATTargetState, to view: UIView)
  func changeTarget(state: ATTargetState, isDestination: Bool, to view: UIView)
}

public protocol ATProgressUpdateObserver: AnyObject {
  func atDidUpdateProgress(progress: Double)
}

public enum ATViewOrderingStrategy {
  case auto, sourceViewOnTop, destinationViewOnTop
}
