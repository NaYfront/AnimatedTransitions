#if canImport(UIKit) && os(iOS)

import UIKit

public class ATDebugPlugin: ATPlugin {
  public static var showOnTop: Bool = false

  var debugView: ATDebugView?
  var zPositionMap = [UIView: CGFloat]()
  var addedLayers: [CALayer] = []
  var updating = false

  override public func animate(fromViews: [UIView], toViews: [UIView]) -> TimeInterval {
    if at.forceNotInteractive { return 0 }
    var hasArc = false
    for v in context.fromViews + context.toViews where context[v]?.arc != nil && context[v]?.position != nil {
      hasArc = true
      break
    }
    let debugView = ATDebugView(initialProcess: at.isPresenting ? 0.0 : 1.0, showCurveButton: hasArc, showOnTop: ATDebugPlugin.showOnTop)
    debugView.frame = at.container.bounds
    debugView.delegate = self
    at.container.window?.addSubview(debugView)

    debugView.layoutSubviews()
    self.debugView = debugView

    UIView.animate(withDuration: 0.4) {
      debugView.showControls = true
    }

    return .infinity
  }

  public override func resume(timePassed: TimeInterval, reverse: Bool) -> TimeInterval {
    guard let debugView = debugView else { return 0.4 }
    debugView.delegate = nil

    UIView.animate(withDuration: 0.4) {
      debugView.showControls = false
      debugView.debugSlider.setValue(roundf(debugView.progress), animated: true)
    }

    on3D(wants3D: false)
    return 0.4
  }

  public override func clean() {
    debugView?.removeFromSuperview()
    debugView = nil
  }
}

extension ATDebugPlugin: ATDebugViewDelegate {
  public func onDone() {
    guard let debugView = debugView else { return }
    let seekValue = at.isPresenting ? debugView.progress : 1.0 - debugView.progress
    if seekValue > 0.5 {
      at.finish()
    } else {
      at.cancel()
    }
  }

  public func onProcessSliderChanged(progress: Float) {
    let seekValue = at.isPresenting ? progress : 1.0 - progress
    at.update(CGFloat(seekValue))
  }

  func onPerspectiveChanged(translation: CGPoint, rotation: CGFloat, scale: CGFloat) {
    var t = CATransform3DIdentity
    t.m34 = -1 / 4000
    t = CATransform3DTranslate(t, translation.x, translation.y, 0)
    t = CATransform3DScale(t, scale, scale, 1)
    t = CATransform3DRotate(t, rotation, 0, 1, 0)
    at.container.layer.sublayerTransform = t
  }

  func animateZPosition(view: UIView, to: CGFloat) {
    let a = CABasicAnimation(keyPath: "zPosition")
    a.fromValue = view.layer.value(forKeyPath: "zPosition")
    a.toValue = NSNumber(value: Double(to))
    a.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    a.duration = 0.4
    view.layer.add(a, forKey: "zPosition")
    view.layer.zPosition = to
  }

  func onDisplayArcCurve(wantsCurve: Bool) {
    for layer in addedLayers {
      layer.removeFromSuperlayer()
      addedLayers.removeAll()
    }
    if wantsCurve {
      for layer in at.container.layer.sublayers! {
        for (_, anim) in layer.animations {
          if let keyframeAnim = anim as? CAKeyframeAnimation, let path = keyframeAnim.path {
            let s = CAShapeLayer()
            s.zPosition = layer.zPosition + 10
            s.path = path
            s.strokeColor = UIColor.blue.cgColor
            s.fillColor = UIColor.clear.cgColor
            at.container.layer.addSublayer(s)
            addedLayers.append(s)
          }
        }
      }
    }
  }

  func on3D(wants3D: Bool) {
    var t = CATransform3DIdentity
    if wants3D {
      var viewsWithZPosition = Set<UIView>()
      for view in at.container.subviews where view.layer.zPosition != 0 {
        viewsWithZPosition.insert(view)
        zPositionMap[view] = view.layer.zPosition
      }

      let viewsWithoutZPosition = at.container.subviews.filter { return !viewsWithZPosition.contains($0) }
      let viewsWithPositiveZPosition = viewsWithZPosition.filter { return $0.layer.zPosition > 0 }

      for (i, v) in viewsWithoutZPosition.enumerated() {
        animateZPosition(view: v, to: CGFloat(i * 10))
      }

      var maxZPosition: CGFloat = 0
      for v in viewsWithPositiveZPosition {
        maxZPosition = max(maxZPosition, v.layer.zPosition)
        animateZPosition(view: v, to: v.layer.zPosition + CGFloat(viewsWithoutZPosition.count * 10))
      }

      t.m34 = -1 / 4000
      t = CATransform3DTranslate(t, debugView!.translation.x, debugView!.translation.y, 0)
      t = CATransform3DScale(t, debugView!.scale, debugView!.scale, 1)
      t = CATransform3DRotate(t, debugView!.rotation, 0, 1, 0)
    } else {
      for v in at.container.subviews {
        animateZPosition(view: v, to: self.zPositionMap[v] ?? 0)
      }
      self.zPositionMap.removeAll()
    }

    let a = CABasicAnimation(keyPath: "sublayerTransform")
    a.fromValue = at.container.layer.value(forKeyPath: "sublayerTransform")
    a.toValue = NSValue(caTransform3D: t)
    a.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    a.duration = 0.4

    UIView.animate(withDuration: 0.4) {
      self.context.container.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
    }

    at.container.layer.add(a, forKey: "debug")
    at.container.layer.sublayerTransform = t
  }
}

#endif
