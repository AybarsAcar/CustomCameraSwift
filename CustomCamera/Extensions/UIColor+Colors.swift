//
//  UIColor+Colors.swift
//  CustomCamera
//
//  Created by Aybars Acar on 19/6/2022.
//

import UIKit

extension UIColor {
  
  static var backgroundAlpha60: UIColor {
    return UIColor(named: "BackgroundAlpha60")!
  }
  
  static var selectedColor: UIColor {
    return UIColor(named: "SelectedColor") ?? UIColor.systemYellow
  }
  
  static var textOnBackgroundAlpha: UIColor {
    return UIColor(named: "TextOnBackgroundAlpha")!
  }
}
