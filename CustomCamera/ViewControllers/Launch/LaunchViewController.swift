//
//  LaunchViewController.swift
//  CustomCamera
//
//  Created by Aybars Acar on 13/6/2022.
//

import UIKit

class LaunchViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViews()
    
  }
  
}

// MARK: - Private Setup
private extension LaunchViewController {
  
  func setupViews() {
    
    // create an instance of the request
    let requestCameraAuthorisationView = RequestCameraAuthorisationView()
    requestCameraAuthorisationView.delegate = self
    
    // to apply constraints
    requestCameraAuthorisationView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(requestCameraAuthorisationView)
    
    NSLayoutConstraint.activate([
      requestCameraAuthorisationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      requestCameraAuthorisationView.topAnchor.constraint(equalTo: view.topAnchor),
      requestCameraAuthorisationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      requestCameraAuthorisationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
  }
}

// MARK: - RequestCameraAuthorisationViewDelegate
extension LaunchViewController: RequestCameraAuthorisationViewDelegate {
  func requestCameraAuthorisationTapped() {
    
    CameraAuthorisationManager.shared.requestCameraAuthorisation { status in
      switch status {
      case .granted:
        print("Granted")
      case .notRequested:
        print("Not Requested")
      case .unauthorised:
        print("Unauthorised")
      }
    }
  }
}
