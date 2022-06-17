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
    
    initialiseCaptureSession()
    
    
  }
  
  func getCaptureSession() -> AVCaptureSession {
    return captureSession
  }
}

private extension CaptureSessionManager {
  
  func getVideoCaptureDevice() -> AVCaptureDevice? {
    
    if let tripleCamera = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back) {
      return tripleCamera
    }
    
    if let dualWideCamera = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) {
      return dualWideCamera
    }
    
    if let dualCamera = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
      return dualCamera
    }
    
    if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
      return wideAngleCamera
    }
    
    return nil
  }
  
  func getCaptureDeviceInput(captureDevice: AVCaptureDevice) -> AVCaptureDeviceInput? {
    do {
      return try AVCaptureDeviceInput(device: captureDevice)
    } catch {
      print("Failed to get capture device input with error: \(error)")
      return nil
    }
  }
  
  func initialiseCaptureSession() {
    guard let captureDevice = getVideoCaptureDevice(),
          let captureDeviceInput = getCaptureDeviceInput(captureDevice: captureDevice),
          captureSession.canAddInput(captureDeviceInput) else {
      return
    }
    
    captureSession.addInput(captureDeviceInput)
    
    captureSession.startRunning()
  }
}
