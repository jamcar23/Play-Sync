//
//  MusicPlayer.swift
//  PlaySync
//
//  Created by James Carroll on 7/20/15.
//  Copyright (c) 2015 James Carroll. All rights reserved.
//

import UIKit
import MediaPlayer

class MusicPlayer {
  let playerController: MPMusicPlayerController?
  var delegate: UIViewController?
  
  init() {
    playerController = MPMusicPlayerController.systemMusicPlayer()
  }
  
  init(isPlaybackDevice: Bool) { 
    playerController = isPlaybackDevice ? MPMusicPlayerController.systemMusicPlayer() : nil
  }
  
  func setQueue(queue: MPMediaItemCollection) {
    if let player = playerController {
      player.setQueueWithItemCollection(queue)
    }
  }
  
  func play() {
    if let player = playerController {
      player.play()
    }
  }
  
  func pause() {
    if let player = playerController {
      player.pause()
    }
  }
  
  func toNextItem() {
    if let player = playerController {
      player.skipToNextItem()
    }
  }
  
  func toBeginning() {
    if let player = playerController {
      player.skipToBeginning()
    }
  }
  
  func toPreviousItem() {
    if let player = playerController {
      player.skipToPreviousItem()
    }
  }
  
  func playBackState() -> MPMusicPlaybackState {
    return playerController?.playbackState ?? .Stopped
  }
}