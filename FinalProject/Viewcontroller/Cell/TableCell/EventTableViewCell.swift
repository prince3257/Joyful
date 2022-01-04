//
//  OnsiteEventTableViewCell.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/15.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    static var identifier = "EventTableViewCell"
        
    @IBOutlet weak var registered: UIView!
    
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var level: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var date: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        level.layer.backgroundColor = UIColor.red.cgColor
        level.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func settingCell(photoUrl: String?, level: String, title: String, price: Int?, location: String, date: String,registered: Bool) {
        self.title.text = title
        self.location.text = location
        self.level.text = level
        self.level.backgroundColor = EventDataModel.shared.getLevelColor(level: level)
        self.level.layer.cornerRadius = 5
        self.level.clipsToBounds = true
        let time = TimeManager.shared.dateFormatter(originString: date)
        self.date.text = time
        if let photoUrl = photoUrl, let url = URL(string: photoUrl) {
            photo.sd_setImage(with: url, completed: nil)
        } else {
            photo.image = UIImage(named: "")
        }
        if let price = price {
            self.price.text = "$ \(String(price))"
        } else {
            self.price.text = "FREE"
        }
        self.registered.isHidden = !registered
    }
    
    
    
}
