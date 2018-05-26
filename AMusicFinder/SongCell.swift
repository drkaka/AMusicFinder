//
//  SongCell.swift
//  AMusicFinder
//
//  Created by Kaka on 26/5/2018.
//  Copyright © 2018 Kaka. All rights reserved.
//

import UIKit

class SongCell: UITableViewCell {
    @IBOutlet var artwork: UIImageView!
    @IBOutlet var trackLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
