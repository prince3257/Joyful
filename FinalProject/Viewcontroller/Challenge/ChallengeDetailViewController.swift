//
//  ChallengeDetailViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/23.
//

import UIKit
import WebKit

class ChallengeDetailViewController: UIViewController {
    
    static var identifier = "ChallengeDetailViewController"

    @IBOutlet weak var challengeTitle: UILabel!
    
    @IBAction func turnBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var webView: WKWebView!
    
    var videContent: SingleVideo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingVC()
    }
    
    func settingVC() {
        guard let videContent = videContent else {
            return
        }
        challengeTitle.text = videContent.snippet.title
        let url = "https://www.youtube.com/embed/\(Info.videoID)?loop=1&playlist=\(Info.videoID)&playsinline=1"
        if let videoUrl = URL(string: url) {
            let request = URLRequest(url: videoUrl)
            webView.load(request)
        }
    }


}
