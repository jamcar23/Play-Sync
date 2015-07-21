//
//  Song.swift
//  PlaySync
//
//  Created by James Carroll on 7/15/15.
//  Copyright (c) 2015 James Carroll. All rights reserved.
//

import UIKit
import MediaPlayer

class Song: NSObject, NSCoding {
  let artist: String!
  let album: String!
  let title: String!
  let artwork: UIImage!
  let url: NSURL!
  let duration: NSTimeInterval!
  let persistentId: String!
  
  override init() {
    self.artist = ""
    self.album = ""
    self.title = ""
    self.artwork = UIImage()
    self.url = NSURL()
    self.duration = NSTimeInterval()
    self.persistentId = ""
    
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
      
      super.init()
  }
  
  required init(coder aDecoder: NSCoder) {
    self.artist = aDecoder.decodeObjectForKey("artist") as! String
    self.album = aDecoder.decodeObjectForKey("album") as! String
    self.title = aDecoder.decodeObjectForKey("title") as! String
    self.artwork = aDecoder.decodeObjectForKey("artwork") as! UIImage
    self.url = aDecoder.decodeObjectForKey("url") as! NSURL
    self.duration = aDecoder.decodeObjectForKey("duration") as! NSTimeInterval
    self.persistentId = aDecoder.decodeObjectForKey("persistantId") as! String
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(artist, forKey: "artist")
    aCoder.encodeObject(album, forKey: "album")
    aCoder.encodeObject(title, forKey: "title")
    aCoder.encodeObject(artwork, forKey: "artwork")
    aCoder.encodeObject(url, forKey: "url")
    aCoder.encodeObject(duration, forKey: "duration")
    aCoder.encodeObject(persistentId, forKey: "persistantId")
  }
  
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
  
  class func returnArrayOfMPMediaItem(songs: [Song]) -> [MPMediaItem] {
    var mediaItems = [MPMediaItem]()
    
    for s in songs {
      mediaItems.append(s.selfToMPMediaItem())
    }
    
    return mediaItems
  }
}