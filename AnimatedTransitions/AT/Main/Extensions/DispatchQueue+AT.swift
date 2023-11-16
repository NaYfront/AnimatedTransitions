import Foundation

func delay(_ time: Double, execute: @escaping () -> Void) {
  if time > 0 {
    DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: execute)
  } else {
    DispatchQueue.main.async(execute: execute)
  }
}
