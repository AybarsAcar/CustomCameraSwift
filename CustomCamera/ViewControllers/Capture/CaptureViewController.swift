//
//  CaptureViewController.swift
//  CustomCamera
//
//  Created by Aybars Acar on 16/6/2022.
//

import UIKit
import AVKit

final class CaptureViewController: UIViewController {
  
  @IBOutlet private weak var videoPreviewView: VideoPreviewView!
  @IBOutlet private weak var visualEffectView: UIVisualEffectView!
  @IBOutlet private weak var overlayView: UIView!
  @IBOutlet private weak var timerView: TimerView!
  @IBOutlet private weak var torchView: TorchView!
  @IBOutlet private weak var alertView: AlertView!
  @IBOutlet private weak var switchZoomView: SwitchZoomView!
  @IBOutlet private weak var toggleCameraView: ToggleCameraView!
  @IBOutlet private weak var recordView: RecordView!
  @IBOutlet private weak var pointOfInterestView: PointOfInterestView!
  
  private var captureSessionManager = CaptureSessionManager()
  
  private var portraitConstraints = [NSLayoutConstraint]()
  private var landscapeConstraints = [NSLayoutConstraint]()
  
  private lazy var timerManager = TimerManager()
  
  private var switchZoomViewWidthConstraint: NSLayoutConstraint?
  private var switchZoomViewHeightConstraint: NSLayoutConstraint?
  
  private var shouldHideSwitchZoomView = false
  
  private var hideAlertViewWorkItem: DispatchWorkItem?
  
  private var pointOfInterestHalfCompletedWorkItem: DispatchWorkItem?
  private var pointOfInterestCompletedWorkItem: DispatchWorkItem?
  
  private var movieOutputFileURL: URL?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupRecordView()
    
    setupTorchView()
    
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
    guard let tapView = tapGestureRecognizer.view else { return }
    
    let tapLocation = tapGestureRecognizer.location(in: tapView)
    
    let newLocation = tapView.convert(tapLocation, to: view)
    showPointOfInterestView(atPoint: newLocation)
    
    let devicePoint = videoPreviewView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: tapLocation)
    
    captureSessionManager.setFocus(focusMode: .autoFocus, exposureMode: .autoExpose, atPoint: devicePoint, shouldMonitorSubjectAreaChange: true)
  }
  
  /// tells whether the view should auto rotate
  override var shouldAutorotate: Bool {
    return !captureSessionManager.isRecording
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
    hidePointOfInterestView()
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
    captureSessionManager.delegate = self
    
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
  
  func showAndHideAlertView(text: String) {
    showAlertView(text: text)
    
    let hideAlertViewWorkItem = DispatchWorkItem { [weak self] in
      guard let self = self else { return }
      
      self.hideAlertView()
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: hideAlertViewWorkItem)
    self.hideAlertViewWorkItem = hideAlertViewWorkItem
  }
  
  func showAlertView(text: String) {
    hideAlertViewWorkItem?.cancel()
    hideAlertViewWorkItem = nil
    
    // initially it is hidden
    alertView.alpha = 0
    alertView.setAlertText(text)
    
    // describe a slide in transform
    alertView.transform = CGAffineTransform(translationX: 0, y: 30)
    
    // animate the view in
    let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
      self.alertView.transform = .identity
      self.alertView.alpha = 1
    }
    
    animation.startAnimation()
  }
  
  func hideAlertView() {
    let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
      self.alertView.transform = CGAffineTransform(translationX: 0, y: 30)
      self.alertView.alpha = 0
    }
    
    animation.startAnimation()
  }
  
  func setupTorchView() {
    torchView.delegate = self
  }
  
  func showPointOfInterestView(atPoint point: CGPoint) {
    // cancel any scheduled work
    pointOfInterestHalfCompletedWorkItem = nil
    pointOfInterestCompletedWorkItem = nil
    
    pointOfInterestView.center = point
    pointOfInterestView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    
    let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
      self.pointOfInterestView.transform = .identity
      self.pointOfInterestView.alpha = 1
    }
    
    animation.startAnimation()
    
    let pointOfInterestHalfCompletedWorkItem = DispatchWorkItem { [weak self] in
      guard let self = self else { return }
      
      let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
        self.pointOfInterestView.alpha = 0.5
      }
      animation.startAnimation()
    }
    
    let pointOfInterestCompletedWorkItem = DispatchWorkItem { [weak self] in
      guard let self = self else { return }
      
      let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
        self.pointOfInterestView.alpha = 0
      }
      animation.startAnimation()
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: pointOfInterestHalfCompletedWorkItem)
    DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: pointOfInterestCompletedWorkItem)
    
    // keep a reference before exit
    self.pointOfInterestHalfCompletedWorkItem = pointOfInterestHalfCompletedWorkItem
    self.pointOfInterestCompletedWorkItem = pointOfInterestCompletedWorkItem
  }
  
  func hidePointOfInterestView() {
    pointOfInterestHalfCompletedWorkItem?.cancel()
    pointOfInterestCompletedWorkItem?.cancel()
    pointOfInterestHalfCompletedWorkItem = nil
    pointOfInterestCompletedWorkItem = nil
    
    pointOfInterestView.alpha = 0
  }
  
  func showTimerView() {
    timerView.isHidden = false
  }
  
  func hideTimerView() {
    timerView.isHidden = true
  }
  
  func resetTimer() {
    timerManager.resetTimer()
  }
  
  func setupRecordView() {
    recordView.delegate = self
  }
}

extension CaptureViewController: RecordViewDelegate {
  
  func recordViewStartRecording(_ recordView: RecordView) {
    showTimerView()
    setupTimer()
    captureSessionManager.startRecording()
  }
  
  func recordViewEndRecording(_ recordView: RecordView) {
    hideTimerView()
    resetTimer()
    captureSessionManager.stopRecording()
  }
  
}

extension CaptureViewController: TorchViewDelegate {

  func torchTapped(torchMode: TorchMode, completion: (Bool) -> Void) {
    switch torchMode {
    case .off:
      let result = captureSessionManager.turnOnTorch()
      
      if !result {
        showAlertView(text: "Could not turn on torch")
      }
      
      completion(result)
      
    case .on:
      let result = captureSessionManager.turnOffTorch()
      
      if !result {
        showAlertView(text: "Could not turn off torch")
      }
      
      completion(result)
    }
  }
}

extension CaptureViewController: SwitchZoomViewDelegate {
  
  func switchZoomTapped(state: ZoomState) {
    hidePointOfInterestView()
    captureSessionManager.setZoomState(state)
  }
}

extension CaptureViewController: ToggleCameraViewDelegate {
  
  func toggleCameraTapped() {
    
    hidePointOfInterestView()
    
    captureSessionManager.toggleCamera { [weak self] cameraPosition in
      
      guard let self = self else { return }
      
      switch cameraPosition {
      case .back:
        if !self.shouldHideSwitchZoomView {
          self.switchZoomView.isHidden = false
        }
        self.torchView.isHidden = false
        
      case .front:
        self.switchZoomView.isHidden = true
        self.torchView.isHidden = true
      }
    }
  }
}

extension CaptureViewController: CaptureSessionManagerDelegate {
  
  func captureSessionManagerDidFinishRecording(_ captureSessionManager: CaptureSessionManager, outputFileURL: URL) {
    
    movieOutputFileURL = outputFileURL
    
    let player = AVPlayer(url: outputFileURL)
    
    let videoPlayerVC = VideoPlayerViewController()
    videoPlayerVC.player = player
    videoPlayerVC.videoPlayerViewControllerDelegate = self
    
    present(videoPlayerVC, animated: true) {
      player.play()
    }
  }
  
  func captureSessionManagerFailedFinishingRecording(_ captureSessionManager: CaptureSessionManager) {
    print("Failed to finish recording")
  }
}

extension CaptureViewController: VideoPlayerViewControllerDelegate {
  
  func videoPlayerViewControllerDismissed(_ videoPlayerViewController: VideoPlayerViewController) {
    guard let movieOutputFileURL = movieOutputFileURL else {
      return
    }
    
    captureSessionManager.cleanUp(movieOutputFileURL)
  }
}
