//
//  Controls.swift
//  PlaySync
//
//  Created by James Carroll on 7/17/15.
//  Copyright (c) 2015 James Carroll. All rights reserved.
//

import Foundation

class Controls {
  static let playbackDevice = "isPlaybackDevice"
  static let currentSong = "isCurrentSong"
  static let paused = "isToBePaused"
  static let played = "isToBePlayed"
  static let neededSong = "isNeededSong"
  static let skipForward = "isToBeSkippedForward"
  static let skipPrevious = "isToBeSkippedPrevious"
  
  class func isPlaybackDevice(device: String) -> String {
    return "\(device)::\(playbackDevice)"
  }
  
  class func isCurrentSong(song: String) -> String {
    return "\(song)::\(currentSong)"
  }
  
  class func isToBePaused() -> String {
    return "::\(paused)"
  }
  
  class func isToBePlayed() -> String {
    return "::\(played)"
  }
  
  class func isNeededSong(song: String) -> String {
    return "\(song)::\(neededSong)"
  }
  
  class func isToBeSkippedForward() -> String {
    return"::\(skipForward)"
  }
  
  class func isToBeSkippedPrevious() -> String {
    return "::\(skipPrevious)"
  }
}