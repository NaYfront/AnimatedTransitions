import UIKit
import CoreGraphics
import QuartzCore

public final class ATModifier {
  internal let apply:(inout ATTargetState) -> Void
  public init(applyFunction:@escaping (inout ATTargetState) -> Void) {
    apply = applyFunction
  }
}

extension ATModifier {
  public static var fade = ATModifier { targetState in
    targetState.opacity = 0
  }

  public static var forceNonFade = ATModifier { targetState in
    targetState.nonFade = true
  }

  public static func position(_ position: CGPoint) -> ATModifier {
    return ATModifier { targetState in
      targetState.position = position
    }
  }

  public static func size(_ size: CGSize) -> ATModifier {
    return ATModifier { targetState in
      targetState.size = size
    }
  }
}

extension ATModifier {
  public static func transform(_ t: CATransform3D) -> ATModifier {
    return ATModifier { targetState in
      targetState.transform = t
    }
  }
    
  public static func perspective(_ perspective: CGFloat) -> ATModifier {
    return ATModifier { targetState in
      var transform = targetState.transform ?? CATransform3DIdentity
      transform.m34 = 1.0 / -perspective
      targetState.transform = transform
    }
  }

  public static func scale(x: CGFloat = 1, y: CGFloat = 1, z: CGFloat = 1) -> ATModifier {
    return ATModifier { targetState in
      targetState.transform = CATransform3DScale(targetState.transform ?? CATransform3DIdentity, x, y, z)
    }
  }

  public static func scale(_ xy: CGFloat) -> ATModifier {
    return .scale(x: xy, y: xy)
  }

  public static func translate(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> ATModifier {
    return ATModifier { targetState in
      targetState.transform = CATransform3DTranslate(targetState.transform ?? CATransform3DIdentity, x, y, z)
    }
  }

  public static func translate(_ point: CGPoint, z: CGFloat = 0) -> ATModifier {
    return translate(x: point.x, y: point.y, z: z)
  }

  public static func rotate(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> ATModifier {
    return ATModifier { targetState in
      targetState.transform = CATransform3DRotate(targetState.transform ?? CATransform3DIdentity, x, 1, 0, 0)
      targetState.transform = CATransform3DRotate(targetState.transform!, y, 0, 1, 0)
      targetState.transform = CATransform3DRotate(targetState.transform!, z, 0, 0, 1)
    }
  }

  public static func rotate(_ point: CGPoint, z: CGFloat = 0) -> ATModifier {
    return rotate(x: point.x, y: point.y, z: z)
  }

  public static func rotate(_ z: CGFloat) -> ATModifier {
    return .rotate(z: z)
  }
}

// MARK: UIKit
extension ATModifier {
  public static func backgroundColor(_ backgroundColor: UIColor) -> ATModifier {
    return ATModifier { targetState in
      targetState.backgroundColor = backgroundColor.cgColor
    }
  }

  public static func borderColor(_ borderColor: UIColor) -> ATModifier {
    return ATModifier { targetState in
      targetState.borderColor = borderColor.cgColor
    }
  }

  public static func shadowColor(_ shadowColor: UIColor) -> ATModifier {
    return ATModifier { targetState in
      targetState.shadowColor = shadowColor.cgColor
    }
  }

  public static func overlay(color: UIColor, opacity: CGFloat) -> ATModifier {
    return ATModifier { targetState in
      targetState.overlay = (color.cgColor, opacity)
    }
  }
}

extension ATModifier {
  public static func opacity(_ opacity: CGFloat) -> ATModifier {
    return ATModifier { targetState in
      targetState.opacity = Float(opacity)
    }
  }
    
  public static func cornerRadius(_ cornerRadius: CGFloat) -> ATModifier {
    return ATModifier { targetState in
      targetState.cornerRadius = cornerRadius
    }
  }

  public static func zPosition(_ zPosition: CGFloat) -> ATModifier {
    return ATModifier { targetState in
      targetState.zPosition = zPosition
    }
  }

  public static func contentsRect(_ contentsRect: CGRect) -> ATModifier {
    return ATModifier { targetState in
      targetState.contentsRect = contentsRect
    }
  }

  public static func contentsScale(_ contentsScale: CGFloat) -> ATModifier {
    return ATModifier { targetState in
      targetState.contentsScale = contentsScale
    }
  }

  public static func borderWidth(_ borderWidth: CGFloat) -> ATModifier {
    return ATModifier { targetState in
      targetState.borderWidth = borderWidth
    }
  }

  public static func shadowOpacity(_ shadowOpacity: CGFloat) -> ATModifier {
    return ATModifier { targetState in
      targetState.shadowOpacity = Float(shadowOpacity)
    }
  }

  public static func shadowOffset(_ shadowOffset: CGSize) -> ATModifier {
    return ATModifier { targetState in
      targetState.shadowOffset = shadowOffset
    }
  }

  public static func shadowRadius(_ shadowRadius: CGFloat) -> ATModifier {
    return ATModifier { targetState in
      targetState.shadowRadius = shadowRadius
    }
  }

  public static func shadowPath(_ shadowPath: CGPath) -> ATModifier {
    return ATModifier { targetState in
      targetState.shadowPath = shadowPath
    }
  }

  public static func masksToBounds(_ masksToBounds: Bool) -> ATModifier {
    return ATModifier { targetState in
      targetState.masksToBounds = masksToBounds
    }
  }
}

extension ATModifier {
  public static func duration(_ duration: TimeInterval) -> ATModifier {
    return ATModifier { targetState in
      targetState.duration = duration
    }
  }

  public static var durationMatchLongest: ATModifier = ATModifier { targetState in
    targetState.duration = .infinity
  }

  public static func delay(_ delay: TimeInterval) -> ATModifier {
    return ATModifier { targetState in
      targetState.delay = delay
    }
  }

  public static func timingFunction(_ timingFunction: CAMediaTimingFunction) -> ATModifier {
    return ATModifier { targetState in
      targetState.timingFunction = timingFunction
    }
  }

  @available(iOS 9, *)
  public static func spring(stiffness: CGFloat, damping: CGFloat) -> ATModifier {
    return ATModifier { targetState in
      targetState.spring = (stiffness, damping)
    }
  }
}

extension ATModifier {
  public static func source(atID: String) -> ATModifier {
    return ATModifier { targetState in
      targetState.source = atID
    }
  }

  public static var arc: ATModifier = .arc()

  public static func arc(intensity: CGFloat = 1) -> ATModifier {
    return ATModifier { targetState in
      targetState.arc = intensity
    }
  }

  public static var cascade: ATModifier = .cascade()

  public static func cascade(delta: TimeInterval = 0.02,
                             direction: CascadeDirection = .topToBottom,
                             delayMatchedViews: Bool = false) -> ATModifier {
    return ATModifier { targetState in
      targetState.cascade = (delta, direction, delayMatchedViews)
    }
  }
}


extension ATModifier {
  public static func when(_ condition: @escaping (ATConditionalContext) -> Bool, _ modifiers: [ATModifier]) -> ATModifier {
    return ATModifier { targetState in
      if targetState.conditionalModifiers == nil {
        targetState.conditionalModifiers = []
      }
      targetState.conditionalModifiers!.append((condition, modifiers))
    }
  }

  public static func when(_ condition: @escaping (ATConditionalContext) -> Bool, _ modifiers: ATModifier...) -> ATModifier {
    return .when(condition, modifiers)
  }

  public static func whenMatched(_ modifiers: ATModifier...) -> ATModifier {
    return .when({ $0.isMatched }, modifiers)
  }

  public static func whenPresenting(_ modifiers: ATModifier...) -> ATModifier {
    return .when({ $0.isPresenting }, modifiers)
  }

  public static func whenDismissing(_ modifiers: ATModifier...) -> ATModifier {
    return .when({ !$0.isPresenting }, modifiers)
  }

  public static func whenAppearing(_ modifiers: ATModifier...) -> ATModifier {
    return .when({ $0.isAppearing }, modifiers)
  }

  public static func whenDisappearing(_ modifiers: ATModifier...) -> ATModifier {
    return .when({ !$0.isAppearing }, modifiers)
  }
}
