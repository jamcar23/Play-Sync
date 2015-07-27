//
//  NowPlaying.swift
//  PlaySync
//
//  Created by James Carroll on 7/25/15.
//  Copyright (c) 2015 James Carroll. All rights reserved.
//

import UIKit

class NowPlaying: UIView {
  
  @IBOutlet weak var albumImg: UIImageView!
  @IBOutlet weak var songLbl: UILabel!
  @IBOutlet weak var artistLbl: UILabel!
  @IBOutlet weak var senderLbl: UILabel!
  
  var delegate: CurrentlyPlayingViewController!
  
  /*
  // Only override drawRect: if you perform custom drawing.
  // An empty implementation adversely affects performance during animation.
  override func drawRect(rect: CGRect) {
  // Drawing code
  }
  */
  
  override func layoutSubviews() {
    self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleViewTapped:"))
  }
  
  func handleViewTapped(sender: UITapGestureRecognizer) {
    if let del = delegate.delegate as? MusicQueueViewController {
      del.currentPlayingVC = nil 
    }
    
    delegate.dismissViewControllerAnimated(true
      , completion: nil)
  }
}
