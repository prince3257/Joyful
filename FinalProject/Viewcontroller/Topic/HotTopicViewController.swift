//
//  HotTopicViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/16.
//

import UIKit

class HotTopicViewController: UIViewController {
    
    // MARK: 屬性

    @IBOutlet weak var tableview: UITableView!
    
    var dataload = 1
    
    
    // MARK: function

    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.register(UINib(nibName: "TopicTableViewCell", bundle: nil), forCellReuseIdentifier: TopicTableViewCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TopicDataModel.shared.delegate = self
        dataload = 1
        TopicDataModel.shared.fetchHotTopicData(page: dataload)
    }
        
}

//MARK: 表格區
extension HotTopicViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TopicDataModel.shared.hotTopicAmt()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TopicTableViewCell.identifier, for: indexPath) as? TopicTableViewCell else {
            return UITableViewCell()
        }
        guard let data = TopicDataModel.shared.getHotTopicDetail(index: indexPath)?.article.article else {
            return UITableViewCell()
        }
        let theme = ThemeDataModel.shared.themeIndex(name: data.theme)
        cell.settingCell(date: data.date, title: data.subject, photoUrl: data.picture, likeCount: data.likeCount, category: theme)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: TopicContentViewController.identifier) as! TopicContentViewController
        let data = TopicDataModel.shared.getHotTopicDetail(index: indexPath)
        guard let content = data?.article.article else { return }
        TopicDataModel.shared.delegate = vc
        TopicDataModel.shared.getArticleMessage(atricleID: content.articleId!, page: 1)
        vc.topic = data
        vc.topicContent = content
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension HotTopicViewController: TopicDataModelDelegate{
    
    func updateTopicData() {
        tableview.reloadData()
    }
    
}

//往下滑page+1
extension HotTopicViewController: UISceneDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView.contentSize.height > self.tableview.frame.height else { return }
        if scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y) <= -5 {
            dataload += 1
            TopicDataModel.shared.delegate = self
            TopicDataModel.shared.fetchHotTopicData(page: dataload)
        }
    }
}
