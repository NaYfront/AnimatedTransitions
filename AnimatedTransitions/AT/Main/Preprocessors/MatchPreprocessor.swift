//
//  MatchPreprocessor.swift
//  AnimatedTransitions
//
//  Created by NaYfront on 04.10.2023.
//

import UIKit

class MatchPreprocessor: BasePreprocessor {
  override func process(fromViews: [UIView], toViews: [UIView]) {
    for tv in toViews {
      guard let id = tv.at.id, let fv = context.sourceView(for: id) else { continue }

      var tvState = context[tv] ?? ATTargetState()
      var fvState = context[fv] ?? ATTargetState()

      // match is just a two-way source effect
      tvState.source = id
      fvState.source = id

      fvState.arc = tvState.arc
      fvState.duration = tvState.duration
      fvState.timingFunction = tvState.timingFunction
      fvState.delay = tvState.delay
      fvState.spring = tvState.spring

      let forceNonFade = tvState.nonFade || fvState.nonFade
      let isNonOpaque = !fv.isOpaque || fv.alpha < 1 || !tv.isOpaque || tv.alpha < 1

      if context.insertToViewFirst {
        fvState.opacity = 0
        if !forceNonFade && isNonOpaque {
          tvState.opacity = 0
        } else {
          tvState.opacity = nil
          if !tv.layer.masksToBounds && tvState.displayShadow {
            fvState.displayShadow = false
          }
        }
      } else {
        tvState.opacity = 0
        if !forceNonFade && isNonOpaque {
          // cross fade if from/toViews are not opaque
          fvState.opacity = 0
        } else {
          // no cross fade in this case, fromView is always displayed during the transition.
          fvState.opacity = nil

          // we dont want two shadows showing up. Therefore we disable toView's shadow when fromView is able to display its shadow
          if !fv.layer.masksToBounds && fvState.displayShadow {
            tvState.displayShadow = false
          }
        }
      }

      context[tv] = tvState
      context[fv] = fvState
    }
  }
}

