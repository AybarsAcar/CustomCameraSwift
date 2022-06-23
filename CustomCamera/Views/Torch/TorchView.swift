//
//  TorchView.swift
//  CustomCamera
//
//  Created by Aybars Acar on 23/6/2022.
//

import UIKit

enum TorchMode {
  case off, on
}

protocol TorchViewDelegate: AnyObject {
  func torchTapped(torchMode: TorchMode, completion: (_ success: Bool) -> Void)
}

final class TorchView: UIView {

  @IBOutlet private weak var contentView: UIView!
  @IBOutlet private weak var torchButton: UIButton!
  
  private var torchMode: TorchMode = .off
  
  weak var delegate: TorchViewDelegate?
  
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
  
  @IBAction func torchButtonHandler(button: UIButton) {
    
    delegate?.torchTapped(torchMode: torchMode) { [weak self] success in
      guard let self = self, success else { return }
      
      
      switch self.torchMode {
      case .off:
        self.torchButton.tintColor = .selectedColor
        self.torchMode = .on
        
      case .on:
        self.torchButton.tintColor = .textOnBackgroundAlpha
        self.torchMode = .off
      }
      
    }
    
  }
}
