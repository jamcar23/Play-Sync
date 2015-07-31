//
//  ControlNowPlaying.swift
//  PlaySync
//
//  Created by James Carroll on 7/25/15.
//  Copyright (c) 2015 James Carroll. All rights reserved.
//

import UIKit

final class ControlNowPlaying: UIView {
  
  @IBOutlet weak var skipPrevious: UIImageView!
  @IBOutlet weak var playPause: UIImageView!
  @IBOutlet weak var skipForward: UIImageView!
  
  var delegate: CurrentlyPlayingViewController!
  var isPlaying: Bool?
  
  /*
  // Only override drawRect: if you perform custom drawing.
  // An empty implementation adversely affects performance during animation.
  override func drawRect(rect: CGRect) {
  // Drawing code
  }
  */
  
  override func layoutSubviews() {
    self.skipPrevious.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handlePreviousTap:"))
    self.playPause.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handlePlayPauseTap:"))
    self.skipForward.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleForwardTap:"))
  }
  
  private func handlePreviousTap(sender: UITapGestureRecognizer) {
    if let del = delegate.delegate as? MusicQueueViewController {
      if del.playbackDevice == true {
        del.player.toPreviousItem()
      } else {
        del.multi.writeMessage(Controls.isToBeSkippedPrevious())
      }
    }
  }
  
  private  func handlePlayPauseTap(sender: UITapGestureRecognizer) {
    if let del = delegate.delegate as? MusicQueueViewController {
      if isPlaying == true {
        del.player.pause()
        del.multi.writeMessage(Controls.isToBePaused())
        isPlaying = false
      } else {
        del.player.play()
        del.multi.writeMessage(Controls.isToBePlayed())
        isPlaying = true 
      }
    }
  }
  
  private  func handleForwardTap(sender: UITapGestureRecognizer) {
    if let del = delegate.delegate as? MusicQueueViewController {
      if del.playbackDevice == true {
        del.player.toNextItem()
      } else {
        del.multi.writeMessage(Controls.isToBeSkippedForward())
      }
    }
  }
}
