//
//  TopicContentTableViewCell.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/18.
//

import UIKit

class TopicContentTableViewCell: UITableViewCell {
    
    // MARK: 屬性
    
    static var identifier = "TopicContentTableViewCell"
    
    var topicContent: TopicContent?
    
    var superVC: TopicContentViewController?
    
    var liked: Bool = false
    
    var saved: Bool = false

    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var posterName: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var content: UITextView!
    
    @IBOutlet weak var likeButton: UIButton!
    
    // MARK: function

    @IBAction func likeThisPost(_ sender: Any) {
        guard let articleID = topicContent?.articleId else { return }
        TopicDataModel.shared.uploadLikeArticle(articleID: articleID) { response in
            switch response {
            case .success(_):
                self.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                self.liked = true
                break
            case .failure(_):
                break
            }
        }
    }
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func saveThisPost(_ sender: Any) {
        guard let articleID = topicContent?.articleId else { return }
        TopicDataModel.shared.uploadSaveArticle(articleID: articleID) { response in
            switch response {
            case .success(let data):
                self.saved = data
                if self.saved {
                    self.saveButton.titleLabel?.text = "已收"
                } else {
                    self.saveButton.titleLabel?.text = "收藏"
                }
            case .failure(_):
                break
            }
        }
        
    }
    
    @IBAction func shareArticle(_ sender: Any) {
        guard let topicContent = topicContent,
        let vc = superVC,
        let id = topicContent.articleId else {
            return
        }
        guard let shareURL = URL(string: "https://optimistic-ardinghelli-fa5907.netlify.app/topics/\(id)") else {
            return
        }
        let items:[Any] = [shareURL]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        vc.present(ac, animated: true, completion: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        settingCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func settingCell() {
        guard let topicContent = topicContent else {
            return
        }
        if let imgUrl = topicContent.avatar,
           let url = URL(string: imgUrl) {
            self.photo.sd_setImage(with: url, completed: nil)
        } else {
            self.photo.image = UIImage(systemName: "person.fill")
        }
        self.photo.layer.cornerRadius = photo.frame.width/2
        self.photo.clipsToBounds = true
        self.posterName.text = topicContent.nickname
        let time = TimeManager.shared.dateFormatter(originString: topicContent.date)
        self.time.text = time
        if liked {
            self.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            self.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        if saved {
            self.saveButton.titleLabel?.text = "已收"
        } else {
            self.saveButton.titleLabel?.text = "收藏"
        }
        settingPostContnet(content: topicContent.wordContent)
    }
    
    func settingPostContnet(content: String) {
        let splitArr = content.split(separator: "\n")
        let mutableStr = NSMutableAttributedString()
        for i in 0..<splitArr.count {
            let string = splitArr[i]
            var position = mutableStr.length
            if string.contains("<IMG>") {
                var rawUrl = string
                let index = string.index(string.startIndex, offsetBy: 5)
                rawUrl = rawUrl[index...]
                var imgUrl = String(rawUrl)
                let secIndex = imgUrl.range(of: ".jpg")!
                let finalUrl = imgUrl.prefix(upTo: secIndex.upperBound)
                imgUrl = String(finalUrl)
                guard let url = URL(string: imgUrl) else {return}
                do {
                    let data = try Data(contentsOf: url)
                    let attachment = NSTextAttachment()
                    guard let image = UIImage(data: data) else { return }
                    let ratio = image.size.height / image.size.width
                    attachment.image = image
                    let width = self.content.frame.width - 2 * 5
                    let height = width*ratio
                    attachment.bounds = CGRect(x: 0, y: 0,
                                               width: width,
                                               height: height)
                    let attachImg = NSAttributedString(attachment: attachment)
                    mutableStr.insert(attachImg, at: position)
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                mutableStr.insert(NSAttributedString(string: String(string)), at: position)
            }
            position = mutableStr.length
            mutableStr.insert(NSAttributedString(string: "\n"), at: position)
        }
        self.content.attributedText = mutableStr
        self.content.font = UIFont.systemFont(ofSize: 25)
    }
    
}
