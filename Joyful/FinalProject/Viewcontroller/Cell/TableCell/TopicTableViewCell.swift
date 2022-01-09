//
//  HotTopicTableViewCell.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/15.
//

import UIKit

class TopicTableViewCell: UITableViewCell {
    
    static var identifier = "TopicTableViewCell"
        
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var likeCount: UILabel!
    
    @IBOutlet weak var category: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func settingCell(date: String, title: String, photoUrl: String?, likeCount: Int, category: Int) {
//        self.layer.cornerRadius = 5
//        self.clipsToBounds = true
//        self.layer.borderColor = UIColor.lightGray.cgColor
//        self.layer.borderWidth = 1
        let date = TimeManager.shared.dateFormatter(originString: date)
        self.date.text = date
        self.title.text = title
        self.likeCount.text = "\(likeCount)人說讚"
        if let photoUrl = photoUrl, let url = URL(string: photoUrl) {
            photo.sd_setImage(with: url, completed: nil)
        } else {
            photo.image = UIImage(named: "找不到")
        }
        photo.layer.cornerRadius = 5
        photo.clipsToBounds = true
        if let theme = ThemeDataModel.shared.themeName(index: category) {
            self.category.text = "#\(theme)"
        } else {
            self.category.text = ""
        }
    }
}
