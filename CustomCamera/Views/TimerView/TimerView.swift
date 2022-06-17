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
  
  /// displays the time as mm:ss
  public func updateTime(seconds: Int64) {
  
    let timeInterval = TimeInterval(integerLiteral: seconds)
    
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
    
    timerLabel.text = formatter.string(from: timeInterval) ?? "00:00"
  }
}
