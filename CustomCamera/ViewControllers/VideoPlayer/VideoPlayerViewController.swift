//
//  VideoPlayerViewController.swift
//  CustomCamera
//
//  Created by Aybars Acar on 26/6/2022.
//

import UIKit
import AVKit

protocol VideoPlayerViewControllerDelegate: AnyObject {
  func videoPlayerViewControllerDismissed(_ videoPlayerViewController: VideoPlayerViewController)
}

final class VideoPlayerViewController: AVPlayerViewController {

  weak var videoPlayerViewControllerDelegate: VideoPlayerViewControllerDelegate?
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    videoPlayerViewControllerDelegate?.videoPlayerViewControllerDismissed(self)
  }
}
