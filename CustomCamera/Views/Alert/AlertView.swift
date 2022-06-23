//
//  AlertView.swift
//  CustomCamera
//
//  Created by Aybars Acar on 23/6/2022.
//

import UIKit

class AlertView: UIView {

  @IBOutlet private weak var contentView: UIView!
  @IBOutlet private weak var containerView: UIView!
  @IBOutlet private weak var alertLabel: UILabel!
  
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
  }
  
  func setAlertText(_ text: String) {
    alertLabel.text = text
  }
}
