//
//  ViewController.swift
//  PlaySync
//
//  Created by James Carroll on 7/13/15.
//  Copyright (c) 2015 James Carroll. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  var playbackDevice: Bool!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let nav = segue.destinationViewController as! UINavigationController
    (nav.viewControllers[0] as! MusicQueueViewController).playbackDevice = self.playbackDevice
  }
  
  // MARK: - IBActions
  
  @IBAction func isPlaybackDevice(sender: UIButton) {
    if sender.tag == 0 {
      playbackDevice = true
    } else {
      playbackDevice = false
    }
    
    performSegueWithIdentifier("toMultipeerConnectionVC", sender: sender)
  }
  
}

