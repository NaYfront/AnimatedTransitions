import UIKit

extension ATTransition {
  public func animate() {
    guard state == .starting else { return }
    state = .animating

    if let toView = toView {
      context.unhide(view: toView)
    }

    // auto hide all animated views
    for view in animatingFromViews {
      context.hide(view: view)
    }
    for view in animatingToViews {
      context.hide(view: view)
    }

    var totalDuration: TimeInterval = 0
    var animatorWantsInteractive = false

    if context.insertToViewFirst {
      for v in animatingToViews { _ = context.snapshotView(for: v) }
      for v in animatingFromViews { _ = context.snapshotView(for: v) }
    } else {
      for v in animatingFromViews { _ = context.snapshotView(for: v) }
      for v in animatingToViews { _ = context.snapshotView(for: v) }
    }

    // UIKit appears to set fromView setNeedLayout to be true.
    // We don't want fromView to layout after our animation starts.
    // Therefore we kick off the layout beforehand
    fromView?.layoutIfNeeded()

    for animator in animators {
      let duration = animator.animate(fromViews: animatingFromViews.filter({ animator.canAnimate(view: $0, appearing: false) }),
                                      toViews: animatingToViews.filter({ animator.canAnimate(view: $0, appearing: true) }))
      if duration == .infinity {
        animatorWantsInteractive = true
      } else {
        totalDuration = max(totalDuration, duration)
      }
    }

    self.totalDuration = totalDuration
    if let forceFinishing = forceFinishing {
      complete(finished: forceFinishing)
    } else if let startingProgress = startingProgress {
      update(startingProgress)
    } else if animatorWantsInteractive {
      update(0)
    } else {
      complete(after: totalDuration, finishing: true)
    }

    fullScreenSnapshot?.removeFromSuperview()
  }
}
