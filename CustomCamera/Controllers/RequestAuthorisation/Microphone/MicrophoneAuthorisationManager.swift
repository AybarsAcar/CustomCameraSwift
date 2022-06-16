//
//  MicrophoneAuthorisationManager.swift
//  CustomCamera
//
//  Created by Aybars Acar on 13/6/2022.
//

import Foundation
import AVFoundation

enum MicrophoneAuthorisationStatus {
  case granted, notRequested, unauthorised
}

typealias RequestMicrophoneAuthorisationCompletionHandler = (_ status: MicrophoneAuthorisationStatus) -> Void

final class MicrophoneAuthorisationManager {
  static let shared = MicrophoneAuthorisationManager()
  private init() { }
  
  func requestMicrophoneAuthorisation(completion: @escaping RequestMicrophoneAuthorisationCompletionHandler) {
    
    AVCaptureDevice.requestAccess(for: .audio) { granted in
      DispatchQueue.main.async {
        guard granted  else {
          completion(.unauthorised)
          return
        }
        
        completion(.granted)
      }
      
      
    }
    
  }
  
  func getMicrophoneAuthorisationStatus() -> MicrophoneAuthorisationStatus {
    let status = AVCaptureDevice.authorizationStatus(for: .audio)
    
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
