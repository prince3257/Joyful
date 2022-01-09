//
//  HomePageViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/14.
//

import UIKit

class HomePageViewController: UIViewController {
    
    // MARK: 屬性
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataload = 1
        
    lazy var collectionviewLayout: UICollectionViewLayout = {
        
        //表格設定
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1) , heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        //表格群設定
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        //區塊設定
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }()
    
    // MARK: function
    
    @IBAction func moreEvent(_ sender: Any) {
        tabBarController?.selectedIndex = 1
    }
    
    @IBAction func moreTopic(_ sender: Any) {
        tabBarController?.selectedIndex = 3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30), NSAttributedString.Key.foregroundColor: UIColor.black]
        collectionView.register(UINib(nibName: "HotEventCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: HotEventCollectionViewCell.identifier)
        collectionView.collectionViewLayout = collectionviewLayout
        tableView.register(UINib(nibName: "TopicTableViewCell", bundle: nil), forCellReuseIdentifier: TopicTableViewCell.identifier)
        PersonalDataModel.shared.delegate = self
        PersonalDataModel.shared.fetchPersonalData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataload = 1
        EventDataModel.shared.delegate = self
        EventDataModel.shared.fetchHotEvent(page: dataload)
        TopicDataModel.shared.delegate = self
        TopicDataModel.shared.fetchHotTopicData(page: dataload)
    }
    
}

// MARK: 活動區
extension HomePageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return EventDataModel.shared.hotEventAmt()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HotEventCollectionViewCell.identifier, for: indexPath) as? HotEventCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard let data = EventDataModel.shared.getHotEventDetail(index: indexPath)?.event else {
            return UICollectionViewCell()
        }
        var register = false
        if EventDataModel.shared.getHotEventDetail(index: indexPath)?.attantAcount != nil {
            register = true
        }
        cell.settingCell(photoUrl: data.picture, level: data.hardnessName, title: data.subject, price: data.price, location: data.areaName, date: data.holdTime, registered: register, category: data.theme)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: EventContentViewController.identifier) as! EventContentViewController
        guard let data = EventDataModel.shared.getHotEventDetail(index: indexPath) else {
            return
        }
        vc.data = data
        vc.dataContent = data.event
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}

// MARK: 文章區

extension HomePageViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
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
        tableView.deselectRow(at: indexPath, animated: false)
        let topicData = TopicDataModel.shared.getHotTopicDetail(index: indexPath)
        guard let content = topicData?.article.article else { return }
        TopicDataModel.shared.delegate = vc
        TopicDataModel.shared.getArticleMessage(atricleID: content.articleId!, page: 1)
        vc.topic = topicData
        vc.topicContent = content
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        vc.generalSetting()
    }
}

extension HomePageViewController: EventDataModelDelegate, TopicDataModelDelegate {
    
    func updateTopicData() {
        tableView.reloadData()
    }
    
    func updateEventData() {
        collectionView.reloadData()
    }
}

extension HomePageViewController: UISceneDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView.contentSize.height > self.tableView.frame.height else { return }
        if scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y) <= -5 {
            dataload += 1
            TopicDataModel.shared.fetchHotTopicData(page: dataload)
        }
    }
}

extension HomePageViewController: PersonalDataModelDelegate {
    func updatePersonData() {
        print("[首頁]已取得個人資料")
    }
    
}
