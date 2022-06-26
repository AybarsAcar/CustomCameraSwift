//
//  RecordView.swift
//  CustomCamera
//
//  Created by Aybars Acar on 17/6/2022.
//

import UIKit

enum RecordViewState {
  case stopped, recording
}

protocol RecordViewDelegate: AnyObject {
  func recordViewStartRecording(_ recordView: RecordView)
  func recordViewEndRecording(_ recordView: RecordView)
}

final class RecordView: UIView {

  @IBOutlet private weak var contentView: UIView!
  @IBOutlet private weak var containerView: UIView!
  @IBOutlet private weak var ringView: UIView!
  @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var stopView: UIView!
  
  weak var delegate: RecordViewDelegate?

  private var state: RecordViewState = .stopped
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    customInit()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    customInit()
  }
  
  private func customInit() {
    let bundle = Bundle.main
    let nibName = String(describing: Self.self)
    bundle.loadNibNamed(nibName, owner: self)
    
    addSubview(contentView)
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    setupContainerView()
  }

  @IBAction func tapHandler(tapGestureRecognizer: UITapGestureRecognizer) {
    switch state {
      
    case .stopped:
      state = .recording
      animateForRecording()
      delegate?.recordViewStartRecording(self)
      
    case .recording:
      state = .stopped
      animateForStopped()
      delegate?.recordViewEndRecording(self)
      
    }
  }
}

private extension RecordView {
  
  func setupContainerView() {
    // set up the stroke
    containerView.layer.borderWidth = 4
    containerView.layer.borderColor = UIColor.white.cgColor
  }
  
  func animateForRecording() {
    
    let ringViewAnimation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) { [weak self] in
      guard let self = self else { return }
      self.ringView.transform = CGAffineTransform(translationX: 0, y: 70)
      self.ringView.alpha = 0
    }
    
    stopView.transform = CGAffineTransform(translationX: 0, y: 70)
    stopView.alpha = 0
    stopView.isHidden = false
    
    let stopViewAnimation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) { [weak self] in
      guard let self = self else { return }
      
      self.stopView.transform = .identity
      self.stopView.alpha = 1
    }

    ringViewAnimation.startAnimation()
    stopViewAnimation.startAnimation(afterDelay: 0.3)
  }
  
  func animateForStopped() {
    let stopViewAnimation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) { [weak self] in
      guard let self = self else { return }
      
      self.stopView.transform = CGAffineTransform(translationX: 0, y: 70)
      self.stopView.alpha = 0
    }
    
    ringView.transform = CGAffineTransform(translationX: 0, y: 70)
    ringView.alpha = 0
    
    let ringViewAnimation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) { [weak self] in
      guard let self = self else { return }
      
      self.ringView.transform = .identity
      self.ringView.alpha = 1
    }
    
    stopViewAnimation.startAnimation()
    ringViewAnimation.startAnimation(afterDelay: 0.3)
  }
}
