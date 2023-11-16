//
//  ConditionalPreprocessor.swift
//  AnimatedTransitions
//
//  Created by NaYfront on 10.10.2023.
//

import UIKit

public struct ATConditionalContext {
  internal weak var at: ATTransition!
  public weak var view: UIView!

  public private(set) var isAppearing: Bool

  public var isPresenting: Bool {
    return at.isPresenting
  }
  public var isInTabbarController: Bool {
    return at.inTabBarController
  }
  public var isInNavbarController: Bool {
    return at.inNavigationController
  }
  public var isMatched: Bool {
    return matchedView != nil
  }
  public var isAncestorViewMatched: Bool {
    return matchedAncestorView != nil
  }

  public var matchedView: UIView? {
    return at.context.pairedView(for: view)
  }
  public var matchedAncestorView: (UIView, UIView)? {
    var current = view.superview
    while let ancestor = current, ancestor != at.context.container {
      if let pairedView = at.context.pairedView(for: ancestor) {
        return (ancestor, pairedView)
      }
      current = ancestor.superview
    }
    return nil
  }

  public var fromViewController: UIViewController {
    return at.fromViewController!
  }
  public var toViewController: UIViewController {
    return at.toViewController!
  }
  public var currentViewController: UIViewController {
    return isAppearing ? toViewController : fromViewController
  }
  public var otherViewController: UIViewController {
    return isAppearing ? fromViewController : toViewController
  }
}

class ConditionalPreprocessor: BasePreprocessor {
  override func process(fromViews: [UIView], toViews: [UIView]) {
    process(views: fromViews, appearing: false)
    process(views: toViews, appearing: true)
  }

  func process(views: [UIView], appearing: Bool) {
    for view in views {
      guard let conditionalModifiers = context[view]?.conditionalModifiers else { continue }
      for (condition, modifiers) in conditionalModifiers {
        if condition(ATConditionalContext(at: at, view: view, isAppearing: appearing)) {
          context[view]!.append(contentsOf: modifiers)
        }
      }
    }
  }
}
