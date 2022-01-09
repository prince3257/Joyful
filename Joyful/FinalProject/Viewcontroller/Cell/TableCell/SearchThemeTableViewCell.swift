//
//  SearchThemeTableViewCell.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/18.
//

import UIKit

class SearchThemeTableViewCell: UITableViewCell {
    
    static var identifier = "SearchThemeTableViewCell"
    
    @IBOutlet weak var photo: UIImageView!
        
    @IBOutlet weak var theme: UILabel!
    
    @IBOutlet weak var checkMark: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(title: String, imgUrl: String) {
        theme.text = title
        guard let url = URL(string: imgUrl) else { return }
        photo.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo.on.rectangle.angled"))
        checkMark.isHidden = true
    }
    
}
