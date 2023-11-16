import UIKit

public class AT: NSObject {
  public static var shared = ATTransition()
}

public protocol ATTransitionDelegate: AnyObject {
  func atTransition(_ at: ATTransition, didUpdate state: ATTransitionState)
  func atTransition(_ at: ATTransition, didUpdate progress: Double)
}

open class ATTransition: NSObject {
  public weak var delegate: ATTransitionDelegate?

  public var defaultAnimation: ATDefaultAnimationType = .auto
  public var containerColor: UIColor = .black
  public var isUserInteractionEnabled = false
  public var viewOrderingStrategy: ATViewOrderingStrategy = .auto
  public var defaultAnimationDirectionStrategy: ATDefaultAnimationType.Strategy = .forceLeftToRight

  public internal(set) var state: ATTransitionState = .possible {
    didSet {
      if state != .notified, state != .starting {
        beginCallback?(state == .animating)
        beginCallback = nil
      }
      delegate?.atTransition(self, didUpdate: state)
    }
  }

  public var isTransitioning: Bool { return state != .possible }
  public internal(set) var isPresenting: Bool = true

  @available(*, renamed: "isTransitioning")
  public var transitioning: Bool {
    return isTransitioning
  }
  @available(*, renamed: "isPresenting")
  public var presenting: Bool {
    return isPresenting
  }

  public internal(set) var container: UIView!

  internal var transitionContainer: UIView?

  internal var completionCallback: ((Bool) -> Void)?
  internal var beginCallback: ((Bool) -> Void)?

  internal var processors: [ATPreprocessor] = []
  internal var animators: [ATAnimator] = []
  internal var plugins: [ATPlugin] = []
  internal var animatingFromViews: [UIView] = []
  internal var animatingToViews: [UIView] = []
  internal var originalSuperview: UIView?
  internal var originalFrame: CGRect?
  internal var originalFrameInContainer: CGRect?

  internal static var enabledPlugins: [ATPlugin.Type] = []

  public internal(set) var toViewController: UIViewController?
  public internal(set) var fromViewController: UIViewController?

  public internal(set) var context: ATContext!

  public var interactive: Bool {
    return !progressRunner.isRunning
  }

  internal var progressUpdateObservers: [ATProgressUpdateObserver]?

  public internal(set) var totalDuration: TimeInterval = 0.0

  public internal(set) var progress: Double = 0 {
    didSet {
      if state == .animating {
        if let progressUpdateObservers = progressUpdateObservers {
          for observer in progressUpdateObservers {
            observer.atDidUpdateProgress(progress: progress)
          }
        }

        let timePassed = progress * totalDuration
        if interactive {
          for animator in animators {
            animator.seekTo(timePassed: timePassed)
          }
        } else {
          for plugin in plugins where plugin.requirePerFrameCallback {
            plugin.seekTo(timePassed: timePassed)
          }
        }

        transitionContext?.updateInteractiveTransition(CGFloat(progress))
      }
      delegate?.atTransition(self, didUpdate: progress)
    }
  }
  lazy var progressRunner: ATProgressRunner = {
    let runner = ATProgressRunner()
    runner.delegate = self
    return runner
  }()

  internal weak var transitionContext: UIViewControllerContextTransitioning?

  internal var fullScreenSnapshot: UIView?
  internal var forceNotInteractive = false
  internal var forceFinishing: Bool?
  internal var startingProgress: CGFloat?

  internal var inNavigationController = false
  internal var inTabBarController = false
  internal var inContainerController: Bool {
    return inNavigationController || inTabBarController
  }
  internal var toOverFullScreen: Bool {
    return !inContainerController && (toViewController?.modalPresentationStyle == .overFullScreen || toViewController?.modalPresentationStyle == .overCurrentContext)
  }
  internal var fromOverFullScreen: Bool {
    return !inContainerController && (fromViewController?.modalPresentationStyle == .overFullScreen || fromViewController?.modalPresentationStyle == .overCurrentContext)
  }

  internal var toView: UIView? { return toViewController?.view }
  internal var fromView: UIView? { return fromViewController?.view }

  public override init() { super.init() }

  func complete(after: TimeInterval, finishing: Bool) {
    guard [ATTransitionState.animating, .starting, .notified].contains(state) else { return }
    if after <= 1.0 / 120 {
      complete(finished: finishing)
      return
    }
    let totalTime: TimeInterval
    if finishing {
      totalTime = after / max((1 - progress), 0.01)
    } else {
      totalTime = after / max(progress, 0.01)
    }
    progressRunner.start(timePassed: progress * totalTime, totalTime: totalTime, reverse: !finishing)
  }

  // MARK: Observe Progress
  public func observeForProgressUpdate(observer: ATProgressUpdateObserver) {
    if progressUpdateObservers == nil {
      progressUpdateObservers = []
    }
    progressUpdateObservers!.append(observer)
  }
}

extension ATTransition: ATProgressRunnerDelegate {
  func updateProgress(progress: Double) {
    self.progress = progress
  }
}

