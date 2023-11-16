

import UIKit

extension ATTransition {
  public func complete(finished: Bool) {
    if state == .notified {
      forceFinishing = finished
    }
    guard state == .animating || state == .starting else { return }
    defer {
      transitionContext = nil
      fromViewController = nil
      toViewController = nil
      inNavigationController = false
      inTabBarController = false
      forceNotInteractive = false
      animatingToViews.removeAll()
      animatingFromViews.removeAll()
      progressUpdateObservers = nil
      transitionContainer = nil
      completionCallback = nil
      forceFinishing = nil
      container = nil
      startingProgress = nil
      processors.removeAll()
      animators.removeAll()
      plugins.removeAll()
      context = nil
      progress = 0
      totalDuration = 0
      state = .possible
    }
    state = .completing

    progressRunner.stop()
    context.clean()

    if let toView = toView, let fromView = fromView {
      if finished && isPresenting && toOverFullScreen {
        context.unhide(rootView: toView)
        context.removeSnapshots(rootView: toView)
        context.storeViewAlpha(rootView: fromView)
        fromViewController?.at.storedSnapshot = container
        container.superview?.addSubview(fromView)
        fromView.addSubview(container)
      } else if !finished && !isPresenting && fromOverFullScreen {
        context.unhide(rootView: fromView)
        context.removeSnapshots(rootView: fromView)
        context.storeViewAlpha(rootView: toView)
        toViewController?.at.storedSnapshot = container
        container.superview?.addSubview(toView)
        toView.addSubview(container)
      } else {
        context.unhideAll()
        context.removeAllSnapshots()
      }

      if (toOverFullScreen && finished) || (fromOverFullScreen && !finished) {
        transitionContainer?.addSubview(finished ? fromView : toView)
      }
      transitionContainer?.addSubview(finished ? toView : fromView)

      if isPresenting != finished, !inContainerController, transitionContext != nil {
        if let superview = originalSuperview, superview.window != nil {
          let view = isPresenting ? fromView : toView
          superview.addSubview(view)
          if let frame = originalFrame {
            view.frame = frame
          }
        } else {
          container.window?.addSubview(isPresenting ? fromView : toView)
        }
      }
    }

    // clear temporary states only when dismissing finishes.
    if !isPresenting && finished {
      originalSuperview = nil
      originalFrame = nil
      originalFrameInContainer = nil
    }

    if container.superview == transitionContainer {
      container.removeFromSuperview()
    }

    for animator in animators {
      animator.clean()
    }

    transitionContainer?.isUserInteractionEnabled = true

    completionCallback?(finished)

    if finished {
      toViewController?.tabBarController?.tabBar.layer.removeAllAnimations()
    } else {
      fromViewController?.tabBarController?.tabBar.layer.removeAllAnimations()
    }

    if finished {
      if let fvc = fromViewController, let tvc = toViewController {
        closureProcessForATDelegate(vc: fvc) {
          $0.atDidEndAnimatingTo?(viewController: tvc)
          $0.atDidEndTransition?()
        }

        closureProcessForATDelegate(vc: tvc) {
          $0.atDidEndAnimatingFrom?(viewController: fvc)
          $0.atDidEndTransition?()
        }
      }
      transitionContext?.finishInteractiveTransition()
    } else {
      if let fvc = fromViewController, let tvc = toViewController {
        closureProcessForATDelegate(vc: fvc) {
          $0.atDidCancelAnimatingTo?(viewController: tvc)
          $0.atDidCancelTransition?()
        }

        closureProcessForATDelegate(vc: tvc) {
          $0.atDidCancelAnimatingFrom?(viewController: fvc)
          $0.atDidCancelTransition?()
        }
      }
      transitionContext?.cancelInteractiveTransition()
    }
    transitionContext?.completeTransition(finished)
  }
}
