//
//  ATAnimatorViewContext.swift
//  AnimatedTransitions
//
//  Created by NaYfront on 19.10.2023.
//

import UIKit

internal class ATAnimatorViewContext {
  weak var animator: ATAnimator?
  let snapshot: UIView
  let appearing: Bool
  var targetState: ATTargetState
  var duration: TimeInterval = 0

  // computed
  var currentTime: TimeInterval {
    return snapshot.layer.convertTime(CACurrentMediaTime(), from: nil)
  }
  var container: UIView? {
    return animator?.at.context.container
  }

  class func canAnimate(view: UIView, state: ATTargetState, appearing: Bool) -> Bool {
    return false
  }

  func apply(state: ATTargetState) {
  }

  func changeTarget(state: ATTargetState, isDestination: Bool) {
  }

  func resume(timePassed: TimeInterval, reverse: Bool) -> TimeInterval {
    return 0
  }

  func seek(timePassed: TimeInterval) {
  }

  func clean() {
    animator = nil
  }

  func startAnimations() -> TimeInterval {
    return 0
  }

  required init(animator: ATAnimator, snapshot: UIView, targetState: ATTargetState, appearing: Bool) {
    self.animator = animator
    self.snapshot = snapshot
    self.targetState = targetState
    self.appearing = appearing
  }
}
