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
  
  class func isPlaybackDevice(device: String) -> String {
    return "\(device)::\(playbackDevice)"
  }
  
  class func isCurrentSong(song: String) -> String {
    return "\(song)::\(currentSong)"
  }
}