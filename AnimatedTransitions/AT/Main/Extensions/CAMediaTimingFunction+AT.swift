#if canImport(QuartzCore)
import QuartzCore

public extension CAMediaTimingFunction {
  // default
  static let linear = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
  static let easeIn = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
  static let easeOut = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
  static let easeInOut = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

  // material
  static let standard = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
  static let deceleration = CAMediaTimingFunction(controlPoints: 0.0, 0.0, 0.2, 1)
  static let acceleration = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 1, 1)
  static let sharp = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.6, 1)

  // easing.net
  static let easeOutBack = CAMediaTimingFunction(controlPoints: 0.175, 0.885, 0.32, 1.275)

  static func from(name: String) -> CAMediaTimingFunction? {
    switch name {
    case "linear":
      return .linear
    case "easeIn":
      return .easeIn
    case "easeOut":
      return .easeOut
    case "easeInOut":
      return .easeInOut
    case "standard":
      return .standard
    case "deceleration":
      return .deceleration
    case "acceleration":
      return .acceleration
    case "sharp":
      return .sharp
    default:
      return nil
    }
  }
}

#endif
