//
//  CameraAuthorisationManager.swift
//  CustomCamera
//
//  Created by Aybars Acar on 13/6/2022.
//

import Foundation
import AVFoundation

enum CamearAuthorisationStatus {
  case granted, notRequested, unauthorised
}

typealias RequestCameraAuthorisationCompletionHandler = (CamearAuthorisationStatus) -> Void

final class CameraAuthorisationManager {
  static let shared = CameraAuthorisationManager()
  
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
  
  func getCameraAuthorisationStatus() -> CamearAuthorisationStatus {
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
