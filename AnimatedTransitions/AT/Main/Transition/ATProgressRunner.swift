import QuartzCore

protocol ATProgressRunnerDelegate: AnyObject {
  func updateProgress(progress: Double)
  func complete(finished: Bool)
}

class ATProgressRunner {
  weak var delegate: ATProgressRunnerDelegate?

  var isRunning: Bool {
    return displayLink != nil
  }
  internal var timePassed: TimeInterval = 0.0
  internal var duration: TimeInterval = 0.0
    internal var isReversed: Bool = false

  internal var displayLink: CADisplayLink?

  @objc func displayUpdate(_ link: CADisplayLink) {
    timePassed += isReversed ? -link.duration : link.duration
    if isReversed, timePassed <= 1.0 / 120 {
      delegate?.complete(finished: false)
      stop()
      return
    }

    if !isReversed, timePassed > duration - 1.0 / 120 {
      delegate?.complete(finished: true)
      stop()
      return
    }

    delegate?.updateProgress(progress: timePassed / duration)
  }

  func start(timePassed: TimeInterval, totalTime: TimeInterval, reverse: Bool) {
    stop()
    self.timePassed = timePassed
    self.isReversed = reverse
    self.duration = totalTime
    displayLink = CADisplayLink(target: self, selector: #selector(displayUpdate(_:)))
    displayLink!.add(to: .main, forMode: RunLoop.Mode.common)
  }

  func stop() {
    displayLink?.isPaused = true
    displayLink?.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
    displayLink = nil
  }
}
