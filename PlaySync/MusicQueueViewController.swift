//
//  MultipeerViewController.swift
//  PlaySync
//
//  Created by James Carroll on 7/13/15.
//  Copyright (c) 2015 James Carroll. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import MediaPlayer
import AVFoundation
import AudioToolbox

let songCellId = "songCell"

class MusicQueueViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate, MPMediaPickerControllerDelegate, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var currentlyPlaying: CurrentSong!
  
  var playbackDevice: Bool!
  var songs = [Song]()
  var currentSong: Song?
  
  var multi: Multipeer!
  var player: MusicPlayer!
  var notiCenter: NSNotificationCenter!
  var currentPlayingVC: CurrentlyPlayingViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    multi = Multipeer(delegate: self)
    multi.playbackDevice = self.playbackDevice
    multi.openViewController()
    
    tableView.tableFooterView = UIView(frame: CGRectZero)
    tableView.backgroundColor = UIColor.clearColor()
    
    currentSong = nil
    
    if currentSong == nil {
      currentlyPlaying.hidden = true
    }
    
    currentlyPlaying.delegate = self
    
    player = MusicPlayer(isPlaybackDevice: playbackDevice)
    
    if playbackDevice == true {
      notiCenter = NSNotificationCenter.defaultCenter()
      notiCenter.addObserver(self, selector: "handleNowPlayingItemChanged:", name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: player.playerController)
      notiCenter.addObserver(self, selector: "handlePlaybackStateChange:", name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: player.playerController)
      
      player.playerController!.playbackState == .Stopped
      player.playerController!.beginGeneratingPlaybackNotifications()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - class methods
  
  func updateCurrentlyPlaying() {
    if let song = currentSong {
      currentlyPlaying.albumImg.layer.backgroundColor = UIColor.blackColor().CGColor
      currentlyPlaying.albumImg.image = song.artwork
      currentlyPlaying.songLbl.text = song.title
      currentlyPlaying.artistLbl.text = song.artist
      currentlyPlaying.hidden = false
      
      
      if playbackDevice == true {
        if song.sender == multi.peerId.displayName {
          player.playerController?.nowPlayingItem = song.selfToMPMediaItem()
          player.play()
        } else {
          multi.writeMessageToPeer(Controls.isNeededSong(song.selfToString()), peerName: song.sender)
        }
      }
      
      if let cpVC = currentPlayingVC {
        if self.currentSong! !== cpVC.currentSong {
          cpVC.currentSong = self.currentSong!
          cpVC.updateAllViews()
        }
        
      }
    }
  }
  
  func handleNowPlayingItemChanged(notification: NSNotification) {
    if let nowPlaying = player.playerController?.nowPlayingItem {
      currentSong = Song.returnSongObject(song: nowPlaying)
      updateCurrentlyPlaying()
      multi.writeMessage(Controls.isCurrentSong(currentSong!.selfToString()))
    }
  }
  
  func handlePlaybackStateChange(notification: NSNotification) {
    handleControlButton()
  }
  
  func handleControlButton() {
    if player.playBackState() == .Stopped || player.playBackState() == .Paused {
      currentlyPlaying.setControlBtnIcon(true)
      multi.writeMessage(Controls.isToBePaused())
    } else {
      currentlyPlaying.setControlBtnIcon(false)
      multi.writeMessage(Controls.isToBePlayed())
    }
    
    if let cpVC = currentPlayingVC {
      cpVC.playPauseImg = currentlyPlaying.controlBtn.image
      cpVC.updateAllViews()
    }
  }
  
  // MARK: - UITableViewDataSource
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return songs.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var c = tableView.dequeueReusableCellWithIdentifier(songCellId) as! SongTableViewCell
    let song = songs[indexPath.row]
    c.albumImg?.image = song.artwork
    c.songLbl.text = song.title
    c.artistLbl.text = song.artist
    c.durationLbl.text = song.secToMin()
    
    return c
  }
  
  // MARK: - UITableViewDelegate
  
  func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 55.0
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 55.0
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    currentSong = songs[indexPath.row]
    updateCurrentlyPlaying()
    multi.writeMessage(Controls.isCurrentSong(currentSong?.selfToString() ?? ""))
    
    
  }
  
  // MARK: - MCBrowserViewControllerDelegate
  
  // Notifies the delegate, when the user taps the done button
  func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  // Notifies delegate that the user taps the cancel button.
  func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - McSessionDelegate
  
  // Remote peer changed state
  func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
    if state == .Connected {
      if playbackDevice == true {
        multi.writeMessage(Controls.isPlaybackDevice(multi.peerId.displayName))
      }
      
      if songs.count > 0 {
        for s in songs {
          multi.writeData(s.selfToNSData())
        }
      }
      
      if let song = currentSong {
        multi.writeMessage(Controls.isCurrentSong(song.selfToString() ?? ""))
      }
    }
  }
  
  // Received data from remote peer
  func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
    let message = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
    
    if let message = message {
      if message != "" {
        let splitString = message.componentsSeparatedByString("::")
        
        switch splitString[1] {
        case Controls.playbackDevice:
          multi.setSelfPlaybackPeer(splitString[0])
        case Controls.currentSong:
          let d = NSData(base64EncodedString: splitString[0], options: .IgnoreUnknownCharacters)
          currentSong = multi.dataToSong(d ?? NSData())
          dispatch_async(dispatch_get_main_queue(), {
            self.updateCurrentlyPlaying()
          })
        case Controls.paused:
          dispatch_async(dispatch_get_main_queue(), {
            self.currentlyPlaying.setControlBtnIcon(true)
            self.currentPlayingVC?.setControlBtnIcon(true)
            
            if self.playbackDevice == true {
              self.player.pause()
            }
          })
        case Controls.played:
          dispatch_async(dispatch_get_main_queue(), {
            self.currentlyPlaying.setControlBtnIcon(false)
            self.currentPlayingVC?.setControlBtnIcon(false)
            
            if self.playbackDevice == true {
              self.player.play()
            }
          })
        case Controls.neededSong:
          dispatch_async(dispatch_get_main_queue(), {
            self.multi.startStreamWithPlaybackPeer()
            self.multi.writeSongToStream(self.currentSong!)
          })
        case Controls.skipForward:
          if playbackDevice == true {
            dispatch_async(dispatch_get_main_queue(), {
              self.player.toNextItem()
            })
          }
        case Controls.skipPrevious:
          if playbackDevice == true {
            dispatch_async(dispatch_get_main_queue(), {
              self.player.toPreviousItem()
            })
          }
        default:
          break
        }
      }
    } else {
      let songObj = multi.dataToSong(data)
      
      if let songObj = songObj {
        songs.append(songObj)
        dispatch_async(dispatch_get_main_queue(), {
          self.tableView.reloadData()
        })
      }
    }
  }
  
  // Received a byte stream from remote peer
  func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
    if playbackDevice == true {
      stream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
      stream.open()
    }
  }
  
  // Start receiving a resource from remote peer
  func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
    if playbackDevice == true {
      
    }
  }
  
  // Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
  func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
    
  }
  
  // MARK: - MPMediaPickerControllerDelegate
  
  func mediaPickerDidCancel(mediaPicker: MPMediaPickerController!) {
    
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func mediaPicker(mediaPicker: MPMediaPickerController!, didPickMediaItems mediaItemCollection: MPMediaItemCollection!) {
    //    var asset: AVURLAsset!
    //    var assestReader: AVAssetReader!
    //    var err: NSError?
    var songObj: Song!
    
    for s in (mediaItemCollection.items as! [MPMediaItem]) {
      songObj = Song.returnSongObject(song: s)
      songs.append(songObj)
      multi.writeData(songObj.selfToNSData())
      
      //      asset = AVURLAsset(URL: songObj.url, options: nil)
      //      assestReader = AVAssetReader(asset: asset, error: &err)
    }
    tableView.reloadData()
    
    player.setQueue(MPMediaItemCollection(items: Song.returnArrayOfMPMediaItem(songs)))
    currentSong = songs[0]
    multi.writeMessage(Controls.isCurrentSong(currentSong?.selfToString() ?? ""))
    handleControlButton()
    updateCurrentlyPlaying()
    
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - Navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    currentPlayingVC = segue.destinationViewController as? CurrentlyPlayingViewController
    
    currentPlayingVC?.delegate = self
    currentPlayingVC?.currentSong = self.currentSong!
    currentPlayingVC?.playPauseImg = currentlyPlaying.controlBtn.image
    currentPlayingVC?.isPlaying = currentlyPlaying.isPlaying

  }
  
  // MARK: - IBActions
  
  @IBAction func addMusicBtnPressed(sender: AnyObject) {
    let mediaPicker = MPMediaPickerController(mediaTypes: .Music)
    mediaPicker.delegate = self
    mediaPicker.allowsPickingMultipleItems = true
    mediaPicker.showsCloudItems = false
    
    presentViewController(mediaPicker, animated: true, completion: nil)
  }
}
