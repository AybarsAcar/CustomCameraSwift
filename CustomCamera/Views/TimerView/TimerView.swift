//
//  TimerView.swift
//  CustomCamera
//
//  Created by Aybars Acar on 17/6/2022.
//

import UIKit

final class TimerView: UIView {

  @IBOutlet private weak var contentView: UIView!
  @IBOutlet private weak var timerLabel: UILabel!
  
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
}
