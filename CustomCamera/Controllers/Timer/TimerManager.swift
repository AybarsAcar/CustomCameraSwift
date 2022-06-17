//
//  TimerManager.swift
//  CustomCamera
//
//  Created by Aybars Acar on 17/6/2022.
//

import Foundation

final class TimerManager {
  
  private var timer: Timer?
  private var seconds: Int64 = 0
  
  func setupTimer(timerUpdateHandler: @escaping (_ seconds: Int64) -> Void) {
    
    let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
      guard let self = self else { return }
      
      // update the seconds and notify the setup timer
      self.seconds += 1
      timerUpdateHandler(self.seconds)
    }
    
    self.timer = timer
  }
  
  func resetTimer() {
    timer?.invalidate()
    timer = nil
    seconds = 0
  }
}
