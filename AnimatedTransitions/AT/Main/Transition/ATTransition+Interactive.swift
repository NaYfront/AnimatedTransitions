import UIKit

extension ATTransition {
  public func update(_ percentageComplete: CGFloat) {
    guard state == .animating else {
      startingProgress = percentageComplete
      return
    }
    self.progressRunner.stop()
    self.progress = Double(percentageComplete.clamp(0, 1))
  }

  public func finish(animate: Bool = true) {
    guard state == .animating || state == .notified || state == .starting else { return }
    if !animate {
      self.complete(finished: true)
      return
    }
    var maxTime: TimeInterval = 0
    for animator in self.animators {
      maxTime = max(maxTime, animator.resume(timePassed: self.progress * self.totalDuration,
                                             reverse: false))
    }
    self.complete(after: maxTime, finishing: true)
  }

  public func cancel(animate: Bool = true) {
    guard state == .animating || state == .notified || state == .starting else { return }
    if !animate {
      self.complete(finished: false)
      return
    }
    var maxTime: TimeInterval = 0
    for animator in self.animators {
      var adjustedProgress = self.progress
      if adjustedProgress < 0 {
        adjustedProgress = -adjustedProgress
      }
      maxTime = max(maxTime, animator.resume(timePassed: adjustedProgress * self.totalDuration,
                                             reverse: true))
    }
    self.complete(after: maxTime, finishing: false)
  }

  public func apply(modifiers: [ATModifier], to view: UIView) {
    guard state == .animating else { return }
    let targetState = ATTargetState(modifiers: modifiers)
    if let otherView = self.context.pairedView(for: view) {
      for animator in self.animators {
        animator.apply(state: targetState, to: otherView)
      }
    }
    for animator in self.animators {
      animator.apply(state: targetState, to: view)
    }
  }
    
  public func changeTarget(modifiers: [ATModifier], isDestination: Bool = true, to view: UIView) {
    guard state == .animating else { return }
    let targetState = ATTargetState(modifiers: modifiers)
    if let otherView = self.context.pairedView(for: view) {
      for animator in self.animators {
        animator.changeTarget(state: targetState, isDestination: !isDestination, to: otherView)
      }
    }
    for animator in self.animators {
      animator.changeTarget(state: targetState, isDestination: isDestination, to: view)
    }
  }
}
