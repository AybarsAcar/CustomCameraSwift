//
//  CameraAuthorisationManager.swift
//  CustomCamera
//
//  Created by Aybars Acar on 13/6/2022.
//

import Foundation
import AVFoundation

enum CameraAuthorisationStatus {
  case granted, notRequested, unauthorised
}

typealias RequestCameraAuthorisationCompletionHandler = (_ status: CameraAuthorisationStatus) -> Void

final class CameraAuthorisationManager {
  static let shared = CameraAuthorisationManager()
  private init() { }
  
  func requestCameraAuthorisation(completion: @escaping RequestCameraAuthorisationCompletionHandler) {
    
    AVCaptureDevice.requestAccess(for: .video) { granted in
      DispatchQueue.main.async {
        guard granted  else {
          completion(.unauthorised)
          return
        }
        
        completion(.granted)
      }
      
      
    }
    
  }
  
  func getCameraAuthorisationStatus() -> CameraAuthorisationStatus {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    
    switch status {
    case .notDetermined:
      return .notRequested
    case .authorized:
      return .granted
    default:
      return .unauthorised
    }
  }
}
