//
//  DefaultAnimationPreprocessor.swift
//  AnimatedTransitions
//
//  Created by NaYfront on 03.10.2023.
//

import UIKit

public enum ATDefaultAnimationType {
  public enum Direction: ATStringConvertible {
    case left, right, up, down
    public static func from(node: ExprNode) -> Direction? {
      switch node.name {
      case "left": return .left
      case "right": return .right
      case "up": return .up
      case "down": return .down
      case "leading": return .leading
      case "trailing": return .trailing
      default: return nil
      }
    }

    public static var leadingToTrailing: CascadeDirection {
      return !Locale.isDeviceLanguageRightToLeft ? .leftToRight : .rightToLeft
    }

    public static var trailingToLeading: CascadeDirection {
      return !Locale.isDeviceLanguageRightToLeft ? .rightToLeft : .leftToRight
    }

    public static var leading: Direction {
      return !Locale.isDeviceLanguageRightToLeft ? .left : .right
    }

    public static var trailing: Direction {
      return !Locale.isDeviceLanguageRightToLeft ? .right : .left
    }
  }

  public enum Strategy {
    case forceLeftToRight, forceRightToLeft, userInterface
    func defaultDirection(presenting: Bool) -> Direction {
      switch self {
      case .forceLeftToRight:
        return presenting ? .left : .right
      case .forceRightToLeft:
        return presenting ? .right : .left
      case .userInterface:
        return presenting ? .leading : .trailing
      }
    }
  }

  case auto
  case push(direction: Direction)
  case pull(direction: Direction)
  case cover(direction: Direction)
  case uncover(direction: Direction)
  case slide(direction: Direction)
  case zoomSlide(direction: Direction)
  case pageIn(direction: Direction)
  case pageOut(direction: Direction)
  case fade
  case zoom
  case zoomOut

  indirect case selectBy(presenting: ATDefaultAnimationType, dismissing: ATDefaultAnimationType)

  public static func autoReverse(presenting: ATDefaultAnimationType) -> ATDefaultAnimationType {
    return .selectBy(presenting: presenting, dismissing: presenting.reversed())
  }

  case none

  func reversed() -> ATDefaultAnimationType {
    switch self {
    case .push(direction: .up):
      return .pull(direction: .down)
    case .push(direction: .right):
      return .pull(direction: .left)
    case .push(direction: .down):
      return .pull(direction: .up)
    case .push(direction: .left):
      return .pull(direction: .right)
    case .pull(direction: .up):
      return .push(direction: .down)
    case .pull(direction: .right):
      return .push(direction: .left)
    case .pull(direction: .down):
      return .push(direction: .up)
    case .pull(direction: .left):
      return .push(direction: .right)
    case .cover(direction: .up):
      return .uncover(direction: .down)
    case .cover(direction: .right):
      return .uncover(direction: .left)
    case .cover(direction: .down):
      return .uncover(direction: .up)
    case .cover(direction: .left):
      return .uncover(direction: .right)
    case .uncover(direction: .up):
      return .cover(direction: .down)
    case .uncover(direction: .right):
      return .cover(direction: .left)
    case .uncover(direction: .down):
      return .cover(direction: .up)
    case .uncover(direction: .left):
      return .cover(direction: .right)
    case .slide(direction: .up):
      return .slide(direction: .down)
    case .slide(direction: .down):
      return .slide(direction: .up)
    case .slide(direction: .left):
      return .slide(direction: .right)
    case .slide(direction: .right):
      return .slide(direction: .left)
    case .zoomSlide(direction: .up):
      return .zoomSlide(direction: .down)
    case .zoomSlide(direction: .down):
      return .zoomSlide(direction: .up)
    case .zoomSlide(direction: .left):
      return .zoomSlide(direction: .right)
    case .zoomSlide(direction: .right):
      return .zoomSlide(direction: .left)
    case .pageIn(direction: .up):
      return .pageOut(direction: .down)
    case .pageIn(direction: .right):
      return .pageOut(direction: .left)
    case .pageIn(direction: .down):
      return .pageOut(direction: .up)
    case .pageIn(direction: .left):
      return .pageOut(direction: .right)
    case .pageOut(direction: .up):
      return .pageIn(direction: .down)
    case .pageOut(direction: .right):
      return .pageIn(direction: .left)
    case .pageOut(direction: .down):
      return .pageIn(direction: .up)
    case .pageOut(direction: .left):
      return .pageIn(direction: .right)
    case .zoom:
      return .zoomOut
    case .zoomOut:
      return .zoom

    default:
      return self
    }
  }

  public var label: String? {
    let mirror = Mirror(reflecting: self)
    if let associated = mirror.children.first {
      let valuesMirror = Mirror(reflecting: associated.value)
      if !valuesMirror.children.isEmpty {
        let parameters = valuesMirror.children.map { ".\($0.value)" }.joined(separator: ",")
        return ".\(associated.label ?? "")(\(parameters))"
      }
      return ".\(associated.label ?? "")(.\(associated.value))"
    }
    return ".\(self)"
  }
}

extension ATDefaultAnimationType: ATStringConvertible {
  public static func from(node: ExprNode) -> ATDefaultAnimationType? {
    let name: String = node.name
    let parameters: [ExprNode] = (node as? CallNode)?.arguments ?? []

    switch name {
    case "auto":
      return .auto
    case "push":
      if let node = parameters.get(0), let direction = Direction.from(node: node) {
        return .push(direction: direction)
      }
    case "pull":
      if let node = parameters.get(0), let direction = Direction.from(node: node) {
        return .pull(direction: direction)
      }
    case "cover":
      if let node = parameters.get(0), let direction = Direction.from(node: node) {
        return .cover(direction: direction)
      }
    case "uncover":
      if let node = parameters.get(0), let direction = Direction.from(node: node) {
        return .uncover(direction: direction)
      }
    case "slide":
      if let node = parameters.get(0), let direction = Direction.from(node: node) {
        return .slide(direction: direction)
      }
    case "zoomSlide":
      if let node = parameters.get(0), let direction = Direction.from(node: node) {
        return .zoomSlide(direction: direction)
      }
    case "pageIn":
      if let node = parameters.get(0), let direction = Direction.from(node: node) {
        return .pageIn(direction: direction)
      }
    case "pageOut":
      if let node = parameters.get(0), let direction = Direction.from(node: node) {
        return .pageOut(direction: direction)
      }
    case "fade": return .fade
    case "zoom": return .zoom
    case "zoomOut": return .zoomOut
    case "selectBy":
      if let presentingNode = parameters.get(0),
        let presenting = ATDefaultAnimationType.from(node: presentingNode),
        let dismissingNode = parameters.get(1),
        let dismissing = ATDefaultAnimationType.from(node: dismissingNode) {
        return .selectBy(presenting: presenting, dismissing: dismissing)
      }
    case "none": return ATDefaultAnimationType.none
    default: break
    }
    return nil
  }
}

class DefaultAnimationPreprocessor: BasePreprocessor {
  func shift(direction: ATDefaultAnimationType.Direction, appearing: Bool, size: CGSize? = nil, transpose: Bool = false) -> CGPoint {
    let size = size ?? context.container.bounds.size
    let rtn: CGPoint
    switch direction {
    case .left, .right:
      rtn = CGPoint(x: (direction == .right) == appearing ? -size.width : size.width, y: 0)
    case .up, .down:
      rtn = CGPoint(x: 0, y: (direction == .down) == appearing ? -size.height : size.height)
    }
    if transpose {
      return CGPoint(x: rtn.y, y: rtn.x)
    }
    return rtn
  }

  override func process(fromViews: [UIView], toViews: [UIView]) {
    guard let at = at, let toView = at.toView, let fromView = at.fromView else { return }
    var defaultAnimation = at.defaultAnimation
    let inNavigationController = at.inNavigationController
    let inTabBarController = at.inTabBarController
    let toViewController = at.toViewController
    let fromViewController = at.fromViewController
    let presenting = at.isPresenting
    let fromOverFullScreen = at.fromOverFullScreen
    let toOverFullScreen = at.toOverFullScreen
    let animators = at.animators

    if case .auto = defaultAnimation {
      if inNavigationController, let navAnim = toViewController?.navigationController?.at.navigationAnimationType {
        defaultAnimation = navAnim
      } else if inTabBarController, let tabAnim = toViewController?.tabBarController?.at.tabBarAnimationType {
        defaultAnimation = tabAnim
      } else if let modalAnim = (presenting ? toViewController : fromViewController)?.at.modalAnimationType {
        defaultAnimation = modalAnim
      }
    }

    if case .selectBy(let presentAnim, let dismissAnim) = defaultAnimation {
      defaultAnimation = presenting ? presentAnim : dismissAnim
    }

    if case .auto = defaultAnimation {
      if animators.contains(where: { $0.canAnimate(view: toView, appearing: true) || $0.canAnimate(view: fromView, appearing: false) }) {
        defaultAnimation = .none
      } else if inNavigationController {
        let direction = at.defaultAnimationDirectionStrategy.defaultDirection(presenting: presenting)
        defaultAnimation = .push(direction: direction)
      } else if inTabBarController {
        let direction = at.defaultAnimationDirectionStrategy.defaultDirection(presenting: presenting)
        defaultAnimation = .slide(direction: direction)
      } else {
        defaultAnimation = .fade
      }
    }

    if case .none = defaultAnimation {
      return
    }

    context[fromView] = [.timingFunction(.standard), .duration(0.35)]
    context[toView] = [.timingFunction(.standard), .duration(0.35)]

    let shadowState: [ATModifier] = [.shadowOpacity(0.5),
                                       .shadowColor(.black),
                                       .shadowRadius(5),
                                       .shadowOffset(.zero),
                                       .masksToBounds(false)]
    switch defaultAnimation {
    case .push(let direction):
      context.insertToViewFirst = false
      context[toView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: true)),
                                           .shadowOpacity(0),
                                           .beginWith(modifiers: shadowState),
                                           .timingFunction(.deceleration)])
      context[fromView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: false) / 3),
                                             .overlay(color: .black, opacity: 0.1),
                                             .timingFunction(.deceleration)])
    case .pull(let direction):
      context.insertToViewFirst = true
      context[fromView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: false)),
                                             .shadowOpacity(0),
                                             .beginWith(modifiers: shadowState)])
      context[toView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: true) / 3),
                                           .overlay(color: .black, opacity: 0.1)])
    case .slide(let direction):
      context[fromView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: false))])
      context[toView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: true))])
    case .zoomSlide(let direction):
      context[fromView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: false)), .scale(0.8)])
      context[toView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: true)), .scale(0.8)])
    case .cover(let direction):
      context.insertToViewFirst = false
      context[toView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: true)),
                                           .shadowOpacity(0),
                                           .beginWith(modifiers: shadowState),
                                           .timingFunction(.deceleration)])
      context[fromView]!.append(contentsOf: [.overlay(color: .black, opacity: 0.1),
                                             .timingFunction(.deceleration)])
    case .uncover(let direction):
      context.insertToViewFirst = true
      context[fromView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: false)),
                                             .shadowOpacity(0),
                                             .beginWith(modifiers: shadowState)])
      context[toView]!.append(contentsOf: [.overlay(color: .black, opacity: 0.1)])
    case .pageIn(let direction):
      context.insertToViewFirst = false
      context[toView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: true)),
                                           .shadowOpacity(0),
                                           .beginWith(modifiers: shadowState),
                                           .timingFunction(.deceleration)])
      context[fromView]!.append(contentsOf: [.scale(0.7),
                                             .overlay(color: .black, opacity: 0.1),
                                             .timingFunction(.deceleration)])
    case .pageOut(let direction):
      context.insertToViewFirst = true
      context[fromView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: false)),
                                             .shadowOpacity(0),
                                             .beginWith(modifiers: shadowState)])
      context[toView]!.append(contentsOf: [.scale(0.7),
                                           .overlay(color: .black, opacity: 0.1)])
    case .fade:
      // TODO: clean up this. overFullScreen logic shouldn't be here
      if !(fromOverFullScreen && !presenting) {
        context[toView] = [.fade]
      }

      #if os(tvOS)
        context[fromView] = [.fade]
      #else
        if (!presenting && toOverFullScreen) || !fromView.isOpaque || (fromView.backgroundColor?.alphaComponent ?? 1) < 1 {
          context[fromView] = [.fade]
        }
      #endif

      context[toView]!.append(.durationMatchLongest)
      context[fromView]!.append(.durationMatchLongest)
    case .zoom:
      context.insertToViewFirst = true
      context[fromView]!.append(contentsOf: [.scale(1.3), .fade])
      context[toView]!.append(contentsOf: [.scale(0.7)])
    case .zoomOut:
      context.insertToViewFirst = false
      context[toView]!.append(contentsOf: [.scale(1.3), .fade])
      context[fromView]!.append(contentsOf: [.scale(0.7)])
    default:
      fatalError("Not implemented")
    }
  }
}
