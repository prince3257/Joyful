//
//  TopicContentViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/18.
//

import UIKit
import JGProgressHUD

class TopicContentViewController: UIViewController {
    
    // MARK: 屬性

    static var identifier = "TopicContentViewController"
    
    var topic: TopicData?
        
    var topicContent: TopicContent?
    
    var liked: Bool = false
    
    var saved: Bool = false
    
    var messageload = 1
    
    @IBOutlet weak var theme: UILabel!
    
    @IBOutlet weak var tableview: UITableView!

    @IBOutlet weak var messageBar: UITextField!
    
    // MARK: function
    
    @IBAction func turnBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func leaveMessage(_ sender: Any) {
        guard let messageContent = messageBar.text,
              let articleID = topicContent?.articleId,
              let personData = PersonalDataModel.shared.personalData else {
            return
        }
        
        let hud = JGProgressHUD.init()
        hud.textLabel.text = "上傳中"
        hud.show(in: self.view, animated: true)
        
        let message = MessageUpload(articleId: articleID, account: personData.account, nickname: personData.nickname, wordContent: messageContent)
        TopicDataModel.shared.uploadMessage(message: message) { response in
            switch response {
            case .success(_):
                DispatchQueue.main.async {
                    hud.dismiss(animated: true)
                    TopicDataModel.shared.getArticleMessage(atricleID: articleID, page: 1)
                }
            case .failure(_):
                DispatchQueue.main.async {
                    hud.dismiss(animated: true)
                    AlertManager.shared.showAlert(title: "上傳失敗", headLine: "上傳文章失敗，請檢查網路", content: "", vc: self)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.register(UINib(nibName: "TopicContentTableViewCell", bundle: nil), forCellReuseIdentifier: TopicContentTableViewCell.identifier)
        tableview.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: MessageTableViewCell.identifier)
        addGesture()
        keyboardNotificationSetting()
        generalSetting()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //檢查是否收藏、按讚，放上主題
    func generalSetting() {
        guard let topic = topic,
              let content = topicContent else {
            return
        }
        if topic.collectedAcount != nil {
            self.saved = true
        }
        if topic.article.likedAcount != nil {
            self.liked = true
        }
        theme.text = content.subject
    }
    
    //新增手勢：點擊空白處收回鍵盤
    func addGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
    }
    
    //註冊鍵盤監聽
    func keyboardNotificationSetting() {
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyborad), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //顯示鍵盤
    @objc func showKeyboard(_ notification: NSNotification) {
        guard let info = notification.userInfo,
              let keyboardFrameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardSize = keyboardFrameValue.cgRectValue
        if view.frame.origin.y == 0 {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    //隱藏鍵盤
    @objc func hideKeyborad(_ notification: NSNotification) {
        self.view.frame.origin.y = .zero
    }
    
    //隱藏鍵盤
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }

}

extension TopicContentViewController: UITableViewDelegate, UITableViewDataSource {
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 0 && indexPath.row == 0 {
//            return tableView.frame.height/2
//        }
//        return tableView.estimatedRowHeight
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TopicDataModel.shared.messageAmt() + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let topicContent = topicContent else {
            return UITableViewCell()
        }
        if indexPath.section == 0 && indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TopicContentTableViewCell.identifier, for: indexPath) as? TopicContentTableViewCell else {return UITableViewCell() }
            cell.topicContent = topicContent
            cell.liked = liked
            cell.saved = saved
            cell.superVC = self
            cell.settingCell()
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier, for: indexPath) as? MessageTableViewCell else {return UITableViewCell() }
            cell.messageContent = TopicDataModel.shared.getMessage(index: indexPath)
            cell.settingCell()
            return cell
        }
    }
}

extension TopicContentViewController: TopicDataModelDelegate {
    func updateTopicData() {
        if let data = TopicDataModel.shared.specificArticle {
            self.topic = data
            generalSetting()
        }
        tableview.reloadData()
    }
}

extension TopicContentViewController: UISceneDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView.contentSize.height > self.tableview.frame.height,
        let articleID = topicContent?.articleId else { return }
        if scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y) <= -5 {
            messageload += 1
            TopicDataModel.shared.getArticleMessage(atricleID: articleID, page: messageload)
        }
    }
}
