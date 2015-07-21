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

let songCellId = "songCell"

class MusicQueueViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate, MPMediaPickerControllerDelegate, NSStreamDelegate, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var currentlyPlaying: CurrentSong!
  
  var playbackDevice: Bool!
  var songs = [Song]()
  var currentSong: Song?
  
  var multi: Multipeer!
  var player: MusicPlayer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    multi = Multipeer(delegate: self)
    multi.playbackDevice = self.playbackDevice
    multi.openViewController()
    
    tableView.tableFooterView = UIView(frame: CGRectZero)
    tableView.backgroundColor = UIColor.clearColor()
    
    if currentSong == nil {
      currentlyPlaying.hidden = true
    }
    
    player = MusicPlayer(isPlaybackDevice: playbackDevice)
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
      currentlyPlaying.controlBtn.image = song.artwork
      currentlyPlaying.songLbl.text = song.title
      currentlyPlaying.artistLbl.text = song.artist
      currentlyPlaying.hidden = false
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
    
    if playbackDevice == true {
      player.playerController?.nowPlayingItem = currentSong?.selfToMPMediaItem()
    }
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
      
      if currentSong != nil {
        multi.writeMessage(Controls.isCurrentSong(currentSong?.selfToString() ?? ""))
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
          multi.playbackPeer = MCPeerID(displayName: splitString[0])
        case Controls.currentSong:
          let d = NSData(base64EncodedString: splitString[0], options: .IgnoreUnknownCharacters)
          currentSong = multi.dataToSong(d ?? NSData())
          dispatch_async(dispatch_get_main_queue(), {
            self.updateCurrentlyPlaying()
          })
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
      stream.delegate = self
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
    var asset: AVURLAsset!
    var assestReader: AVAssetReader!
    var err: NSError?
    var songObj: Song!
    
    for s in (mediaItemCollection.items as! [MPMediaItem]) {
      songObj = Song(artist: s.artist, album: s.albumTitle, title: s.title,
        artwork: s.artwork.imageWithSize(CGSize(width: 128, height: 128)),
        url: s.assetURL, duration: s.playbackDuration, persistentId: s.persistentID.description)
      songs.append(songObj)
      multi.writeData(songObj.selfToNSData())
      
      asset = AVURLAsset(URL: songObj.url, options: nil)
      assestReader = AVAssetReader(asset: asset, error: &err)
    }
    tableView.reloadData()
    
    player.setQueue(MPMediaItemCollection(items: Song.returnArrayOfMPMediaItem(songs)))
    player.play()
    
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - NSStreamDelegate
  
  func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
    if aStream is NSInputStream {
      switch eventCode {
      case NSStreamEvent.HasBytesAvailable:
        break
      default:
        break
      }
    }
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
