//
//  ThemeCollectionViewCell.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/16.
//

import UIKit
import SDWebImage

class ThemeCollectionViewCell: UICollectionViewCell {
    
    static var identifier = "ThemeCollectionViewCell"
    
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var category: UILabel!
    
    @IBOutlet weak var checkView: UIView!
    
    var check = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
    }

    func toggle() {
        check = !check
    }
    
    func setCell(title: String, imgUrl: String) {
        category.text = title
        guard let url = URL(string: imgUrl) else { return }
        photo.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo.on.rectangle.angled"))
    }
}
