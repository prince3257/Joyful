//
//  EditPostViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/15.
//

import UIKit
import Lottie

class EditPostViewController: UIViewController {
    
    @IBAction func createEvent(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: EditEventViewController.identifier)
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func createPost(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: EditTopicViewController.identifier)
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func turnBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var backButton: UIButton!
    
    static var identifier = "EditPostViewController"

    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.layer.borderWidth = 2
        backButton.layer.borderColor = UIColor.darkGray.cgColor
        backButton.layer.cornerRadius = 15
        backButton.clipsToBounds = true
    }


}
