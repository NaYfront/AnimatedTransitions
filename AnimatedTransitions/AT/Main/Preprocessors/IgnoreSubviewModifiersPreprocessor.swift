//
//  IgnoreSubviewModifiersPreprocessor.swift
//  AnimatedTransitions
//
//  Created by NaYfront on 12.10.2023.
//

import UIKit

class IgnoreSubviewModifiersPreprocessor: BasePreprocessor {
  override func process(fromViews: [UIView], toViews: [UIView]) {
    process(views: fromViews)
    process(views: toViews)
  }

  func process(views: [UIView]) {
    for view in views {
      guard let recursive = context[view]?.ignoreSubviewModifiers else { continue }
      var parentView = view
      if view is UITableView, let wrapperView = view.subviews.get(0) {
        parentView = wrapperView
      }

      if recursive {
        cleanSubviewModifiers(parentView)
      } else {
        for subview in parentView.subviews {
          context[subview] = nil
        }
      }
    }
  }

  private func cleanSubviewModifiers(_ parentView: UIView) {
    for view in parentView.subviews {
      context[view] = nil
      cleanSubviewModifiers(view)
    }
  }
}
