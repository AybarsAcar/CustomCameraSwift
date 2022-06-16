//
//  LaunchViewController.swift
//  CustomCamera
//
//  Created by Aybars Acar on 13/6/2022.
//

import UIKit

final class LaunchViewController: UIViewController {
  
  private var requestCameraAuthorisationView: RequestCameraAuthorisationView?
  private var requestMicrophoneAuthorisationView: RequestMicrophoneAuthorisationView?
  private var requestPhotoLibraryAuthorisationView: RequestPhotoLibraryAuthorisationView?
  
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
  
  private var photoLibraryAuthorisationStatus = PhotoLibraryAuthorisationManager.shared.getPhotoLibraryAuthorisationStatus() {
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
    
    guard photoLibraryAuthorisationStatus == .granted else {
      setupRequestPhotoLibraryAuthorisationView()
      return
    }
    
    if requestPhotoLibraryAuthorisationView != nil {
      removeRequestPhotoLibraryAuthorisationView()
      return
    }
     
    DispatchQueue.main.async {
      AppSetup.shared.loadCaptureViewController()
    }
  }
  
  // MARK: - Camera Auth View
  
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
  
  func removeRequestCameraAuthorisationView() {
    
    requestCameraAuthorisationView?.animateOutViews { [weak self] in
      
      self?.requestCameraAuthorisationView?.removeFromSuperview()
      self?.requestCameraAuthorisationView = nil
      self?.setupViewForNextAuthorisationRequest()
    }
  }
  
  // MARK: - Microphone Auth View
  
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
  
  func removeRequestMicrophoneAuthorisationView() {
    
    requestMicrophoneAuthorisationView?.animateOutViews { [weak self] in
      
      self?.requestMicrophoneAuthorisationView?.removeFromSuperview()
      self?.requestMicrophoneAuthorisationView = nil
      self?.setupViewForNextAuthorisationRequest()
    }
  }
  
  // MARK: - Photo Library View
  
  func setupRequestPhotoLibraryAuthorisationView() {
    
    guard requestPhotoLibraryAuthorisationView == nil else {
      
      // if unauthorised set up the view
      if photoLibraryAuthorisationStatus == .unauthorised {
        requestPhotoLibraryAuthorisationView?.configureForErrorState()
      }
      
      return
    }
    
    // create an instance of the request
    let requestPhotoLibraryAuthorisationView = RequestPhotoLibraryAuthorisationView()
    
    requestPhotoLibraryAuthorisationView.delegate = self
    
    // to apply constraints
    requestPhotoLibraryAuthorisationView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(requestPhotoLibraryAuthorisationView)
    
    NSLayoutConstraint.activate([
      requestPhotoLibraryAuthorisationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      requestPhotoLibraryAuthorisationView.topAnchor.constraint(equalTo: view.topAnchor),
      requestPhotoLibraryAuthorisationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      requestPhotoLibraryAuthorisationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
    // animate the added view
    requestPhotoLibraryAuthorisationView.animateInViews()
    
    // if unauthorised set up the view that way
    if photoLibraryAuthorisationStatus == .unauthorised {
      requestPhotoLibraryAuthorisationView.configureForErrorState()
    }
    
    self.requestPhotoLibraryAuthorisationView = requestPhotoLibraryAuthorisationView
    
  }
  
  func removeRequestPhotoLibraryAuthorisationView() {
    
    requestPhotoLibraryAuthorisationView?.animateOutViews { [weak self] in
      
      self?.requestPhotoLibraryAuthorisationView?.removeFromSuperview()
      self?.requestPhotoLibraryAuthorisationView = nil
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

// MARK: - RequestPhotoLibraryAuthorisationViewDelegate
extension LaunchViewController: RequestPhotoLibraryAuthorisationViewDelegate {
  
  func requestPhotoLibraryTapped() {
    
    if photoLibraryAuthorisationStatus == .unauthorised {
      // open the device settings
      openSettings()
    }
    
    if photoLibraryAuthorisationStatus == .notRequested {
      PhotoLibraryAuthorisationManager.shared.requestPhotoLibraryAuthorisation { [weak self] status in
        
        guard let self = self else { return }
        
        self.photoLibraryAuthorisationStatus = status
        
      }
    }
  }
}
