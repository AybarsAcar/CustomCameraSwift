//
//  UIView+Animations.swift
//  CustomCamera
//
//  Created by Aybars Acar on 16/6/2022.
//

import UIKit

extension UIView {
  
  func animateInView(delay: TimeInterval = 0) {
    self.alpha = 0
    self.transform = CGAffineTransform(translationX: 0, y: -20)
    
    let animation = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
      self.alpha = 1
      self.transform = .identity
    }
    
    animation.startAnimation(afterDelay: delay)
  }
  
  func animateOutView(delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
    let animation = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
      self.alpha = 0
      self.transform = CGAffineTransform(translationX: 0, y: -20)
    }
    
    animation.addCompletion { _ in
      completion?()
    }
    
    animation.startAnimation(afterDelay: delay)
  }
}
