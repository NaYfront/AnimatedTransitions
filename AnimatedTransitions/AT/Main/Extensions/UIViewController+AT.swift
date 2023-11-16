//
//  ATViewControllerConfig.swift
//  AnimatedTransitions
//
//  Created by NaYfront on 05.11.2023.
//

import UIKit

internal class ATViewControllerConfig: NSObject {
  var modalAnimation: ATDefaultAnimationType = .auto
  var navigationAnimation: ATDefaultAnimationType = .auto
  var tabBarAnimation: ATDefaultAnimationType = .auto

  var storedSnapshot: UIView?
  weak var previousNavigationDelegate: UINavigationControllerDelegate?
  weak var previousTabBarDelegate: UITabBarControllerDelegate?
}

extension UIViewController: ATCompatible { }
public extension ATExtension where Base: UIViewController {

  internal var config: ATViewControllerConfig {
    get {
      if let config = objc_getAssociatedObject(base, &type(of: base).AssociatedKeys.atConfig) as? ATViewControllerConfig {
        return config
      }
      let config = ATViewControllerConfig()
      self.config = config
      return config
    }
    set { objc_setAssociatedObject(base, &type(of: base).AssociatedKeys.atConfig, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  /// used for .overFullScreen presentation
  internal var storedSnapshot: UIView? {
    get { return config.storedSnapshot }
    set { config.storedSnapshot = newValue }
  }

  var modalAnimationType: ATDefaultAnimationType {
    get { return config.modalAnimation }
    set { config.modalAnimation = newValue }
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  var modalAnimationTypeString: String? {
    get { return config.modalAnimation.label }
    set { config.modalAnimation = newValue?.parseOne() ?? .auto }
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  var isEnabled: Bool {
    get {
      return base.transitioningDelegate is ATTransition
    }
    set {
      guard newValue != isEnabled else { return }
      if newValue {
        base.transitioningDelegate = AT.shared
        if let navi = base as? UINavigationController {
          base.previousNavigationDelegate = navi.delegate
          navi.delegate = AT.shared
        }
        if let tab = base as? UITabBarController {
          base.previousTabBarDelegate = tab.delegate
          tab.delegate = AT.shared
        }
      } else {
        base.transitioningDelegate = nil
        if let navi = base as? UINavigationController, navi.delegate is ATTransition {
          navi.delegate = base.previousNavigationDelegate
        }
        if let tab = base as? UITabBarController, tab.delegate is ATTransition {
          tab.delegate = base.previousTabBarDelegate
        }
      }
    }
  }
}

public extension UIViewController {
  fileprivate struct AssociatedKeys {
    static var atConfig = "atConfig"
  }

  @available(*, renamed: "at.config")
  internal var atConfig: ATViewControllerConfig {
    get { return at.config }
    set { at.config = newValue }
  }

  internal var previousNavigationDelegate: UINavigationControllerDelegate? {
    get { return at.config.previousNavigationDelegate }
    set { at.config.previousNavigationDelegate = newValue }
  }

  internal var previousTabBarDelegate: UITabBarControllerDelegate? {
    get { return at.config.previousTabBarDelegate }
    set { at.config.previousTabBarDelegate = newValue }
  }

  @available(*, renamed: "at.storedSnapshot")
  internal var atStoredSnapshot: UIView? {
    get { return at.config.storedSnapshot }
    set { at.config.storedSnapshot = newValue }
  }

  @available(*, renamed: "at.modalAnimationType")
  var atModalAnimationType: ATDefaultAnimationType {
    get { return at.modalAnimationType }
    set { at.modalAnimationType = newValue }
  }

  @available(*, renamed: "at.modalAnimationTypeString")
  @IBInspectable var atModalAnimationTypeString: String? {
    get { return at.modalAnimationTypeString }
    set { at.modalAnimationTypeString = newValue }
  }

  @available(*, renamed: "at.isEnabled")
  @IBInspectable var isATEnabled: Bool {
    get { return at.isEnabled }
    set { at.isEnabled = newValue }
  }
}

public extension ATExtension where Base: UINavigationController {

  var navigationAnimationType: ATDefaultAnimationType {
    get { return config.navigationAnimation }
    set { config.navigationAnimation = newValue }
  }

  var navigationAnimationTypeString: String? {
    get { return config.navigationAnimation.label }
    set { config.navigationAnimation = newValue?.parseOne() ?? .auto }
  }
}

extension UINavigationController {
  @available(*, renamed: "at.navigationAnimationType")
  public var atNavigationAnimationType: ATDefaultAnimationType {
    get { return at.navigationAnimationType }
    set { at.navigationAnimationType = newValue }
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  @available(*, renamed: "at.navigationAnimationTypeString")
  @IBInspectable public var atNavigationAnimationTypeString: String? {
    get { return at.navigationAnimationTypeString }
    set { at.navigationAnimationTypeString = newValue }
  }

   func setViewControllers(viewControllers: [UIViewController], animated: Bool, completion: (() -> Void)?) {
		setViewControllers(viewControllers, animated: animated)
		guard animated, let coordinator = transitionCoordinator else {
			DispatchQueue.main.async { completion?() }
			return
		}
		coordinator.animate(alongsideTransition: nil) { _ in completion?() }
	}
}

public extension ATExtension where Base: UITabBarController {

  var tabBarAnimationType: ATDefaultAnimationType {
    get { return config.tabBarAnimation }
    set { config.tabBarAnimation = newValue }
  }

  var tabBarAnimationTypeString: String? {
    get { return config.tabBarAnimation.label }
    set { config.tabBarAnimation = newValue?.parseOne() ?? .auto }
  }
}

public extension UITabBarController {
  @available(*, renamed: "at.tabBarAnimationType")
  var atTabBarAnimationType: ATDefaultAnimationType {
    get { return at.tabBarAnimationType }
    set { at.tabBarAnimationType = newValue }
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  @available(*, renamed: "at.tabBarAnimationTypeString")
  @IBInspectable var atTabBarAnimationTypeString: String? {
    get { return at.tabBarAnimationTypeString }
    set { at.tabBarAnimationTypeString = newValue }
  }
}

public extension ATExtension where Base: UIViewController {

  func dismissViewController(completion: (() -> Void)? = nil) {
    if let navigationController = base.navigationController, navigationController.viewControllers.first != base {
      navigationController.popViewController(animated: true)
    } else {
      base.dismiss(animated: true, completion: completion)
    }
  }

  func unwindToRootViewController() {
    unwindToViewController { $0.presentingViewController == nil }
  }

  func unwindToViewController(_ toViewController: UIViewController) {
    unwindToViewController { $0 == toViewController }
  }

  func unwindToViewController(withSelector: Selector) {
    unwindToViewController { $0.responds(to: withSelector) }
  }

  func unwindToViewController(withClass: AnyClass) {
    unwindToViewController { $0.isKind(of: withClass) }
  }

  func unwindToViewController(withMatchBlock: (UIViewController) -> Bool) {
    var target: UIViewController?
    var current: UIViewController? = base

    while target == nil && current != nil {
      if let childViewControllers = (current as? UINavigationController)?.children ?? current!.navigationController?.children {
        for vc in childViewControllers.reversed() {
          if vc != base, withMatchBlock(vc) {
            target = vc
            break
          }
        }
      }
      if target == nil {
        current = current!.presentingViewController
        if let vc = current, withMatchBlock(vc) == true {
          target = vc
        }
      }
    }

    if let target = target {
      if target.presentedViewController != nil {
        _ = target.navigationController?.popToViewController(target, animated: false)

        let fromVC = base.navigationController ?? base
        let toVC = target.navigationController ?? target

        if target.presentedViewController != fromVC {
          AT.shared.fromViewController = fromVC
          let snapshotView = fromVC.view.snapshotView(afterScreenUpdates: true)!
          let targetSuperview = toVC.presentedViewController!.view!
          if let visualEffectView = targetSuperview as? UIVisualEffectView {
            visualEffectView.contentView.addSubview(snapshotView)
          } else {
            targetSuperview.addSubview(snapshotView)
          }
        }

        toVC.dismiss(animated: true, completion: nil)
      } else {
        _ = target.navigationController?.popToViewController(target, animated: true)
      }
    }
  }

  func replaceViewController(with next: UIViewController, completion: (() -> Void)? = nil) {
    let at = next.transitioningDelegate as? ATTransition ?? AT.shared

    if at.isTransitioning {
      print("stop")
      return
    }
    if let navigationController = base.navigationController {
      var vcs = navigationController.children
      if !vcs.isEmpty {
        vcs.removeLast()
        vcs.append(next)
      }
      if navigationController.at.isEnabled {
        at.forceNotInteractive = true
      }
      navigationController.setViewControllers(viewControllers: vcs, animated: true, completion: completion)
    } else if let container = base.view.superview, let parentVC = base.presentingViewController {
      at.transition(from: base, to: next, in: container) { [weak base] finished in
        guard let base = base, finished else { return }
        next.view.window?.addSubview(next.view)
        base.dismiss(animated: false) {
          parentVC.present(next, animated: false, completion: completion)
        }
      }
    } else if let baseWindow = base.view.window, baseWindow.rootViewController == base {
      at.transition(from: base, to: next, in: baseWindow) { [weak base] finished in
        guard base != nil, finished else { return }
        baseWindow.rootViewController = next
      }
    }
  }
}

extension UIViewController {
  @available(*, deprecated, renamed: "at.dismissViewController()")
  @IBAction public func ht_dismiss(_ sender: UIView) {
    at.dismissViewController()
  }

  @available(*, deprecated, renamed: "at.replaceViewController(with:)")
  public func atReplaceViewController(with next: UIViewController) {
    at.replaceViewController(with: next)
  }

  @available(*, deprecated, renamed: "at.dismissViewController()")
  @IBAction public func at_dismissViewController() {
    at.dismissViewController()
  }

  @available(*, deprecated, renamed: "at.unwindToRootViewController()")
  @IBAction public func at_unwindToRootViewController() {
    at.unwindToRootViewController()
  }

  @available(*, deprecated, renamed: "at.unwindToViewController(_:)")
  public func at_unwindToViewController(_ toViewController: UIViewController) {
    at.unwindToViewController(toViewController)
  }

  @available(*, deprecated, renamed: "at.unwindToViewController(withSelector:)")
  public func at_unwindToViewController(withSelector: Selector) {
    at.unwindToViewController(withSelector: withSelector)
  }

  @available(*, deprecated, renamed: "at_unwindToViewController(withClass:)")
  public func at_unwindToViewController(withClass: AnyClass) {
    at.unwindToViewController(withClass: withClass)
  }

  @available(*, deprecated, renamed: "at.unwindToViewController(withMatchBlock:)")
  public func at_unwindToViewController(withMatchBlock: (UIViewController) -> Bool) {
    at.unwindToViewController(withMatchBlock: withMatchBlock)
  }

  @available(*, deprecated, renamed: "at.replaceViewController(with:)")
  public func at_replaceViewController(with next: UIViewController) {
    at.replaceViewController(with: next)
  }
}
