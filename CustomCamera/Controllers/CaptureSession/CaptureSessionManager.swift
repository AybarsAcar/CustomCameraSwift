//
//  CaptureSessionManager.swift
//  CustomCamera
//
//  Created by Aybars Acar on 16/6/2022.
//

import Foundation
import AVFoundation

enum CameraType {
  case ultrawide, wide, telephoto
}

enum CameraPosition {
  case front, back
}

typealias CaptureSessionInitialisedCompletionHandler = () -> Void
typealias CaptureSessionToggleCompletionHandler = (_ cameraPosition: CameraPosition) -> Void

final class CaptureSessionManager: NSObject {
  
  private lazy var captureSession = AVCaptureSession()
  
  // current capture device
  private var captureDevice: AVCaptureDevice?
  private var captureDeviceInput: AVCaptureDeviceInput?
  private var zoomState: ZoomState = .wide
  
  private var cameraPosition: CameraPosition = .back
  
  private var previousZoomState: ZoomState = .wide
  
  override init() {
    super.init()
    
    captureDevice = getBackCameraVideoCaptureDevice()
    
  }
  
  func getCaptureSession() -> AVCaptureSession {
    return captureSession
  }
  
  func setZoomState(_ zoomState: ZoomState) {
    self.zoomState = zoomState
    setVideoZoomFactor() // update the currently displaying Capture Session Controller Details
  }
  
  func getCameraTypes() -> [CameraType]? {
    guard let captureDevice = captureDevice else {
      return nil
    }

    switch captureDevice.deviceType {
    case .builtInTripleCamera:
      return [.ultrawide, .wide, .telephoto]
      
    case .builtInDualWideCamera:
      return [.ultrawide, .wide]
      
    case .builtInDualCamera:
      return [.wide, .telephoto]
      
    case .builtInWideAngleCamera:
      return [.wide]
      
    default:
      return nil
    }
  }
  
  func toggleCamera(completion: CaptureSessionToggleCompletionHandler? = nil) {
    // remove the capture device input
    if let captureDeviceInput = captureDeviceInput {
      captureSession.removeInput(captureDeviceInput)
    }
    
    // reinitialise the capture session in the next run loop
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      
      switch self.cameraPosition {
        
      case .front:
        // if we are in the front camera, switch to back camera
        if let backCaptureDevice = self.getBackCameraVideoCaptureDevice() {
          self.initialiseCaptureSession(captureDevice: backCaptureDevice)
        }
        self.cameraPosition = .back
        
        self.zoomState = self.previousZoomState
        self.setVideoZoomFactor()
        
      case .back:
        self.previousZoomState = self.zoomState
        self.zoomState = .wide
        
        // if we are back switch to front camera
        if let frontCaptureDevice = self.getFrontCameraVideoCaptureDevice() {
          self.initialiseCaptureSession(captureDevice: frontCaptureDevice)
        }
        self.cameraPosition = .front
      }
      
      self.resetFocus()
      
      completion?(self.cameraPosition)
    }
  }
  
  func initialiseCaptureSession(captureDevice: AVCaptureDevice? = nil, completion: CaptureSessionInitialisedCompletionHandler? = nil) {
    
    var tempCaptureDevice = self.captureDevice
    
    if let passedCaptureDevice = captureDevice {
      tempCaptureDevice = passedCaptureDevice
    }
    
    guard let captureDevice = tempCaptureDevice,
          let captureDeviceInput = getCaptureDeviceInput(captureDevice: captureDevice),
          captureSession.canAddInput(captureDeviceInput) else {
      return
    }
    
    self.captureDevice = captureDevice
    self.captureDeviceInput = captureDeviceInput
    
    NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: captureDevice)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(subjectAreaDidChangeNotificationHandler(notification:)),
      name: .AVCaptureDeviceSubjectAreaDidChange,
      object: captureDevice
    )
    
    captureSession.addInput(captureDeviceInput)
    
    captureSession.startRunning()
    
    setVideoZoomFactor()
    
    completion?()
  }
  
  func stopRunning() {
    captureSession.stopRunning()
  }
  
  func startRunning() {
    captureSession.startRunning()
  }
  
  func setFocus(
    focusMode: AVCaptureDevice.FocusMode,
    exposureMode: AVCaptureDevice.ExposureMode,
    atPoint devicePoint: CGPoint,
    shouldMonitorSubjectAreaChange: Bool
  ) {
  
    guard let captureDevice = captureDevice else {
      return
    }

    do {
      try captureDevice.lockForConfiguration()
    } catch {
      print("Failed to get lock for configuration on capture device with error \(error)")
      return
    }
    
    // handle focus
    if captureDevice.isFocusPointOfInterestSupported && captureDevice.isFocusModeSupported(focusMode) {
      captureDevice.focusPointOfInterest = devicePoint
      captureDevice.focusMode = focusMode
    }
    
    // handle exposure
    if captureDevice.isExposurePointOfInterestSupported && captureDevice.isExposureModeSupported(exposureMode) {
      captureDevice.exposurePointOfInterest = devicePoint
      captureDevice.exposureMode = exposureMode
    }
    
    captureDevice.isSubjectAreaChangeMonitoringEnabled = shouldMonitorSubjectAreaChange
    
    captureDevice.unlockForConfiguration()
  }
  
  @objc func subjectAreaDidChangeNotificationHandler(notification: Notification) {
    let devicePoint = CGPoint(x: 0.5, y: 0.5)
    setFocus(focusMode: .continuousAutoFocus, exposureMode: .continuousAutoExposure, atPoint: devicePoint, shouldMonitorSubjectAreaChange: false)
  }
  
  func turnOnTorch() -> Bool {
    return setTorchMode(to: .on)
  }
  
  func turnOffTorch() -> Bool {
    return setTorchMode(to: .off)
  }
}

private extension CaptureSessionManager {
  
  func getBackCameraVideoCaptureDevice() -> AVCaptureDevice? {
    
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
  
  func getFrontCameraVideoCaptureDevice() -> AVCaptureDevice? {
    
    if let trueDepthCamera = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front) {
      return trueDepthCamera
    }
    
    if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
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
  
  func setVideoCaptureDeviceZoom(videoZoomFactor: CGFloat, animated: Bool = false, rate: Float = 0) {
    guard let captureDevice = captureDevice else { return }
    
    do {
      // lock the camera device for configuration
      try captureDevice.lockForConfiguration()
    } catch {
      print("Failed to get lock configuration on capture device with error \(error)")
      return
    }
    
    if animated {
      captureDevice.ramp(toVideoZoomFactor: videoZoomFactor, withRate: rate)
    }
    else {
      captureDevice.videoZoomFactor = videoZoomFactor
    }
    
    // release the lock
    captureDevice.unlockForConfiguration()
  }
  
  func getVideoZoomFactor() -> CGFloat {
    switch zoomState {
    case .ultrawide:
      return 1
      
    case .wide:
      return getWideVideoZoomFactor()
      
    case.telephoto:
      return getTelephotoVideoZoomFactor()
    }
  }
  
  func getWideVideoZoomFactor() -> CGFloat {
    guard let captureDevice = captureDevice else {
      return 1 // default zoom factor for Wide Video Lens
    }
    
    switch captureDevice.deviceType {
    case .builtInTripleCamera:
      return 2
      
    case .builtInDualWideCamera:
      return 2
      
    default:
      return 1
    }
  }
  
  func getTelephotoVideoZoomFactor() -> CGFloat {
    guard let captureDevice = captureDevice else {
      return 2 // default zoom factor for Telephoto Video Lens
    }
    
    switch captureDevice.deviceType {
    case .builtInTripleCamera:
      return 3
      
    case .builtInDualWideCamera:
      return 2
      
    default:
      return 2
    }
  }
  
  func setVideoZoomFactor() {
    let videoZoomFactor = getVideoZoomFactor()
    
    setVideoCaptureDeviceZoom(videoZoomFactor: videoZoomFactor)
  }
  
  func setTorchMode(to torchMode: AVCaptureDevice.TorchMode) -> Bool {
    guard let captureDevice = captureDevice else {
      return false
    }
    
    do {
      try captureDevice.lockForConfiguration()
    } catch {
      print("Failed to get lock configuration on capture device with error \(error)")
    }
    
    guard captureDevice.isTorchAvailable else {
      return false
    }
    
    captureDevice.torchMode = torchMode
    captureDevice.unlockForConfiguration()
    return true
  }
  
  func resetFocus() {
    let devicePoint = CGPoint(x: 0.5, y: 0.5)
    
    setFocus(focusMode: .continuousAutoFocus, exposureMode: .continuousAutoExposure, atPoint: devicePoint, shouldMonitorSubjectAreaChange: false)
  }
}
