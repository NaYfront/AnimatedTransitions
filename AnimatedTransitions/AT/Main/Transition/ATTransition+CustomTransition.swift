import UIKit

public extension ATTransition {
  func transition(from: UIViewController, to: UIViewController, in view: UIView, completion: ((Bool) -> Void)? = nil) {
    guard !isTransitioning else { return }
    self.state = .notified
    isPresenting = true
    transitionContainer = view
    fromViewController = from
    toViewController = to
    completionCallback = {
      completion?($0)
      self.state = .possible
    }
    start()
  }
}

