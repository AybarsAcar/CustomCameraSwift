//
//  RequestCameraAuthorisationView.swift
//  CustomCamera
//
//  Created by Aybars Acar on 13/6/2022.
//

import UIKit

protocol RequestCameraAuthorisationViewDelegate: AnyObject {
  func requestCameraAuthorisationTapped()
}

/// this will be our view that we display when requesting authorisation
final class RequestCameraAuthorisationView: UIView {

  @IBOutlet private weak var contentView: UIView!
  
  @IBOutlet private weak var cameraImageView: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var messageLabel: UILabel!
  @IBOutlet private weak var actionButton: UIButton!
  
  weak var delegate: RequestCameraAuthorisationViewDelegate?
  
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
  }
  
  @IBAction func actionButtonHandler(button: UIButton) {
    delegate?.requestCameraAuthorisationTapped()
  }
}
