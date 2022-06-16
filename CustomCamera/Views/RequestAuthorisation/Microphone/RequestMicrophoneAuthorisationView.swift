//
//  RequestMicrophoneAuthorisationView.swift
//  CustomCamera
//
//  Created by Aybars Acar on 13/6/2022.
//

import UIKit

protocol RequestMicrophoneAuthorisationViewDelegate: AnyObject {
  func requestMicrophoneAuthorisationTapped()
}

final class RequestMicrophoneAuthorisationView: UIView {

  @IBOutlet private weak var contentView: UIView!
  
  @IBOutlet private weak var microphoneImageView: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var messageLabel: UILabel!
  @IBOutlet private weak var actionButton: UIButton!
  @IBOutlet private weak var actionButtonWidthConstraint: NSLayoutConstraint!
  
  weak var delegate: RequestMicrophoneAuthorisationViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    customInit()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    customInit()
  }
  
  private func customInit() {
    // load the nib
    let bundle = Bundle.main
    let nibName = String(describing: Self.self)
    bundle.loadNibNamed(nibName, owner: self, options: nil)
    
    // add the content view as a subview
    addSubview(contentView)
    
    // set the frame of the content view
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    addActionButtonShadowAndCornerRadius()
  }
  
  @IBAction func actionButtonHandler(button: UIButton) {
    delegate?.requestMicrophoneAuthorisationTapped()
  }
  
  private func addActionButtonShadowAndCornerRadius() {
    actionButton.addShadow()
  }
  
  func animateInViews() {
    let viewsToAnimate = [microphoneImageView, titleLabel, messageLabel, actionButton]
    
    for (i, viewToAnimate) in viewsToAnimate.enumerated() {
      
      guard let viewToAnimate = viewToAnimate else  { continue }
      
      viewToAnimate.animateInView(delay: Double(i) * (0.15))
    }
    
  }
  
  func animateOutViews(completion: @escaping () -> Void) {
    let viewsToAnimate = [microphoneImageView, titleLabel, messageLabel, actionButton]
    
    for (i, viewToAnimate) in viewsToAnimate.enumerated() {
      
      guard let viewToAnimate = viewToAnimate else  { continue }
      
      var completionHandler: (() -> Void)? = nil
      
      if viewToAnimate == viewsToAnimate.last {
        completionHandler = completion
      }
      
      viewToAnimate.animateOutView(delay: Double(i) * (0.15), completion: completionHandler)
    }
  }
  
  func configureForErrorState() {
    titleLabel.text = "Microphone Authorisation Denied"
    actionButton.setTitle("Open Settings", for: .normal)
    
    // increase the width of the button which we connected
    actionButtonWidthConstraint.constant = 180
  }

}
