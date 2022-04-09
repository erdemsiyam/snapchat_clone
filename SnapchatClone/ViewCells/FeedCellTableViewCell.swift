//
//  FeedCellTableViewCell.swift
//  SnapchatClone
//
//  Created by Erdem Siyam on 8.04.2022.
//

import UIKit

class FeedCellTableViewCell: UITableViewCell {

    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
