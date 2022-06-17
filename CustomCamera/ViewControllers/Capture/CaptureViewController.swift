//
//  CaptureViewController.swift
//  CustomCamera
//
//  Created by Aybars Acar on 16/6/2022.
//

import UIKit

final class CaptureViewController: UIViewController {
  
  @IBOutlet private weak var videoPreviewView: VideoPreviewView!
  @IBOutlet private weak var recordView: RecordView!
  
  private lazy var captureSession = CaptureSessionManager()
  
  private var portraitConstraints = [NSLayoutConstraint]()
  private var landscapeConstraints = [NSLayoutConstraint]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    videoPreviewView.videoPreviewLayer.session = captureSession.getCaptureSession()
    
    initialiseConstraints()
    
  }
  
  /// called when the size class changes in the application
  /// when we change the screen orientation
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    print(size)
    
    setupOrientationConstraint(size: size)
  }
}

private extension CaptureViewController {
  
  /// populates the array of constraints
  func initialiseConstraints() {
    
    // bottom centre align the button 30 CGFloat away from bottom
    portraitConstraints = [
      recordView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
      recordView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ]
    
    // aligned to the left centre
    landscapeConstraints = [
      recordView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
      recordView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ]
    
    let screenSize = UIScreen.main.bounds.size
    setupOrientationConstraint(size: screenSize)
  }
  
  func setupOrientationConstraint(size: CGSize) {
    
    if size.width > size.height {
      // landscape orientation so activate landscape constraints
      NSLayoutConstraint.deactivate(portraitConstraints)
      NSLayoutConstraint.activate(landscapeConstraints)
    }
    else {
      // we are in portrait orientation
      NSLayoutConstraint.deactivate(landscapeConstraints)
      NSLayoutConstraint.activate(portraitConstraints)
    }
  }
}
