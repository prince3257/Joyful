//
//  LocationTableViewCell.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/22.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    
    static var identifier = "LocationTableViewCell"
    
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var checked: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
