//
//  AppSetup.swift
//  CustomCamera
//
//  Created by Aybars Acar on 16/6/2022.
//

import UIKit

final class AppSetup {
  static var shared = AppSetup()
  private init() { }
  
  func loadCaptureViewController() {
    
    let bundle = Bundle.main
    let nibName = String(describing: CaptureViewController.self)
    
    let captureVC = CaptureViewController(nibName: nibName, bundle: bundle)
    
    let window = self.keyWindow
    
    window?.rootViewController = captureVC
    window?.makeKeyAndVisible()
  }
  
  var keyWindow: UIWindow? {
    return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
  }
}
