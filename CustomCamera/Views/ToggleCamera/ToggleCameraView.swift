//
//  ToggleCameraView.swift
//  CustomCamera
//
//  Created by Aybars Acar on 19/6/2022.
//

import UIKit

protocol ToggleCameraViewDelegate: AnyObject {
  
  func toggleCameraTapped()
}

class ToggleCameraView: UIView {

  @IBOutlet private weak var contentView: UIView!
  
  weak var delegate: ToggleCameraViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    customInit()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    customInit()
  }
  
  private func customInit() {
    // load the nib file
    let bundle = Bundle.main
    let nibName = String(describing: Self.self)
    bundle.loadNibNamed(nibName, owner: self)
    
    addSubview(contentView)
    
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleWidth]
  }
  
  @IBAction func toggleButtonHandler(button: UIButton) {
    delegate?.toggleCameraTapped()
  }
}
