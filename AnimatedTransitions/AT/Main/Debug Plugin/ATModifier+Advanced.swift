//
//  ATModifier.swift
//  AnimatedTransitions
//
//  Created by NaYfront on 04.11.2023.
//

// advance modifiers
extension ATModifier {
  public static func beginWith(_ modifiers: [ATModifier]) -> ATModifier {
    return ATModifier { targetState in
      if targetState.beginState == nil {
        targetState.beginState = []
      }
      targetState.beginState!.append(contentsOf: modifiers)
    }
  }

  public static func beginWith(modifiers: [ATModifier]) -> ATModifier {
    return .beginWith(modifiers)
  }

  public static func beginWith(_ modifiers: ATModifier...) -> ATModifier {
    return .beginWith(modifiers)
  }

  public static var useGlobalCoordinateSpace: ATModifier = ATModifier { targetState in
    targetState.coordinateSpace = .global
  }

  public static var ignoreSubviewModifiers: ATModifier = .ignoreSubviewModifiers()

  public static func ignoreSubviewModifiers(recursive: Bool = false) -> ATModifier {
    return ATModifier { targetState in
      targetState.ignoreSubviewModifiers = recursive
    }
  }

  public static var useOptimizedSnapshot: ATModifier = ATModifier { targetState in
    targetState.snapshotType = .optimized
  }

  public static var useNormalSnapshot: ATModifier = ATModifier { targetState in
    targetState.snapshotType = .normal
  }

  public static var useLayerRenderSnapshot: ATModifier = ATModifier { targetState in
    targetState.snapshotType = .layerRender
  }

  public static var useNoSnapshot: ATModifier = ATModifier { targetState in
    targetState.snapshotType = .noSnapshot
  }

  public static var forceAnimate = ATModifier { targetState in
    targetState.forceAnimate = true
  }

  public static var useScaleBasedSizeChange: ATModifier = ATModifier { targetState in
    targetState.useScaleBasedSizeChange = true
  }
}
