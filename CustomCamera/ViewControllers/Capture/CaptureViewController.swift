//
//  CaptureViewController.swift
//  CustomCamera
//
//  Created by Aybars Acar on 16/6/2022.
//

import UIKit

final class CaptureViewController: UIViewController {
  
  @IBOutlet private weak var videoPreviewView: VideoPreviewView!
  @IBOutlet private weak var visualEffectView: UIVisualEffectView!
  @IBOutlet private weak var overlayView: UIView!
  @IBOutlet private weak var timerView: TimerView!
  @IBOutlet private weak var switchZoomView: SwitchZoomView!
  @IBOutlet private weak var toggleCameraView: ToggleCameraView!
  @IBOutlet private weak var recordView: RecordView!
  
  private var captureSessionManager = CaptureSessionManager()
  
  private var portraitConstraints = [NSLayoutConstraint]()
  private var landscapeConstraints = [NSLayoutConstraint]()
  
  private lazy var timerManager = TimerManager()
  
  private var switchZoomViewWidthConstraint: NSLayoutConstraint?
  private var switchZoomViewHeightConstraint: NSLayoutConstraint?
  
  private var shouldHideSwitchZoomView = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupVisualEffectView()
    
    setupToggleCameraView()
    
    setupCaptureSessionManager()
    
    registerForApplicationStateNotifications()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    initialiseConstraints()
    
    showInitialViews()
  }
  
  /// called when the size class changes in the application
  /// when we change the screen orientation
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    print(size)
    
    // to prevent animation when view orientation changes
    hideViewsBeforeOrientationChange()
    
    coordinator.animate { [weak self] context in
      guard let self = self else { return }
      
      self.setupVideoOrientation()
      
    } completion: { [weak self] context in
      guard let self = self else { return }
      
      self.setupOrientationConstraint(size: size)
      self.showViewsAfterOrientationChange()
    }
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: .ApplicationDidBecomeActive, object: nil)
    NotificationCenter.default.removeObserver(self, name: .ApplicationWillResignActive, object: nil)
  }
  
  @IBAction func overlayViewTapHandler(tapGestureRecognizer: UITapGestureRecognizer) {
    
    // give us the tapped area
    // get tap location and send it as the focus point
    let tapView = tapGestureRecognizer.view
    
    let tapLocation = tapGestureRecognizer.location(in: tapView)
    
    let devicePoint = videoPreviewView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: tapLocation)
    
    captureSessionManager.setFocus(focusMode: .autoFocus, exposureMode: .autoExpose, atPoint: devicePoint, shouldMonitorSubjectAreaChange: true)
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
      switchZoomView.trailingAnchor.constraint(equalTo: recordView.leadingAnchor, constant: -30),
      
      toggleCameraView.centerXAnchor.constraint(equalTo: recordView.centerXAnchor),
      toggleCameraView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30)
    ]
    
    let switchZoomViewWidthConstraint = switchZoomView.widthAnchor.constraint(equalToConstant: 180)
    portraitConstraints.append(switchZoomViewWidthConstraint)
    self.switchZoomViewWidthConstraint = switchZoomViewWidthConstraint
    
    let switchZoomViewHeightConstraint = switchZoomView.heightAnchor.constraint(equalToConstant: 180)
    landscapeConstraints.append(switchZoomViewWidthConstraint)
    self.switchZoomViewHeightConstraint = switchZoomViewHeightConstraint
    
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
        reduceSwitchZoomViewSize()
      }
      
      if cameraTypes.filter({ $0 == .telephoto}).isEmpty {
        // telephoto camera type does not exist so hide it
        switchZoomView.hideTelephotoButton()
        reduceSwitchZoomViewSize()
      }
      
      if cameraTypes == [.wide] {
        // we have only 1 camera so hide the switch zoom view all together
        switchZoomView.isHidden = true
        
        shouldHideSwitchZoomView = true
      }
    }
  }
  
  func setupCaptureSessionManager() {
    captureSessionManager.initialiseCaptureSession { [weak self] in
      guard let self = self else {
        return
      }
      
      self.videoPreviewView.videoPreviewLayer.session = self.captureSessionManager.getCaptureSession()
      
      self.setupVideoOrientation()
      
      self.setupToggleCameraView()
      
      self.setupSwitchZoomView()
    }
  }
  
  func setupToggleCameraView() {
    toggleCameraView.delegate = self
  }
  
  func setupVisualEffectView() {
    // no effect
    visualEffectView.effect = nil
  }
  
  func registerForApplicationStateNotifications() {
    NotificationCenter.default.addObserver(forName: .ApplicationDidBecomeActive, object: nil, queue: .main) { [weak self] notification in
      guard let self = self else { return }
      
      UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
        self.visualEffectView.effect = nil
      } completion: { _ in
      }
      
      self.captureSessionManager.startRunning()
    }
    
    NotificationCenter.default.addObserver(forName: .ApplicationWillResignActive, object: nil, queue: .main) { [weak self] notification in
      guard let self = self else { return }
      
      UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
        self.visualEffectView.effect = UIBlurEffect(style: .dark)
      } completion: { _ in
      }
      
      self.captureSessionManager.stopRunning()
    }
  }
  
  func setupVideoOrientation() {
    guard let interfaceOrientation = AppSetup.shared.interfaceOrientation,
          let videoOrientation = VideoOrientationManager.shared.getVideoOrientation(from: interfaceOrientation) else {
      return
    }
    
    // assign the video orientation
    videoPreviewView.videoPreviewLayer.connection?.videoOrientation = videoOrientation
  }
  
  func reduceSwitchZoomViewSize() {
    let delta: CGFloat = 50
    
    switchZoomViewWidthConstraint?.constant -= delta
    switchZoomViewHeightConstraint?.constant -= delta
  }
  
  /// so when we launch the app from the landscape mode it will be setup
  /// according to the landscape view
  func showInitialViews() {
    recordView.isHidden = false
    switchZoomView.isHidden = shouldHideSwitchZoomView
    toggleCameraView.isHidden = false
  }
}

extension CaptureViewController: SwitchZoomViewDelegate {
  
  func switchZoomTapped(state: ZoomState) {
    captureSessionManager.setZoomState(state)
  }
}

extension CaptureViewController: ToggleCameraViewDelegate {
  
  func toggleCameraTapped() {
    captureSessionManager.toggleCamera { [weak self] cameraPosition in
      
      guard let self = self else { return }
      
      switch cameraPosition {
      case .back:
        if !self.shouldHideSwitchZoomView {
          self.switchZoomView.isHidden = false
        }
        
      case .front:
        self.switchZoomView.isHidden = true
      }
    }
  }
}

