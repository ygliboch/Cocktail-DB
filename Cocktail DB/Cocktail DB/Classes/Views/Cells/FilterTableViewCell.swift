//
//  FilterTableViewCell.swift
//  Cocktail DB
//
//  Created by Yaroslava Hlibochko on 12.12.2019.
//  Copyright © 2019 Yaroslava Hlibochko. All rights reserved.
//

import UIKit

class FilterTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var isSelectedIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            isSelectedIcon.isHidden = false
        } else {
            isSelectedIcon.isHidden = true
        }
    }

}
