//
//  CurrentSong.swift
//  PlaySync
//
//  Created by James Carroll on 7/17/15.
//  Copyright (c) 2015 James Carroll. All rights reserved.
//

import UIKit

final class CurrentSong: UIView {
  
  @IBOutlet weak var albumImg: UIImageView!
  @IBOutlet weak var songLbl: UILabel!
  @IBOutlet weak var artistLbl: UILabel!
  @IBOutlet weak var controlBtn: UIImageView!
  
  var delegate: UIViewController?
  
  var playImg: UIImage?
  var pauseImg: UIImage?
  var isPlaying: Bool?
  
  /*
  // Only override drawRect: if you perform custom drawing.
  // An empty implementation adversely affects performance during animation.
  override func drawRect(rect: CGRect) {
  // Drawing code
  }
  */
  
  override func layoutSubviews() {
    playImg = UIImage(named: "ic_play_arrow_48pt")
    pauseImg = UIImage(named: "ic_pause_48pt")
    
    controlBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleControlBtnTapped:"))
    self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleViewTapped:"))
  }
  
  func setControlBtnIcon(isPaused: Bool) {
    if isPaused {
      controlBtn.image = playImg
      isPlaying = false
    } else {
      controlBtn.image = pauseImg
      isPlaying = true
    }
  }
  
  private func handleControlBtnTapped(sender: UITapGestureRecognizer) {
    if let del = delegate as? MusicQueueViewController {
      if isPlaying == true {
        del.player.pause()
        del.multi.writeMessage(Controls.isToBePaused())
      } else {
        del.player.play()
        del.multi.writeMessage(Controls.isToBePlayed())
      }
    }
  }
  
  private func handleViewTapped(sender: UITapGestureRecognizer) {
    if let del = delegate as? MusicQueueViewController {
      del.performSegueWithIdentifier("toCurrentPlayingVC", sender: del)
    }
  }
}
