//
//  HotEventCollectionViewCell.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/14.
//

import UIKit
import SDWebImage

class HotEventCollectionViewCell: UICollectionViewCell {
        
    static var identifier = "HotEventCollectionViewCell"

    @IBOutlet weak var registered: UIView!
    
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var level: UILabel!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var category: UILabel!
            
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func settingCell(photoUrl: String?, level: String, title: String, price: Int?, location: String, date: String, registered: Bool, category: String) {
        self.level.layer.backgroundColor = UIColor.red.cgColor
        self.level.layer.cornerRadius = 5
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1

        self.title.text = title
        self.location.text = location
        self.category.text = category
        self.level.text = level
        self.level.backgroundColor = EventDataModel.shared.getLevelColor(level: level)
        self.level.layer.cornerRadius = 5
        self.level.clipsToBounds = true
        let time = TimeManager.shared.dateFormatter(originString: date)
        self.date.text = time
        if let photoUrl = photoUrl, let url = URL(string: photoUrl) {
            photo.sd_setImage(with: url, completed: nil)
        }
//        else {
//            photo.image = UIImage(named: "")
//        }
        self.registered.isHidden = !registered
    }

}
