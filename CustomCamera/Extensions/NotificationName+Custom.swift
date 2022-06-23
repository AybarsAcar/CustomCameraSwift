//
//  NotificationName+Custom.swift
//  CustomCamera
//
//  Created by Aybars Acar on 23/6/2022.
//

import Foundation

extension Notification.Name {
  
  static var ApplicationDidBecomeActive = Notification.Name(rawValue: "ApplicationDidBecomeActive")
  
  static var ApplicationWillResignActive = Notification.Name(rawValue: "ApplicationWillResignActive")
}
