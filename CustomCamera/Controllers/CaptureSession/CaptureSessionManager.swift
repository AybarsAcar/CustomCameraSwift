//
//  CaptureSessionManager.swift
//  CustomCamera
//
//  Created by Aybars Acar on 16/6/2022.
//

import Foundation
import AVFoundation

final class CaptureSessionManager: NSObject {
  
  private lazy var captureSession = AVCaptureSession()
  
  override init() {
    super.init()
    
    // get the back camera
    if let captureDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
      
      // create the input device
      if let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) {
        // set the device input and start the method
        captureSession.addInput(deviceInput)
      }
      
      captureSession.startRunning()
    }
    
    
  }
  
  func getCaptureSession() -> AVCaptureSession {
    return captureSession
  }
}
