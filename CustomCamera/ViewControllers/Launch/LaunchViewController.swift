//
//  LaunchViewController.swift
//  CustomCamera
//
//  Created by Aybars Acar on 13/6/2022.
//

import UIKit

class LaunchViewController: UIViewController {
  
  private var requestCameraAuthorisationView: RequestCameraAuthorisationView?
  private var requestMicrophoneAuthorisationView: RequestMicrophoneAuthorisationView?
  
  private var cameraAuthorisationStatus = CameraAuthorisationManager.shared.getCameraAuthorisationStatus() {
    didSet {
      setupViewForNextAuthorisationRequest()
    }
  }
  
  private var microphoneAuthorisationStatus = MicrophoneAuthorisationManager.shared.getMicrophoneAuthorisationStatus() {
    didSet {
      setupViewForNextAuthorisationRequest()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViewForNextAuthorisationRequest()
    
  }
  
}

// MARK: - Private Setup
private extension LaunchViewController {
  
  func setupViewForNextAuthorisationRequest() {
    
    guard cameraAuthorisationStatus == .granted else {
      setupRequestCameraAuthorisationView()
      return
    }
    
    if requestCameraAuthorisationView != nil {
      removeRequestCameraAuthorisationView()
      return
    }
    
    guard microphoneAuthorisationStatus == .granted else {
      setupRequestMicrophoneAuthorisationView()
      return
    }
    
    if requestMicrophoneAuthorisationView != nil {
      removeRequestMicrophoneAuthorisationView()
      return
    }
    
    print("Request Photo Library Authorisation")
    
  }
  
  func setupRequestCameraAuthorisationView() {
    
    guard requestCameraAuthorisationView == nil else {
      
      // if unauthorised set up the view
      if cameraAuthorisationStatus == .unauthorised {
        requestCameraAuthorisationView?.configureForErrorState()
      }
      
      return
    }
    
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
    
    // animate the added view
    requestCameraAuthorisationView.animateInViews()
    
    // if unauthorised set up the view that way
    if cameraAuthorisationStatus == .unauthorised {
      requestCameraAuthorisationView.configureForErrorState()
    }
    
    self.requestCameraAuthorisationView = requestCameraAuthorisationView
    
  }
  
  func setupRequestMicrophoneAuthorisationView() {
    
    guard requestCameraAuthorisationView == nil else {
      
      // if unauthorised set up the view
      if microphoneAuthorisationStatus == .unauthorised {
        requestMicrophoneAuthorisationView?.configureForErrorState()
      }
      
      return
    }
    
    // create an instance of the request
    let requestMicrophoneAuthorisationView = RequestMicrophoneAuthorisationView()
    
    requestMicrophoneAuthorisationView.delegate = self
    
    // to apply constraints
    requestMicrophoneAuthorisationView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(requestMicrophoneAuthorisationView)
    
    NSLayoutConstraint.activate([
      requestMicrophoneAuthorisationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      requestMicrophoneAuthorisationView.topAnchor.constraint(equalTo: view.topAnchor),
      requestMicrophoneAuthorisationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      requestMicrophoneAuthorisationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
    // animate the added view
    requestMicrophoneAuthorisationView.animateInViews()
    
    // if unauthorised set up the view that way
    if cameraAuthorisationStatus == .unauthorised {
      requestMicrophoneAuthorisationView.configureForErrorState()
    }
    
    self.requestMicrophoneAuthorisationView = requestMicrophoneAuthorisationView
    
  }
  
  func removeRequestCameraAuthorisationView() {
    
    requestCameraAuthorisationView?.animateOutViews { [weak self] in
      
      self?.requestCameraAuthorisationView?.removeFromSuperview()
      self?.requestCameraAuthorisationView = nil
      self?.setupViewForNextAuthorisationRequest()
    }
  }
  
  func removeRequestMicrophoneAuthorisationView() {
    
    requestMicrophoneAuthorisationView?.animateOutViews { [weak self] in
      
      self?.requestMicrophoneAuthorisationView?.removeFromSuperview()
      self?.requestMicrophoneAuthorisationView = nil
      self?.setupViewForNextAuthorisationRequest()
    }
  }
  
  private func openSettings() {
    let settingsURLString = UIApplication.openSettingsURLString
    
    if let settingsURL = URL(string: settingsURLString) {
      UIApplication.shared.open(settingsURL)
    }
  }
}

// MARK: - RequestCameraAuthorisationViewDelegate
extension LaunchViewController: RequestCameraAuthorisationViewDelegate {
  
  func requestCameraAuthorisationTapped() {
    
    if cameraAuthorisationStatus == .unauthorised {
      // open the device settings
      openSettings()
    }
    
    if cameraAuthorisationStatus == .notRequested {
      CameraAuthorisationManager.shared.requestCameraAuthorisation { [weak self] status in
        
        guard let self = self else { return }
        
        self.cameraAuthorisationStatus = status
        
      }
    }
  }
}

// MARK: - RequestMicrophoneAuthrosationViewDelegate
extension LaunchViewController: RequestMicrophoneAuthorisationViewDelegate {
  
  func requestMicrophoneAuthorisationTapped() {
    
    if microphoneAuthorisationStatus == .unauthorised {
      // open the device settings
      openSettings()
    }
    
    if microphoneAuthorisationStatus == .notRequested {
      MicrophoneAuthorisationManager.shared.requestMicrophoneAuthorisation { [weak self] status in
        
        guard let self = self else { return }
        
        self.microphoneAuthorisationStatus = status
        
      }
    }
  }
}
