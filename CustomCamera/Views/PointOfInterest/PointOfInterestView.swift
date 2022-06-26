//
//  PointOfInterestView.swift
//  CustomCamera
//
//  Created by Aybars Acar on 26/6/2022.
//

import UIKit

/// the Square View that is displayed when camera focus tap action
final class PointOfInterestView: UIView {

  @IBOutlet private weak var contentView: UIView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    customInit()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    customInit()
  }

  private func customInit() {
    let bunde = Bundle.main
    let nibName = String(describing: Self.self)
    
    bunde.loadNibNamed(nibName, owner: self)
    
    addSubview(contentView)
    
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    // set the border style
    contentView.layer.borderColor = UIColor.yellow.cgColor
    contentView.layer.borderWidth = 1
  }
}
