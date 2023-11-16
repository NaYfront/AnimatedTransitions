import UIKit

internal extension CALayer {
  // return all animations running by this layer.
  // the returned value is mutable
  var animations: [(String, CAAnimation)] {
    if let keys = animationKeys() {
      // swiftlint:disable:next force_cast
      return keys.map { return ($0, self.animation(forKey: $0)!.copy() as! CAAnimation) }
    }
    return []
  }

  func flatTransformTo(layer: CALayer) -> CATransform3D {
    var layer = layer
    var trans = layer.transform
    while let superlayer = layer.superlayer, superlayer != self, !(superlayer.delegate is UIWindow) {
      trans = CATransform3DConcat(superlayer.transform, trans)
      layer = superlayer
    }
    return trans
  }

  func removeAllATAnimations() {
    guard let keys = animationKeys() else { return }
    for animationKey in keys where animationKey.hasPrefix("at.") {
      removeAnimation(forKey: animationKey)
    }
  }
}
