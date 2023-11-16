//
//  ATViewControllerDelegate.swift
//  AnimatedTransitions
//
//  Created by NaYfront on 16.10.2023.
//

import UIKit

@objc public protocol ATViewControllerDelegate {
  @objc optional func atWillStartAnimatingFrom(viewController: UIViewController)
  @objc optional func atDidEndAnimatingFrom(viewController: UIViewController)
  @objc optional func atDidCancelAnimatingFrom(viewController: UIViewController)

  @objc optional func atWillStartTransition()
  @objc optional func atDidEndTransition()
  @objc optional func atDidCancelTransition()

  @objc optional func atWillStartAnimatingTo(viewController: UIViewController)
  @objc optional func atDidEndAnimatingTo(viewController: UIViewController)
  @objc optional func atDidCancelAnimatingTo(viewController: UIViewController)
}

internal extension ATTransition {
  func closureProcessForATDelegate<T: UIViewController>(vc: T, closure: (ATViewControllerDelegate) -> Void) {
    if let delegate = vc as? ATViewControllerDelegate {
      closure(delegate)
    }

    if let navigationController = vc as? UINavigationController,
      let delegate = navigationController.topViewController as? ATViewControllerDelegate {
      closure(delegate)
    } else if let tabBarController = vc as? UITabBarController,
      let delegate = tabBarController.selectedViewController as? ATViewControllerDelegate {
      closure(delegate)
    } else {
      for vc in vc.children where vc.isViewLoaded {
        self.closureProcessForATDelegate(vc: vc, closure: closure)
      }
    }
  }
}
