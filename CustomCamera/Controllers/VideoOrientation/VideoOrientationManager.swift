//
//  VideoOrientationManager.swift
//  CustomCamera
//
//  Created by Aybars Acar on 23/6/2022.
//

import AVFoundation
import UIKit

final class VideoOrientationManager {
  static let shared = VideoOrientationManager()
  private init() { }
  
  func getVideoOrientation(from interfaceOrientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation? {
    
    switch interfaceOrientation {
    case .portrait:
      return .portrait
    case .portraitUpsideDown:
      return .portraitUpsideDown
    case .landscapeLeft:
      return .landscapeLeft
    case .landscapeRight:
      return .landscapeRight
    default:
      return nil
    }
  }
  
}
