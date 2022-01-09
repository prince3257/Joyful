//
//  ChallengeTableViewCell.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/16.
//

import UIKit

class ChallengeTableViewCell: UITableViewCell {
    
    static var identifier = "ChallengeTableViewCell"

    @IBOutlet weak var photo: UIImageView!
        
    @IBOutlet weak var title: UILabel!
            
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
