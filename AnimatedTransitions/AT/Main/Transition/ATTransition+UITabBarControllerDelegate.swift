import UIKit

extension ATTransition: UITabBarControllerDelegate {
  public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    guard tabBarController.selectedViewController !== viewController else {
      return false
    }
    if isTransitioning {
      cancel(animate: false)
    }
    return true
  }

  public func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactiveTransitioning
  }

  public func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    guard !isTransitioning else { return nil }
    self.state = .notified
    let fromVCIndex = tabBarController.children.firstIndex(of: fromVC)!
    let toVCIndex = tabBarController.children.firstIndex(of: toVC)!
    self.isPresenting = toVCIndex > fromVCIndex
    self.fromViewController = fromViewController ?? fromVC
    self.toViewController = toViewController ?? toVC
    self.inTabBarController = true
    return self
  }
}
