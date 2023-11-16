import UIKit

extension ATTransition {
  public func start() {
    guard state == .notified else { return }
    state = .starting

    if let toView = toView, let fromView = fromView {
      // remember the superview of the view of the `fromViewController` which is
      // presenting the `toViewController` with `overFullscreen` `modalPresentationStyle`,
      // so that we can restore the presenting view controller's view later on dismiss
      if isPresenting && !inContainerController {
        originalSuperview = fromView.superview
        originalFrame = fromView.frame
      }
      if let toViewController = toViewController, let transitionContext = transitionContext {
        toView.frame = transitionContext.finalFrame(for: toViewController)
      } else {
        toView.frame = fromView.frame
      }
      toView.setNeedsLayout()
      if nil != toView.window {
        toView.layoutIfNeeded()
      }
    }

    if let fvc = fromViewController, let tvc = toViewController {
      closureProcessForATDelegate(vc: fvc) {
        $0.atWillStartTransition?()
        $0.atWillStartAnimatingTo?(viewController: tvc)
      }

      closureProcessForATDelegate(vc: tvc) {
        $0.atWillStartTransition?()
        $0.atWillStartAnimatingFrom?(viewController: fvc)
      }
    }

    // take a snapshot to hide all the flashing that might happen
    fullScreenSnapshot = transitionContainer?.window?.snapshotView(afterScreenUpdates: false) ?? fromView?.snapshotView(afterScreenUpdates: false)
    if let fullScreenSnapshot = fullScreenSnapshot {
      (transitionContainer?.window ?? transitionContainer)?.addSubview(fullScreenSnapshot)
    }

    if let oldSnapshot = fromViewController?.at.storedSnapshot {
      oldSnapshot.removeFromSuperview()
      fromViewController?.at.storedSnapshot = nil
    }
    if let oldSnapshot = toViewController?.at.storedSnapshot {
      oldSnapshot.removeFromSuperview()
      toViewController?.at.storedSnapshot = nil
    }

    plugins = ATTransition.enabledPlugins.map({ return $0.init() })
    processors = [
      IgnoreSubviewModifiersPreprocessor(),
      ConditionalPreprocessor(),
      DefaultAnimationPreprocessor(),
      MatchPreprocessor(),
      SourcePreprocessor(),
      CascadePreprocessor()
    ]
    animators = [
      ATDefaultAnimator<ATCoreAnimationViewContext>()
    ]

    if #available(iOS 10, tvOS 10, *) {
      animators.append(ATDefaultAnimator<ATViewPropertyViewContext>())
    }

    // There is no covariant in Swift, so we need to add plugins one by one.
    plugins.forEach {
      processors.append($0)
      animators.append($0)
    }

    transitionContainer?.isUserInteractionEnabled = isUserInteractionEnabled

    // a view to hold all the animating views
    container = UIView(frame: transitionContainer?.bounds ?? .zero)
    container.isUserInteractionEnabled = false
    if !toOverFullScreen && !fromOverFullScreen {
      container.backgroundColor = containerColor
    }
    transitionContainer?.addSubview(container)

    context = ATContext(container: container)

    processors.forEach {
      $0.at = self
    }
    animators.forEach {
      $0.at = self
    }

    if let toView = toView, let fromView = fromView, toView != fromView {
      // if we're presenting a view controller, remember the position & dimension
      // of the view relative to the transition container so that we can:
      // - correctly place the view in the transition container when presenting
      // - correctly place the view back to where it was when dismissing
      if isPresenting && !inContainerController {
        originalFrameInContainer = fromView.superview?.convert(
          fromView.frame, to: container
        )
      }

      // when dismiss and before animating, place the `toView` to be animated
      // with the correct position and dimension in the transition container.
      // otherwise, there will be an apparent visual jagging when the animation begins.
      if !isPresenting, let frame = originalFrameInContainer {
        toView.frame = frame
      }

      context.loadViewAlpha(rootView: toView)
      context.loadViewAlpha(rootView: fromView)
      container.addSubview(toView)
      container.addSubview(fromView)

      // when present and before animating, place the `fromView` to be animated
      // with the correct position and dimension in the transition container to
      // prevent any possible visual jagging when animation starts, even though not
      // that apparent in some cases.
      if isPresenting, let frame = originalFrameInContainer {
        fromView.frame = frame
      }

      toView.updateConstraints()
      toView.setNeedsLayout()
      toView.layoutIfNeeded()

      context.set(fromViews: fromView.flattenedViewHierarchy, toViews: toView.flattenedViewHierarchy)
    }

    if (viewOrderingStrategy == .auto && !isPresenting && !inTabBarController) ||
       viewOrderingStrategy == .sourceViewOnTop {
      context.insertToViewFirst = true
    }

    processors.forEach {
      $0.process(fromViews: context.fromViews, toViews: context.toViews)
    }

    animatingFromViews = context.fromViews.filter { (view: UIView) -> Bool in
      animators.contains { $0.canAnimate(view: view, appearing: false) }
    }

    animatingToViews = context.toViews.filter { (view: UIView) -> Bool in
      animators.contains { $0.canAnimate(view: view, appearing: true) }
    }

    if let toView = toView {
      context.hide(view: toView)
    }

    #if os(tvOS)
      animate()
    #else
      if inNavigationController {
        // When animating within navigationController, we have to dispatch later into the main queue.
        // otherwise snapshots will be pure white. Possibly a bug with UIKit
        DispatchQueue.main.async {
          self.animate()
        }
      } else {
        animate()
      }
    #endif
  }
}
