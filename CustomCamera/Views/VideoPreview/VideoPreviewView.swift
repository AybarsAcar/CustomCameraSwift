//
//  VideoPreviewView.swift
//  CustomCamera
//
//  Created by Aybars Acar on 16/6/2022.
//

import UIKit
import AVFoundation

final class VideoPreviewView: UIView {
  
  // set the CALayer
  override class var layerClass: AnyClass {
    return AVCaptureVideoPreviewLayer.self
  }
  
  var videoPreviewLayer: AVCaptureVideoPreviewLayer {
    return layer as! AVCaptureVideoPreviewLayer
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // set the frame
    videoPreviewLayer.frame = UIScreen.main.bounds
    
    videoPreviewLayer.videoGravity = .resizeAspect
  }
  
  

}
