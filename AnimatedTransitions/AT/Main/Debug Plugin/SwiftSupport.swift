#if canImport(UIKit) && !(swift(>=4.2))
import Foundation
import CoreMedia
import CoreGraphics

extension CMTime {
	static let zero = kCMTimeZero
}

enum CAMediaTimingFillMode {
  static let both = kCAFillModeBoth
}

enum CAMediaTimingFunctionName {
  static let linear = kCAMediaTimingFunctionLinear
  static let easeIn = kCAMediaTimingFunctionEaseIn
  static let easeOut = kCAMediaTimingFunctionEaseOut
  static let easeInEaseOut = kCAMediaTimingFunctionEaseInEaseOut
}

import UIKit

extension UIControl {
  typealias State = UIControlState
}

public extension UINavigationController {
  typealias Operation = UINavigationControllerOperation
}

extension UIViewController {
  var children: [UIViewController] {
    return childViewControllers
  }
}

extension RunLoop {
  enum Mode {
		static let common = RunLoopMode.commonModes
  }
}

#endif
