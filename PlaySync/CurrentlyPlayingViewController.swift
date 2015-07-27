//
//  CurrentlyPlayingViewController.swift
//  PlaySync
//
//  Created by James Carroll on 7/25/15.
//  Copyright (c) 2015 James Carroll. All rights reserved.
//

import UIKit

class CurrentlyPlayingViewController: UIViewController {
  
  @IBOutlet weak var nowPlaying: NowPlaying!
  @IBOutlet weak var albumImg: UIImageView!
  @IBOutlet weak var controlNowPlaying: ControlNowPlaying!
  
  var delegate: UIViewController!
  var currentSong: Song!
  var playPauseImg: UIImage!
  var isPlaying: Bool?
  let playImg = UIImage(named: "ic_play_arrow_48pt")
  let pauseImg = UIImage(named: "ic_pause_48pt")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    nowPlaying.delegate = self
    controlNowPlaying.delegate = self
    
    updateAllViews()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  private func setNowPlayingInfo() {
    nowPlaying.albumImg.image = currentSong.artwork
    nowPlaying.songLbl.text = currentSong.title
    nowPlaying.artistLbl.text = currentSong.artist
    nowPlaying.senderLbl.text = currentSong.sender
  }
  
  private func setControlNowPlay() {
    controlNowPlaying.playPause.image = self.playPauseImg
    controlNowPlaying.isPlaying = self.isPlaying
  }
  
  func setControlBtnIcon(isPaused: Bool) {
    if isPaused {
      playPauseImg = playImg
      isPlaying = false
    } else {
      playPauseImg = pauseImg
      isPlaying = true
    }
    
    setControlNowPlay()
  }
  
  func updateAllViews() {
    setNowPlayingInfo()
    self.albumImg.image = currentSong.artwork
    setControlNowPlay()
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
