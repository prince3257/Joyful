//
//  ChallengePageViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/16.
//

import UIKit

class ChallengePageViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.register(UINib(nibName: "ChallengeTableViewCell", bundle: nil), forCellReuseIdentifier: ChallengeTableViewCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        VideoDataModel.shared.delegate = self
        VideoDataModel.shared.fetchVideoData { response in
            switch response {
            case .success(let outcome):
                if !outcome {
                    AlertManager.shared.showAlert(title: "載入失敗", headLine: "請確認網路", content: "返回確認", vc: self)
                }
                break
            case .failure(_):
                AlertManager.shared.showAlert(title: "載入失敗", headLine: "請確認網路", content: "返回確認", vc: self)
                break
            }
        }
    }
}

extension ChallengePageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return VideoDataModel.shared.getVideoAmt()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengeTableViewCell", for: indexPath) as? ChallengeTableViewCell else {
            return UITableViewCell() }
        guard let data = VideoDataModel.shared.getVideoData(index: indexPath) else {
            return UITableViewCell()
        }
        cell.title.text = data.snippet.title
        let url = data.snippet.thumbnails.medium.url
        cell.photo.sd_setImage(with: URL(string: url), completed: nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ChallengeDetailViewController.identifier) as! ChallengeDetailViewController
        guard let data = VideoDataModel.shared.getVideoData(index: indexPath) else {
            return
        }
        vc.videContent = data
        Info.channelID = data.snippet.channelId
        Info.videoID = data.contentDetails.videoId
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}

extension ChallengePageViewController: VideoDataModelDelegate {
    func updateVideoData() {
        tableview.reloadData()
    }
    
}
