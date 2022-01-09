//
//  TopicPageViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/15.
//

import UIKit

class TopicPageViewController: UIViewController {
    

    @IBOutlet var pages: [UIView]!
    
    @IBOutlet weak var segmentBar: UISegmentedControl!
    
    @IBAction func changePage(sender: UISegmentedControl) {
       for page in pages {
           page.isHidden = true
       }
        pages[sender.selectedSegmentIndex].isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30), NSAttributedString.Key.foregroundColor: UIColor.black]
        pages[0].isHidden = false
        pages[1].isHidden = true
        segmentBar.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25), NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
    }

}
