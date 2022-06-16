//
//  RequestPhotoLibraryAuthorisationView.swift
//  CustomCamera
//
//  Created by Aybars Acar on 16/6/2022.
//

import UIKit

protocol RequestPhotoLibraryAuthorisationViewDelegate: AnyObject {
  
  func requestPhotoLibraryTapped()
}

class RequestPhotoLibraryAuthorisationView: UIView {

  @IBOutlet private weak var contentView: UIView!
  @IBOutlet private weak var photoImageView: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var messageLabel: UILabel!
  @IBOutlet private weak var actionButton: UIButton!
  @IBOutlet private weak var actionButtonWidthConstraint: NSLayoutConstraint!
  
  weak var delegate: RequestPhotoLibraryAuthorisationViewDelegate?
  
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
    bundle.loadNibNamed(String(describing: Self.self), owner: self)
    
    addSubview(contentView)
    
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    addActionButtonShadow()
  }
  
  @IBAction func actionButtonHandler(button: UIButton) {
    delegate?.requestPhotoLibraryTapped()
  }
  
  func animateInViews() {
    let viewsToAnimate = [photoImageView, titleLabel, messageLabel, actionButton]
    
    for (i, viewToAnimate) in viewsToAnimate.enumerated() {
      
      guard let viewToAnimate = viewToAnimate else  { continue }
      
      viewToAnimate.animateInView(delay: Double(i) * (0.15))
    }
    
  }
  
  func animateOutViews(completion: @escaping () -> Void) {
    let viewsToAnimate = [photoImageView, titleLabel, messageLabel, actionButton]
    
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
    titleLabel.text = "Photo Library Authorisation Denied"
    actionButton.setTitle("Open Settings", for: .normal)
    
    // increase the width of the button which we connected
    actionButtonWidthConstraint.constant = 180
  }
}

private extension RequestPhotoLibraryAuthorisationView {
  
  func addActionButtonShadow() {
    actionButton.addShadow()
  }
}
