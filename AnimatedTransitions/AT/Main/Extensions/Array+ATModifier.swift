import Foundation

#if canImport(CoreGraphics)
import CoreGraphics
#endif

internal extension Array {
  func get(_ index: Int) -> Element? {
    if index < count {
      return self[index]
    }
    return nil
  }
}

internal extension Array where Element: ExprNode {
	#if canImport(CoreGraphics)
  func getCGFloat(_ index: Int) -> CGFloat? {
    if let s = get(index) as? NumberNode {
      return CGFloat(s.value)
    }
    return nil
  }
	#endif
  func getDouble(_ index: Int) -> Double? {
    if let s = get(index) as? NumberNode {
      return Double(s.value)
    }
    return nil
  }
  func getFloat(_ index: Int) -> Float? {
    if let s = get(index) as? NumberNode {
      return s.value
    }
    return nil
  }
  func getBool(_ index: Int) -> Bool? {
    if let s = get(index) as? VariableNode, let f = Bool(s.name) {
      return f
    }
    return nil
  }
}
