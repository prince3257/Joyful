//
//  MessageTableViewCell.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/18.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    // MARK: 屬性
    
    static var identifier = "MessageTableViewCell"
    
    var messageContent: MessageData?
    
    var liked: Bool = false

    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var uerName: UILabel!
    
    @IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    // MARK: function
    
    @IBAction func likeMessage(_ sender: Any) {
        guard let messageContent = messageContent?.message else {
            return
        }
        TopicDataModel.shared.uploadLikeMessage(messageID: messageContent.messageId) { response in
            switch response {
            case .success(_):
                print("留言按讚成功")
                self.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
                self.liked = true
            case .failure(_):
                break
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        settingCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func settingCell() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        guard let messageContent = messageContent else {
            return
        }
        if messageContent.likedAcount != nil {
            liked = true
        }
        if liked {
            likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
//            likeButton.isEnabled = false
        } else {
            likeButton.setImage(UIImage(systemName:"hand.thumbsup"), for: .normal)
//            likeButton.isEnabled = true
        }
        let message = messageContent.message
        self.photo.layer.cornerRadius = photo.frame.width/2
        self.photo.clipsToBounds = true
        if let urlString = message.avatar ,
           let url = URL(string: urlString) {
            self.photo.sd_setImage(with: url, completed: nil)
        } else {
            self.photo.image = UIImage(systemName: "person.fill")
        }
        self.uerName.text = message.nickname
        self.message.text = message.wordContent
    }
    
}
