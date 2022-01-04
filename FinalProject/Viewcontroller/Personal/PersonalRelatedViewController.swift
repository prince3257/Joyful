//
//  TextViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/17.
//

import UIKit

class PersonalRelatedViewController: UIViewController {
    
    //MARK: 屬性
    
    static var identifier = "PersonalRelatedViewController"
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var subject: UILabel!
    
    var type: PersonalRelated?
    
    var dataload = 1
    
    @IBAction func turnBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}

extension PersonalRelatedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch type {
        case .Posted:
            return TopicDataModel.shared.postTopicAmt()
        case .Collected:
            return TopicDataModel.shared.collectTopicAmt()
        case .Joined:
            return EventDataModel.shared.joinedEventAmt()
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "personalRelatedCell") else {
            return UITableViewCell()
        }
        switch type {
        case .Posted:
            guard let data = TopicDataModel.shared.getPostedTopicDetail(index: indexPath) else {
                return UITableViewCell()
            }
            //設定
            subject.text = "我發布的文章"
//            cell.textLabel?.text = data.subject
            cell.textLabel?.attributedText = NSAttributedString(string: data.subject, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
            return cell
        case .Collected:
            guard let data = TopicDataModel.shared.getCollectedTopicDetail(index: indexPath) else {
                return UITableViewCell()
            }
            subject.text = "我收藏的文章"
            cell.textLabel?.attributedText = NSAttributedString(string: data.subject, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
            //設定
            return cell
        case .Joined:
            guard let data = EventDataModel.shared.getPersonalEventDetail(index: indexPath) else {
                return UITableViewCell()
            }
            subject.text = "我參加過的活動"
            cell.textLabel?.attributedText = NSAttributedString(string: data.subject, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
            //設定
            return cell
        case .none:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch type {
        case .Posted:
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: TopicContentViewController.identifier) as! TopicContentViewController
            let data = TopicDataModel.shared.getPostedTopicDetail(index: indexPath)
            guard let atricleID = data?.articleId else { return }
            TopicDataModel.shared.delegate = vc
            TopicDataModel.shared.getSpecificArticle(topicID: atricleID)
            TopicDataModel.shared.getArticleMessage(atricleID: atricleID, page: 1)
            vc.topicContent = data
            vc.sheetPresentationController?.detents = [.large()]
            present(vc, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case .Collected:
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: TopicContentViewController.identifier) as! TopicContentViewController
            let data = TopicDataModel.shared.getCollectedTopicDetail(index: indexPath)
            guard let atricleID = data?.articleId else { return }
            TopicDataModel.shared.delegate = vc
            TopicDataModel.shared.getSpecificArticle(topicID: atricleID)
            TopicDataModel.shared.getArticleMessage(atricleID: atricleID, page: 1)
            vc.topicContent = data
            vc.sheetPresentationController?.detents = [.large()]
            present(vc, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case .Joined:
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: EventContentViewController.identifier) as! EventContentViewController
            let data = EventDataModel.shared.getPersonalEventDetail(index: indexPath)
            vc.dataContent = data
            vc.sheetPresentationController?.detents = [.large()]
            present(vc, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        case .none:
            tableView.deselectRow(at: indexPath, animated: true)
            break
        }
    }
    
}

extension PersonalRelatedViewController: TopicDataModelDelegate, EventDataModelDelegate {
    func updateMessageData() {
         
    }
    
    func updateTopicData() {
        tableView.reloadData()
    }
    
    func updateEventData() {
        tableView.reloadData()
    }
    
}

//往下滑page+1
extension PersonalRelatedViewController: UISceneDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView.contentSize.height > self.tableView.frame.height else { return }
        if scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y) <= -5 {
            dataload += 1
            switch type {
            case .Posted:
                TopicDataModel.shared.getPersonalRelatedArticle(type: .Posted, page: dataload)
                break
            case .Collected:
                TopicDataModel.shared.getPersonalRelatedArticle(type: .Collected, page: dataload)
                break
            case .Joined:
                EventDataModel.shared.fetchPersonalRelatedEvent(page: dataload)
            case .none:
                break
            }
        }
    }
}
