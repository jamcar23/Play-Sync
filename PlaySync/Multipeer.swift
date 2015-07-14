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
  var session: MCSession!
  var browser: MCBrowserViewController!
  var advertiser: MCAdvertiserAssistant!
  var delegate: MusicQueueViewController!
  
  init() {
    peerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    session = MCSession(peer: peerId)
    
  }
  
  func openViewController() {
    session.delegate = delegate
    
    if playbackDevice == true {
      advertiser = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)
      advertiser.start()
    } else {
      browser = MCBrowserViewController(serviceType: serviceType, session: session)
      browser.delegate = delegate
      
      delegate.presentViewController(browser, animated: true, completion: nil)
    }
  }
  
  
}