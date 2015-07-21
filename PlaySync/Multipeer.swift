//
//  Multipeer.swift
//  PlaySync
//
//  Created by James Carroll on 7/13/15.
//  Copyright (c) 2015 James Carroll. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class Multipeer {
  let serviceType = "7c24dec7ad14dca"
  
  var playbackDevice: Bool!
  var peerId: MCPeerID!
  var playbackPeer: MCPeerID!
  var session: MCSession!
  var browser: MCBrowserViewController!
  var advertiser: MCAdvertiserAssistant!
  var delegate: AnyObject!
  
  init() {
    peerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    session = MCSession(peer: peerId)
    advertiser = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)
  }
  
  init(delegate: AnyObject) {
    self.delegate = delegate
    
    if let del = delegate as? MusicQueueViewController {
      peerId = MCPeerID(displayName: UIDevice.currentDevice().name)
      session = MCSession(peer: peerId)
      session.delegate = del
      advertiser = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)
    }
  }
  
  func openViewController() {
    if let del = delegate as? MusicQueueViewController {
      if playbackDevice == true {
        advertiser.start()
      } else {
        browser = MCBrowserViewController(serviceType: serviceType, session: session)
        browser.delegate = del
        
        del.presentViewController(browser, animated: true, completion: nil)
      }
    }
    
  }
  
  func writeData(data: NSData) {
    var err: NSError?
    
    if data.length > 0 {
      session.sendData(data, toPeers: session.connectedPeers, withMode: .Reliable, error: &err)
    }
  }
  
  func writeMessage(message: String) {
    let data = message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) ?? NSData()
    writeData(data)
  }
  
  func dataToSong(data: NSData) -> Song? {
    if data.length > 0 {
      return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Song
    } else {
      return nil
    }
  }
  
  
}