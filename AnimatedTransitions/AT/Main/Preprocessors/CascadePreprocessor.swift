//
//  CascadePreprocessor.swift
//  AnimatedTransitions
//
//  Created by NaYfront on 12.10.2023.
//

import UIKit

public enum CascadeDirection {
  case topToBottom
  case bottomToTop
  case leftToRight
  case rightToLeft
  case radial(center: CGPoint)
  case inverseRadial(center: CGPoint)
  var comparator: (UIView, UIView) -> Bool {
    switch self {
    case .topToBottom:
      return topToBottomComperator
    case .bottomToTop:
      return bottomToTopComperator
    case .leftToRight:
      return leftToRightComperator
    case .rightToLeft:
      return rightToLeftComperator
    case .radial(let center):
      return { (lhs: UIView, rhs: UIView) -> Bool in
        return lhs.center.distance(center) < rhs.center.distance(center)
      }
    case .inverseRadial(let center):
      return { (lhs: UIView, rhs: UIView) -> Bool in
        return lhs.center.distance(center) > rhs.center.distance(center)
      }
    }
  }

  init?(_ string: String) {
    switch string {
    case "bottomToTop":
      self = .bottomToTop
    case "leftToRight":
      self = .leftToRight
    case "rightToLeft":
      self = .rightToLeft
    case "topToBottom":
      self = .topToBottom
    case "leadingToTrailing":
      self = .leadingToTrailing
    case "trailingToLeading":
      self = .trailingToLeading
    default:
      return nil
    }
  }

  public static var leadingToTrailing: CascadeDirection {
    return !Locale.isDeviceLanguageRightToLeft ? .leftToRight : .rightToLeft
  }

  public static var trailingToLeading: CascadeDirection {
    return !Locale.isDeviceLanguageRightToLeft ? .rightToLeft : .leftToRight
  }

  private func topToBottomComperator(lhs: UIView, rhs: UIView) -> Bool {
    return lhs.frame.minY < rhs.frame.minY
  }

  private func bottomToTopComperator(lhs: UIView, rhs: UIView) -> Bool {
    return lhs.frame.maxY == rhs.frame.maxY ? lhs.frame.maxX > rhs.frame.maxX : lhs.frame.maxY > rhs.frame.maxY
  }

  private func leftToRightComperator(lhs: UIView, rhs: UIView) -> Bool {
    return lhs.frame.minX < rhs.frame.minX
  }

  private func rightToLeftComperator(lhs: UIView, rhs: UIView) -> Bool {
    return lhs.frame.maxX > rhs.frame.maxX
  }
}

class CascadePreprocessor: BasePreprocessor {
  override func process(fromViews: [UIView], toViews: [UIView]) {
    process(views: fromViews)
    process(views: toViews)
  }

  func process(views: [UIView]) {
    for view in views {
      guard let (deltaTime, direction, delayMatchedViews) = context[view]?.cascade else { continue }

      var parentView = view
      if view is UITableView, let wrapperView = view.subviews.get(0) {
        parentView = wrapperView
      }

      let sortedSubviews = parentView.subviews.sorted(by: direction.comparator)

      let initialDelay = context[view]!.delay
      let finalDelay = TimeInterval(sortedSubviews.count) * deltaTime + initialDelay

      for (i, subview) in sortedSubviews.enumerated() {
        let delay = TimeInterval(i) * deltaTime + initialDelay

        func applyDelay(view: UIView) {
          if context.pairedView(for: view) == nil {
            context[view]?.delay = delay
          } else if delayMatchedViews, let paired = context.pairedView(for: view) {
            context[view]?.delay = finalDelay
            context[paired]?.delay = finalDelay
          }
          for subview in view.subviews {
            applyDelay(view: subview)
          }
        }

        applyDelay(view: subview)
      }
    }
  }
}
