//
//  Song.swift
//  PlaySync
//
//  Created by James Carroll on 7/15/15.
//  Copyright (c) 2015 James Carroll. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

let deviceName = UIDevice.currentDevice().name

class Song: NSObject, NSCoding {
  let artist: String!
  let album: String!
  let title: String!
  let artwork: UIImage!
  let url: NSURL!
  let duration: NSTimeInterval!
  let persistentId: String!
  let sender: String!
  
  // MARK: - init
  
  override init() {
    self.artist = ""
    self.album = ""
    self.title = ""
    self.artwork = UIImage()
    self.url = NSURL()
    self.duration = NSTimeInterval()
    self.persistentId = ""
    self.sender = ""
    
    super.init()
  }
  
  init(artist: String, album: String, title: String, artwork: UIImage,
    url: NSURL, duration: NSTimeInterval, persistentId: String) {
      self.artist = artist
      self.album = album
      self.title = title
      self.artwork = artwork
      self.url = url
      self.duration = duration
      self.persistentId = persistentId
      self.sender = deviceName
      
      super.init()
  }
  
  // MARK: - NSCoding
  
  required init(coder aDecoder: NSCoder) {
    self.artist = aDecoder.decodeObjectForKey("artist") as! String
    self.album = aDecoder.decodeObjectForKey("album") as! String
    self.title = aDecoder.decodeObjectForKey("title") as! String
    self.artwork = aDecoder.decodeObjectForKey("artwork") as! UIImage
    self.url = aDecoder.decodeObjectForKey("url") as! NSURL
    self.duration = aDecoder.decodeObjectForKey("duration") as! NSTimeInterval
    self.persistentId = aDecoder.decodeObjectForKey("persistantId") as! String
    self.sender = aDecoder.decodeObjectForKey("sender") as! String
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(artist, forKey: "artist")
    aCoder.encodeObject(album, forKey: "album")
    aCoder.encodeObject(title, forKey: "title")
    aCoder.encodeObject(artwork, forKey: "artwork")
    aCoder.encodeObject(url, forKey: "url")
    aCoder.encodeObject(duration, forKey: "duration")
    aCoder.encodeObject(persistentId, forKey: "persistantId")
    aCoder.encodeObject(sender, forKey: "sender")
  }
  
  // MARK: - Instance methods
  
  func selfToNSData() -> NSData {
    return NSKeyedArchiver.archivedDataWithRootObject(self)
  }
  
  func selfToString() -> String {
    return selfToNSData().base64EncodedStringWithOptions(.Encoding64CharacterLineLength) ?? ""
  }
  
  func selfToMPMediaItem() -> MPMediaItem {
    let predicate = MPMediaPropertyPredicate(value: self.persistentId, forProperty: MPMediaItemPropertyPersistentID)
    let query = MPMediaQuery()
    var song = MPMediaItem()
    query.addFilterPredicate(predicate)
    
    if query.items.count > 0 {
      song = query.items[0] as! MPMediaItem
    }
    
    return song
  }
  
  func selfToAssetOutput() -> AVAssetReaderTrackOutput {
    var err: NSError?
    let asset = AVURLAsset(URL: self.url, options: nil)
    let reader = AVAssetReader(asset: asset, error: &err)
    let output = AVAssetReaderTrackOutput(track: asset.tracks[0] as! AVAssetTrack, outputSettings: nil)
    
    reader.addOutput(output)
    reader.startReading()
    
    return output
  }
  
  // Returns human readable String of NSTimeInterval
  func secToMin() -> String {
    let t = self.duration
    var min = floor(t / 60)
    var sec = Int(round(t - (min * 60)))
    var secString: String!
    
    if sec >= 10 {
      secString = sec.description
    } else {
      secString = "0\(sec)"
    }
    
    return "\(Int(min)):\(secString)"
  }
  
  // MARK: - Class methods
  
  class func returnArrayOfMPMediaItem(songs: [Song]) -> [MPMediaItem] {
    var mediaItems = [MPMediaItem]()
    
    for s in songs {
      mediaItems.append(s.selfToMPMediaItem())
    }
    
    return mediaItems
  }
  
  class func returnSongObject(song s: MPMediaItem) -> Song {
    return Song(artist: s.artist, album: s.albumTitle, title: s.title,
      artwork: s.artwork.imageWithSize(CGSize(width: 128, height: 128)),
      url: s.assetURL, duration: s.playbackDuration, persistentId: s.persistentID.description)
  }
}