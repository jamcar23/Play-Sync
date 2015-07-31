//
//  Multipeer.swift
//  PlaySync
//
//  Created by James Carroll on 7/13/15.
//  Copyright (c) 2015 James Carroll. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CoreMedia

final class Multipeer: NSObject, NSStreamDelegate {
  let serviceType = "7c24dec7ad14dca"
  
  var playbackDevice: Bool!
  var peerId: MCPeerID!
  var playbackPeer: MCPeerID!
  var session: MCSession!
  var browser: MCBrowserViewController!
  var advertiser: MCAdvertiserAssistant!
  var delegate: AnyObject!
  var outputStream: NSOutputStream?
  
  struct audioData {
    var fileStream = AudioFileStreamID()
    var queue = AudioQueueRef()
  }
  
  override init() {
    peerId = MCPeerID(displayName: deviceName)
    session = MCSession(peer: peerId)
    advertiser = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)
    
    super.init()
  }
  
  init(delegate: AnyObject) {
    self.delegate = delegate
    
    if let del = delegate as? MusicQueueViewController {
      peerId = MCPeerID(displayName: deviceName)
      session = MCSession(peer: peerId)
      session.delegate = del
      advertiser = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)
    }
    
    super.init()
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
  
  func writeMessageToPeer(message: String, peerName: String) {
    let data = message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) ?? NSData()
    var err: NSError?
    
    session.sendData(data, toPeers: [getPeer(peerName)], withMode: .Reliable, error: &err)
  }
  
  func startStreamWithPlaybackPeer() {
    var err: NSError?
    if outputStream == nil && (delegate as? MusicQueueViewController)?.playbackDevice == true {
      outputStream = session.startStreamWithName(Controls.neededSong, toPeer: playbackPeer, error: &err)
      outputStream?.delegate = self 
    }
    
    if let e = err {
      println("startStream error: \(e)")
    }
  }
  
  func writeSongToStream(song: Song) {
    let sampleBuffer = song.selfToAssetOutput().copyNextSampleBuffer()
    var blockBuffer: Unmanaged<CMBlockBuffer>? = nil
    var bufferList = AudioBufferList(mNumberBuffers: 1, mBuffers: AudioBuffer(mNumberChannels: 0, mDataByteSize: 0, mData: nil))
    
    CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, nil, &bufferList, sizeofValue(bufferList), nil, nil, UInt32(kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment), &blockBuffer)
    
    let audioBuffers = UnsafeBufferPointer<AudioBuffer>(start: &bufferList.mBuffers, count: Int(bufferList.mNumberBuffers))
    
    if let stream = outputStream {
      for buffer in audioBuffers {
        stream.write(UnsafeMutablePointer<UInt8>(buffer.mData), maxLength: Int(buffer.mDataByteSize))
      }
    }
    
    blockBuffer?.release()
  }
  
  func dataToSong(data: NSData) -> Song? {
    if data.length > 0 {
      return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Song
    } else {
      return nil
    }
  }
  
  private func getPeer(peerName: String) -> MCPeerID {
    var peer: MCPeerID!
    
    for p in session.connectedPeers as! [MCPeerID] {
      if p.displayName == peerName {
        peer = p
      }
    }
    
    return peer
  }
  
  func setSelfPlaybackPeer(peerName: String) {
    self.playbackPeer = getPeer(peerName)
  }
  
  // MARK: - NSStreamDelegate
  
  private func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
    if aStream is NSInputStream {
      switch eventCode {
      case NSStreamEvent.HasBytesAvailable:
        break
      default:
        break
      }
    }
    
    if aStream is NSOutputStream {
      switch eventCode{
      case NSStreamEvent.HasSpaceAvailable:
        break
      default:
        break
      }
    }
  }
  
  
}