//
//  ATCoreAnimationViewContext.swift
//  AnimatedTransitions
//
//  Created by NaYfront on 25.10.2023.
//

import UIKit

@available(iOS 10, tvOS 10, *)
internal class ATViewPropertyViewContext: ATAnimatorViewContext {

  var viewPropertyAnimator: UIViewPropertyAnimator!
  var endEffect: UIVisualEffect?
  var startEffect: UIVisualEffect?

  override class func canAnimate(view: UIView, state: ATTargetState, appearing: Bool) -> Bool {
    return view is UIVisualEffectView && state.opacity != nil
  }

  override func resume(timePassed: TimeInterval, reverse: Bool) -> TimeInterval {
    guard let visualEffectView = snapshot as? UIVisualEffectView else { return .zero }
    guard duration > 0 else { return .zero }
    if reverse {
      viewPropertyAnimator?.stopAnimation(false)
      viewPropertyAnimator?.finishAnimation(at: .current)

      viewPropertyAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
        visualEffectView.effect = reverse ? self.startEffect : self.endEffect
      }

      // workaround for a bug https://openradar.appspot.com/30856746
      viewPropertyAnimator.startAnimation()
      viewPropertyAnimator.pauseAnimation()

      viewPropertyAnimator.fractionComplete = CGFloat(1.0 - timePassed / duration)
    }

    DispatchQueue.main.async {
      self.viewPropertyAnimator.startAnimation()
    }

    return duration
  }

  override func seek(timePassed: TimeInterval) {
    viewPropertyAnimator?.pauseAnimation()
    viewPropertyAnimator?.fractionComplete = CGFloat(timePassed / duration)
  }

  override func clean() {
    super.clean()
    viewPropertyAnimator?.stopAnimation(false)
    viewPropertyAnimator?.finishAnimation(at: .current)
    viewPropertyAnimator = nil
  }

  override func startAnimations() -> TimeInterval {
    guard let visualEffectView = snapshot as? UIVisualEffectView else { return 0 }
    let appearedEffect = visualEffectView.effect
    let disappearedEffect = targetState.opacity == 0 ? nil : visualEffectView.effect
    startEffect = appearing ? disappearedEffect : appearedEffect
    endEffect = appearing ? appearedEffect : disappearedEffect
    visualEffectView.effect = startEffect
    viewPropertyAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
      visualEffectView.effect = self.endEffect
    }
    viewPropertyAnimator.startAnimation()
    return duration
  }
}
