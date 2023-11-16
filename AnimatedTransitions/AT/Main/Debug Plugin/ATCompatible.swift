import Foundation

public protocol ATCompatible {
  associatedtype CompatibleType

  var at: ATExtension<CompatibleType> { get set }
}

public extension ATCompatible {
  var at: ATExtension<Self> {
    get { return ATExtension(self) }
    // swiftlint:disable unused_setter_value
    set { }
  }
}

public class ATExtension<Base> {
  public let base: Base

  init(_ base: Base) {
    self.base = base
  }
}
