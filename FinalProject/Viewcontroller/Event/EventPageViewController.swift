//
//  EventPageViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/15.
//

import UIKit

class EventPageViewController: UIViewController {

    @IBOutlet weak var segmentBar: UISegmentedControl!
    
    @IBOutlet var pages: [UIView]!
    
    @IBAction func changePage(sender: UISegmentedControl) {
       for page in pages {
           page.isHidden = true
       }
        pages[sender.selectedSegmentIndex].isHidden = false
        self.children[sender.selectedSegmentIndex].viewWillLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30), NSAttributedString.Key.foregroundColor: UIColor.black]
        pages[0].isHidden = false
        pages[1].isHidden = true
        pages[2].isHidden = true
        segmentBar.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25), NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        
    }
    
}
