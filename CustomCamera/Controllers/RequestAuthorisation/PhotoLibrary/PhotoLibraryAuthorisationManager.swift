//
//  PhotoLibraryAuthorisationManager.swift
//  CustomCamera
//
//  Created by Aybars Acar on 16/6/2022.
//

import Foundation
import Photos

enum PhotoLibraryAuthorisationStatus {
  case granted, notRequested, unauthorised
}

typealias RequestPhotoLibraryAuthorisationCompletionHandler = (_ status: PhotoLibraryAuthorisationStatus) -> Void

final class PhotoLibraryAuthorisationManager {
  static let shared = PhotoLibraryAuthorisationManager()
  private init() { }
  
  func requestPhotoLibraryAuthorisation(completion: @escaping RequestPhotoLibraryAuthorisationCompletionHandler) {
    
    PHPhotoLibrary.requestAuthorization { status in
      
      DispatchQueue.main.async {
        guard status == .authorized else {
          completion(.unauthorised)
          return
        }
        
        completion(.granted)
      }
    }
    
  }
  
  func getPhotoLibraryAuthorisationStatus() -> PhotoLibraryAuthorisationStatus {
    let status = PHPhotoLibrary.authorizationStatus()
    
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
