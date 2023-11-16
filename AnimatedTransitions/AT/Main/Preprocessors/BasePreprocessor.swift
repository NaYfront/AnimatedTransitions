//
//  BasePreprocessor.swift
//  AnimatedTransitions
//
//  Created by NaYfront on 05.10.2023.
//

import UIKit

class BasePreprocessor: ATPreprocessor {
  weak public var at: ATTransition!
  public var context: ATContext! {
    return at?.context
  }

  func process(fromViews: [UIView], toViews: [UIView]) {}
}
