//
//  CaptureViewController.swift
//  CustomCamera
//
//  Created by Aybars Acar on 16/6/2022.
//

import UIKit

final class CaptureViewController: UIViewController {
  
  @IBOutlet private weak var videoPreviewView: VideoPreviewView!
  @IBOutlet private weak var timerView: TimerView!
  @IBOutlet private weak var switchZoomView: SwitchZoomView!
  @IBOutlet private weak var toggleCameraView: ToggleCameraView!
  @IBOutlet private weak var recordView: RecordView!
  
  private var captureSessionManager: CaptureSessionManager!
  
  private var portraitConstraints = [NSLayoutConstraint]()
  private var landscapeConstraints = [NSLayoutConstraint]()
  
  private lazy var timerManager = TimerManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initialiseConstraints()
    
    setupToggleCameraView()
    
    setupCaptureSessionManager()
  }

  /// called when the size class changes in the application
  /// when we change the screen orientation
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    print(size)
    
    // to prevent animation when view orientation changes
    hideViewsBeforeOrientationChange()
    
    coordinator.animate { context in
      
    } completion: { [weak self] context in
      guard let self = self else { return }
    
      self.setupOrientationConstraint(size: size)
      self.showViewsAfterOrientationChange()
    }
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}

private extension CaptureViewController {
  
  // MARK: - Custom Constraints
  
  /// populates the array of constraints
  func initialiseConstraints() {
    
    // bottom centre align the button 30 CGFloat away from bottom
    portraitConstraints = [
      recordView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
      recordView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      
      switchZoomView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      switchZoomView.widthAnchor.constraint(equalToConstant: 180),
      switchZoomView.heightAnchor.constraint(equalToConstant: 80),
      switchZoomView.bottomAnchor.constraint(equalTo: recordView.topAnchor, constant: -30),
      
      toggleCameraView.centerYAnchor.constraint(equalTo: recordView.centerYAnchor),
      toggleCameraView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30)
    ]
    
    // aligned to the left centre
    landscapeConstraints = [
      recordView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
      recordView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      
      switchZoomView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      switchZoomView.widthAnchor.constraint(equalToConstant: 80),
      switchZoomView.heightAnchor.constraint(equalToConstant: 180),
      switchZoomView.trailingAnchor.constraint(equalTo: recordView.leadingAnchor, constant: -30),
      
      toggleCameraView.centerXAnchor.constraint(equalTo: recordView.centerXAnchor),
      toggleCameraView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30)
    ]
    
    let screenSize = UIScreen.main.bounds.size
    setupOrientationConstraint(size: screenSize)
  }
  
  func setupOrientationConstraint(size: CGSize) {
    
    if size.width > size.height {
      // landscape orientation so activate landscape constraints
      NSLayoutConstraint.deactivate(portraitConstraints)
      NSLayoutConstraint.activate(landscapeConstraints)
      
      switchZoomView.configureForLandscapeOrientation()
    }
    else {
      // we are in portrait orientation
      NSLayoutConstraint.deactivate(landscapeConstraints)
      NSLayoutConstraint.activate(portraitConstraints)
      
      switchZoomView.configureForPortraitOrientation()
    }
  }
  
  func setupTimer() {
    timerManager.setupTimer { [weak self] seconds in
      guard let self = self else { return }
      self.timerView.updateTime(seconds: seconds)
    }
  }
  
  func hideViewsBeforeOrientationChange() {
    recordView.alpha = 0
    switchZoomView.alpha = 0
  }
  
  func showViewsAfterOrientationChange() {
    
    let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
      self.recordView.alpha = 1
      self.switchZoomView.alpha = 1
    }
    
    animation.startAnimation()
  }
  
  func setupSwitchZoomView() {
    switchZoomView.delegate = self
    
    if let cameraTypes = captureSessionManager.getCameraTypes() {
      
      if cameraTypes.filter({ $0 == .ultrawide}).isEmpty {
        // ultrawide camera type does not exist so hide it
        switchZoomView.hideUltraWideButton()
      }
      
      if cameraTypes.filter({ $0 == .telephoto}).isEmpty {
        // telephoto camera type does not exist so hide it
        switchZoomView.hideTelephotoButton()
      }
      
      if cameraTypes == [.wide] {
        // we have only 1 camera so hide the switch zoom view all together
        switchZoomView.alpha = 0
      }
    }
  }
  
  func setupCaptureSessionManager() {
    captureSessionManager = CaptureSessionManager { [weak self] in
      guard let self = self else {
        return
      }
      
      self.videoPreviewView.videoPreviewLayer.session = self.captureSessionManager.getCaptureSession()

      self.setupSwitchZoomView()
    }
  }
  
  func setupToggleCameraView() {
    toggleCameraView.delegate = self
  }
}

extension CaptureViewController: SwitchZoomViewDelegate {
  
  func switchZoomTapped(state: ZoomState) {
    captureSessionManager.setZoomState(state)
  }
}

extension CaptureViewController: ToggleCameraViewDelegate {
  
  func toggleCameraTapped() {
    print("Toggle Camera TAPPED")
  }
}
