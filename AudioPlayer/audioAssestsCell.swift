//
//  audioAssestsCell.swift
//  AudioPlayer
//
//  Created by Nitin on 05/06/20.
//  Copyright © 2020 Nitin. All rights reserved.
//

import UIKit

class audioAssestsCell: UITableViewCell {

    //right now btn play user interaction is disabled, used as an image only
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
