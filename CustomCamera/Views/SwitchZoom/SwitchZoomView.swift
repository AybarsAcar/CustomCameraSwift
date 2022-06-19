//
//  SwitchZoomView.swift
//  CustomCamera
//
//  Created by Aybars Acar on 19/6/2022.
//

import UIKit

enum ZoomState {
  case ultrawide, wide, telephoto
}

protocol SwitchZoomViewDelegate: AnyObject {
  
  func switchZoomTapped(state: ZoomState)
}

final class SwitchZoomView: UIView {

  @IBOutlet private weak var contentView: UIView!
  @IBOutlet private weak var stackView: UIStackView!
  @IBOutlet private weak var ultraWideButton: UIButton!
  @IBOutlet private weak var wideButton: UIButton!
  @IBOutlet private weak var telephotoButton: UIButton!
  
  private var zoomState: ZoomState = .wide
  
  private var selectedButton: UIButton?
  
  public weak var delegate: SwitchZoomViewDelegate?
  
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
    
    wideButton.setTitleColor(.selectedColor, for: .normal)
    selectedButton = wideButton
  }
  
  // MARK: - Button Actions
  
  @IBAction func ultraWideButtonHandler(button: UIButton) {
    selectedButton?.setTitleColor(.textOnBackgroundAlpha, for: .normal)
    
    zoomState = .ultrawide
    ultraWideButton.setTitleColor(.selectedColor, for: .normal)
    selectedButton = ultraWideButton
    
    delegate?.switchZoomTapped(state: zoomState)
  }
  
  @IBAction func wideButtonHandler(button: UIButton) {
    selectedButton?.setTitleColor(.textOnBackgroundAlpha, for: .normal)
    
    zoomState = .wide
    wideButton.setTitleColor(.selectedColor, for: .normal)
    selectedButton = wideButton
    
    delegate?.switchZoomTapped(state: zoomState)
  }
  
  @IBAction func telephotoButtonHandler(button: UIButton) {
    selectedButton?.setTitleColor(.textOnBackgroundAlpha, for: .normal)
    
    zoomState = .telephoto
    telephotoButton.setTitleColor(.selectedColor, for: .normal)
    selectedButton = telephotoButton
    
    delegate?.switchZoomTapped(state: zoomState)
  }
  
  func hideUltraWideButton() {
    ultraWideButton.isHidden = true
  }
  
  func hideTelephotoButton() {
    telephotoButton.isHidden = true
  }
  
  func configureForPortraitOrientation() {
    stackView.axis = .horizontal
  }
  
  func configureForLandscapeOrientation() {
    stackView.axis = .vertical
  }
}
