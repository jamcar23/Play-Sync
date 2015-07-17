//
//  SongTableViewCell.swift
//  PlaySync
//
//  Created by James Carroll on 7/17/15.
//  Copyright (c) 2015 James Carroll. All rights reserved.
//

import UIKit

class SongTableViewCell: UITableViewCell {
  @IBOutlet weak var songLbl: UILabel!
  @IBOutlet weak var artistLbl: UILabel!
  @IBOutlet weak var durationLbl: UILabel!
  @IBOutlet weak var albumImg: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
