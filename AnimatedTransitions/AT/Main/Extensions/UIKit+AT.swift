import UIKit

private let parameterRegex = "(?:\\-?\\d+(\\.?\\d+)?)|\\w+"
private let modifiersRegex = "(\\w+)(?:\\(([^\\)]*)\\))?"

internal extension NSCoding where Self: NSObject {
  func copyWithArchiver() -> Any? {
		if #available(iOS 11.0, tvOS 11.0, *) {
			return try? NSKeyedUnarchiver.unarchivedObject(ofClass: type(of: self), from: NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false))
		} else {
			return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self))!
		}
  }
}

internal extension UIImage {
  class func imageWithView(view: UIView) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
    view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return img!
  }
}

internal extension UIColor {
  var components:(r:CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    getRed(&r, green: &g, blue: &b, alpha: &a)
    return (r, g, b, a)
  }
  var alphaComponent: CGFloat {
    return components.a
  }
}
