//
//  ATContext.swift
//  AnimatedTransitions
//
//  Created by NaYfront on 16.10.2023.
//

import UIKit

public class ATContext {
  internal var ATIDToSourceView = [String: UIView]()
  internal var ATIDToDestinationView = [String: UIView]()
  internal var snapshotViews = [UIView: UIView]()
  internal var viewAlphas = [UIView: CGFloat]()
  internal var targetStates = [UIView: ATTargetState]()
  internal var superviewToNoSnapshotSubviewMap: [UIView: [(Int, UIView)]] = [:]
  internal var insertToViewFirst = false

  internal var defaultCoordinateSpace: ATCoordinateSpace = .local

  internal init(container: UIView) {
    self.container = container
  }

  internal func set(fromViews: [UIView], toViews: [UIView]) {
    self.fromViews = fromViews
    self.toViews = toViews
    process(views: fromViews, idMap: &ATIDToSourceView)
    process(views: toViews, idMap: &ATIDToDestinationView)
  }

  internal func process(views: [UIView], idMap: inout [String: UIView]) {
    for view in views {
      view.layer.removeAllATAnimations()
      let targetState: ATTargetState?
      if let modifiers = view.at.modifiers {
        targetState = ATTargetState(modifiers: modifiers)
      } else {
        targetState = nil
      }
      if targetState?.forceAnimate == true || container.convert(view.bounds, from: view).intersects(container.bounds) {
        if let atID = view.at.id {
          idMap[atID] = view
        }
        targetStates[view] = targetState
      }
    }
  }

  public let container: UIView

  public var fromViews: [UIView] = []

  public var toViews: [UIView] = []
}

extension ATContext {

  public func sourceView(for atID: String) -> UIView? {
    return ATIDToSourceView[atID]
  }

  public func destinationView(for atID: String) -> UIView? {
    return ATIDToDestinationView[atID]
  }

  public func pairedView(for view: UIView) -> UIView? {
    if let id = view.at.id {
      if sourceView(for: id) == view {
        return destinationView(for: id)
      } else if destinationView(for: id) == view {
        return sourceView(for: id)
      }
    }
    return nil
  }

  public func snapshotView(for view: UIView) -> UIView {
    if let snapshot = snapshotViews[view] {
      return snapshot
    }

    var containerView = container
    let coordinateSpace = targetStates[view]?.coordinateSpace ?? defaultCoordinateSpace
    switch coordinateSpace {
    case .local:
      containerView = view
      while containerView != container, snapshotViews[containerView] == nil, let superview = containerView.superview {
        containerView = superview
      }
      if let snapshot = snapshotViews[containerView] {
        containerView = snapshot
      }

      if let visualEffectView = containerView as? UIVisualEffectView {
        containerView = visualEffectView.contentView
      }
    case .global:
      break
    }

    unhide(view: view)

    let oldMaskedCorners: CACornerMask = {
      if #available(iOS 11, tvOS 11, *) {
        return view.layer.maskedCorners
      } else {
        return []
      }
    }()
    let oldCornerRadius = view.layer.cornerRadius
    let oldAlpha = view.alpha
		let oldShadowRadius = view.layer.shadowRadius
		let oldShadowOffset = view.layer.shadowOffset
		let oldShadowPath = view.layer.shadowPath
		let oldShadowOpacity = view.layer.shadowOpacity
    view.layer.cornerRadius = 0
    view.alpha = 1
		view.layer.shadowRadius = 0.0
		view.layer.shadowOffset = .zero
		view.layer.shadowPath = nil
		view.layer.shadowOpacity = 0.0

    let snapshot: UIView
    let snapshotType: ATSnapshotType = self[view]?.snapshotType ?? .optimized

    switch snapshotType {
    case .normal:
      snapshot = view.snapshotView() ?? UIView()
    case .layerRender:
      snapshot = view.slowSnapshotView()
    case .noSnapshot:
      if let superview = view.superview, superview != container {
        if superviewToNoSnapshotSubviewMap[superview] == nil {
          superviewToNoSnapshotSubviewMap[superview] = []
        }
        if let index = superview.subviews.firstIndex(of: view) {
          superviewToNoSnapshotSubviewMap[superview]!.append((index, view))
        }
      }
      snapshot = view
    case .optimized:
        if let customSnapshotView = view as? ATCustomSnapshotView, let snapshotView = customSnapshotView.atSnapshot {
          snapshot = snapshotView
        } else if #available(iOS 9.0, *), let stackView = view as? UIStackView {
          snapshot = stackView.slowSnapshotView()
        } else if let imageView = view as? UIImageView, view.subviews.filter({!$0.isHidden}).isEmpty {
          let contentView = UIImageView(image: imageView.image)
          contentView.frame = imageView.bounds
          contentView.contentMode = imageView.contentMode
          contentView.tintColor = imageView.tintColor
          contentView.backgroundColor = imageView.backgroundColor
          contentView.layer.magnificationFilter = imageView.layer.magnificationFilter
          contentView.layer.minificationFilter = imageView.layer.minificationFilter
          contentView.layer.minificationFilterBias = imageView.layer.minificationFilterBias
          let snapShotView = UIView()
          snapShotView.addSubview(contentView)
          snapshot = snapShotView
        } else if let barView = view as? UINavigationBar, barView.isTranslucent {
          let newBarView = UINavigationBar(frame: barView.frame)

          newBarView.barStyle = barView.barStyle
          newBarView.tintColor = barView.tintColor
          newBarView.barTintColor = barView.barTintColor
          newBarView.clipsToBounds = false

          barView.layer.sublayers![0].opacity = 0
          let realSnapshot = barView.snapshotView(afterScreenUpdates: true)!
          barView.layer.sublayers![0].opacity = 1

          newBarView.addSubview(realSnapshot)
          snapshot = newBarView
        } else if let effectView = view as? UIVisualEffectView {
          snapshot = UIVisualEffectView(effect: effectView.effect)
          snapshot.frame = effectView.bounds
        } else {
          snapshot = view.snapshotView() ?? UIView()
        }
    }

    if #available(iOS 11, tvOS 11, *) {
      view.layer.maskedCorners = oldMaskedCorners
    }
    view.layer.cornerRadius = oldCornerRadius
    view.alpha = oldAlpha
		view.layer.shadowRadius = oldShadowRadius
		view.layer.shadowOffset = oldShadowOffset
		view.layer.shadowPath = oldShadowPath
		view.layer.shadowOpacity = oldShadowOpacity

    snapshot.layer.anchorPoint = view.layer.anchorPoint
    if let superview = view.superview {
      snapshot.layer.position = containerView.convert(view.layer.position, from: superview)
    }
    snapshot.layer.transform = containerView.layer.flatTransformTo(layer: view.layer)
    snapshot.layer.bounds = view.layer.bounds
    snapshot.at.id = view.at.id

    if snapshotType != .noSnapshot {
      if !(view is UINavigationBar), let contentView = snapshot.subviews.get(0) {
        // the Snapshot's contentView must have hold the cornerRadius value,
        // since the snapshot might not have maskToBounds set
        if #available(iOS 11, tvOS 11, *) {
          contentView.layer.maskedCorners = view.layer.maskedCorners
        }
        contentView.layer.cornerRadius = view.layer.cornerRadius
        contentView.layer.masksToBounds = true
      }

      if #available(iOS 11, tvOS 11, *) {
        snapshot.layer.maskedCorners = view.layer.maskedCorners
      }
      snapshot.layer.cornerRadius = view.layer.cornerRadius
      snapshot.layer.allowsGroupOpacity = false
      snapshot.layer.zPosition = view.layer.zPosition
      snapshot.layer.opacity = view.layer.opacity
      snapshot.layer.isOpaque = view.layer.isOpaque
      snapshot.layer.anchorPoint = view.layer.anchorPoint
      snapshot.layer.masksToBounds = view.layer.masksToBounds
      snapshot.layer.borderColor = view.layer.borderColor
      snapshot.layer.borderWidth = view.layer.borderWidth
      snapshot.layer.contentsRect = view.layer.contentsRect
      snapshot.layer.contentsScale = view.layer.contentsScale

      if self[view]?.displayShadow ?? true {
        snapshot.layer.shadowRadius = view.layer.shadowRadius
        snapshot.layer.shadowOpacity = view.layer.shadowOpacity
        snapshot.layer.shadowColor = view.layer.shadowColor
        snapshot.layer.shadowOffset = view.layer.shadowOffset
        snapshot.layer.shadowPath = view.layer.shadowPath
      }

      hide(view: view)
    }

    if
     let pairedView = pairedView(for: view),
     let pairedSnapshot = snapshotViews[pairedView],
     let siblingViews = pairedView.superview?.subviews,
     let index = siblingViews.firstIndex(of: pairedView) {
      let nextSiblings = siblingViews[index+1..<siblingViews.count]
      containerView.addSubview(pairedSnapshot)
      containerView.addSubview(snapshot)
      for subview in pairedView.subviews {
        insertGlobalViewTree(view: subview)
      }
      for sibling in nextSiblings {
        insertGlobalViewTree(view: sibling)
      }
    } else {
      containerView.addSubview(snapshot)
    }
    containerView.addSubview(snapshot)
    snapshotViews[view] = snapshot
    return snapshot
  }

  func insertGlobalViewTree(view: UIView) {
    if targetStates[view]?.coordinateSpace == .global, let snapshot = snapshotViews[view] {
      container.addSubview(snapshot)
    }
    for subview in view.subviews {
      insertGlobalViewTree(view: subview)
    }
  }

  public subscript(view: UIView) -> ATTargetState? {
    get {
      return targetStates[view]
    }
    set {
      targetStates[view] = newValue
    }
  }

  public func clean() {
    for (superview, subviews) in superviewToNoSnapshotSubviewMap {
      for (index, view) in subviews.reversed() {
        superview.insertSubview(view, at: index)
      }
    }
  }
}

// internal
extension ATContext {
  public func hide(view: UIView) {
    if viewAlphas[view] == nil {
      if view is UIVisualEffectView {
        view.isHidden = true
        viewAlphas[view] = 1
      } else {
        viewAlphas[view] = view.alpha
        view.alpha = 0
      }
    }
  }
  public func unhide(view: UIView) {
    if let oldAlpha = viewAlphas[view] {
      if view is UIVisualEffectView {
        view.isHidden = false
      } else {
        view.alpha = oldAlpha
      }
      viewAlphas[view] = nil
    }
  }
  internal func unhideAll() {
    for view in viewAlphas.keys {
      unhide(view: view)
    }
    viewAlphas.removeAll()
  }
  internal func unhide(rootView: UIView) {
    unhide(view: rootView)
    for subview in rootView.subviews {
      unhide(rootView: subview)
    }
  }

  internal func removeAllSnapshots() {
    for (view, snapshot) in snapshotViews {
      if view != snapshot {
        snapshot.removeFromSuperview()
      } else {
        view.layer.removeAllATAnimations()
      }
    }
  }
  internal func removeSnapshots(rootView: UIView) {
    if let snapshot = snapshotViews[rootView] {
      if rootView != snapshot {
        snapshot.removeFromSuperview()
      } else {
        rootView.layer.removeAllATAnimations()
      }
    }
    for subview in rootView.subviews {
      removeSnapshots(rootView: subview)
    }
  }
  internal func snapshots(rootView: UIView) -> [UIView] {
    var snapshots = [UIView]()
    for v in rootView.flattenedViewHierarchy {
      if let snapshot = snapshotViews[v] {
        snapshots.append(snapshot)
      }
    }
    return snapshots
  }
  internal func loadViewAlpha(rootView: UIView) {
    if let storedAlpha = rootView.at.storedAlpha {
      rootView.alpha = storedAlpha
      rootView.at.storedAlpha = nil
    }
    for subview in rootView.subviews {
      loadViewAlpha(rootView: subview)
    }
  }
  internal func storeViewAlpha(rootView: UIView) {
    rootView.at.storedAlpha = viewAlphas[rootView]
    for subview in rootView.subviews {
      storeViewAlpha(rootView: subview)
    }
  }
}

public protocol ATCustomSnapshotView {
	var atSnapshot: UIView? { get }
}
