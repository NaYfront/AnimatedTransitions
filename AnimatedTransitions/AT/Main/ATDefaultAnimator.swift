//
//  ATDefaultAnimator.swift
//  AnimatedTransitions
//
//  Created by NaYfront on 19.10.2023.
//

import UIKit

internal extension UIView {
  func optimizedDurationTo(position: CGPoint?, size: CGSize?, transform: CATransform3D?) -> TimeInterval {
    let fromPos = (layer.presentation() ?? layer).position
    let toPos = position ?? fromPos
    let fromSize = (layer.presentation() ?? layer).bounds.size
    let toSize = size ?? fromSize
    let fromTransform = (layer.presentation() ?? layer).transform
    let toTransform = transform ?? fromTransform

    let realFromPos = CGPoint.zero.transform(fromTransform) + fromPos
    let realToPos = CGPoint.zero.transform(toTransform) + toPos

    let realFromSize = fromSize.transform(fromTransform)
    let realToSize = toSize.transform(toTransform)

    let movePoints = (realFromPos.distance(realToPos) + realFromSize.point.distance(realToSize.point))

    // duration is 0.2 @ 0 to 0.375 @ 500
    let duration = 0.208 + Double(movePoints.clamp(0, 500)) / 3000
    return duration
  }
}

internal class ATDefaultAnimator<ViewContext: ATAnimatorViewContext>: ATAnimator {
  weak public var at: ATTransition!
  public var context: ATContext! {
    return at?.context
  }
  var viewContexts: [UIView: ViewContext] = [:]

  public func seekTo(timePassed: TimeInterval) {
    for viewContext in viewContexts.values {
      viewContext.seek(timePassed: timePassed)
    }
  }

  public func resume(timePassed: TimeInterval, reverse: Bool) -> TimeInterval {
    var duration: TimeInterval = 0
    for (_, viewContext) in viewContexts {
      if viewContext.targetState.duration == nil {
        viewContext.duration = max(viewContext.duration,
                                   calculateOptimizedDuration(snapshot: viewContext.snapshot,
                                                              targetState: viewContext.targetState) + timePassed)
      }
      let timeUntilStopped = viewContext.resume(timePassed: timePassed, reverse: reverse)
      duration = max(duration, timeUntilStopped)
    }
    return duration
  }

  public func apply(state: ATTargetState, to view: UIView) {
    if let context = viewContexts[view] {
      context.apply(state: state)
    }
  }

  public func changeTarget(state: ATTargetState, isDestination: Bool, to view: UIView) {
    if let context = viewContexts[view] {
      context.changeTarget(state: state, isDestination: isDestination)
    }
  }

  public func canAnimate(view: UIView, appearing: Bool) -> Bool {
    guard let state = context[view] else { return false }
    return ViewContext.canAnimate(view: view, state: state, appearing: appearing)
  }

  public func animate(fromViews: [UIView], toViews: [UIView]) -> TimeInterval {
    var maxDuration: TimeInterval = 0

    for v in fromViews { createViewContext(view: v, appearing: false) }
    for v in toViews { createViewContext(view: v, appearing: true) }

    for viewContext in viewContexts.values {
      if let duration = viewContext.targetState.duration, duration != .infinity {
        viewContext.duration = duration
        maxDuration = max(maxDuration, duration)
      } else {
        let duration = calculateOptimizedDuration(snapshot: viewContext.snapshot, targetState: viewContext.targetState)
        if viewContext.targetState.duration == nil {
          viewContext.duration = duration
        }
        maxDuration = max(maxDuration, duration)
      }
    }
    for viewContext in viewContexts.values {
      if viewContext.targetState.duration == .infinity {
        viewContext.duration = maxDuration
      }
      let timeUntilStopped = viewContext.startAnimations()
      maxDuration = max(maxDuration, timeUntilStopped)
    }

    return maxDuration
  }

  func calculateOptimizedDuration(snapshot: UIView, targetState: ATTargetState) -> TimeInterval {
    return snapshot.optimizedDurationTo(position: targetState.position,
                                        size: targetState.size,
                                        transform: targetState.transform)
  }

  func createViewContext(view: UIView, appearing: Bool) {
    let snapshot = context.snapshotView(for: view)
    let viewContext = ViewContext(animator: self, snapshot: snapshot, targetState: context[view]!, appearing: appearing)
    viewContexts[view] = viewContext
  }

  public func clean() {
    for vc in viewContexts.values {
      vc.clean()
    }
    viewContexts.removeAll()
  }
}
