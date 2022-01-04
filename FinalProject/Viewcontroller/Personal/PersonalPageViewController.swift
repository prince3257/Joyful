//
//  PersonalPageViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/15.
//

import UIKit
import JGProgressHUD

class PersonalPageViewController: UIViewController {
    
    //MARK: 屬性

    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var postedButton: UIButton!
    
    @IBOutlet weak var collectedButton: UIButton!
    
    @IBOutlet weak var joinedButton: UIButton!
    
    var photourl: String?
    
    //MARK: function

    @IBAction func postedArticle(_ sender: Any) {
        prepareForDetail(type: .Posted)
    }
    
    @IBAction func collectedArticle(_ sender: Any) {
        prepareForDetail(type: .Collected)
    }
    
    @IBAction func joinedEvent(_ sender: Any) {
        prepareForDetail(type: .Joined)
    }
    
    func prepareForDetail(type:PersonalRelated) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: PersonalRelatedViewController.identifier) as? PersonalRelatedViewController else {
            return
        }
        switch type {
        case .Posted:
            TopicDataModel.shared.delegate = vc
            vc.type = .Posted
            TopicDataModel.shared.getPersonalRelatedArticle(type: .Posted, page: 1)
        case .Collected:
            TopicDataModel.shared.delegate = vc
            vc.type = .Collected
            TopicDataModel.shared.getPersonalRelatedArticle(type: .Collected, page: 1)
        case .Joined:
            EventDataModel.shared.delegate = vc
            vc.type = .Joined
            EventDataModel.shared.fetchPersonalRelatedEvent(page: 1)
        }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
    }
    
    //登出
    @IBAction func signout(_ sender: Any) {
        APIManager.shared.signOut()
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginPageViewController")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30), NSAttributedString.Key.foregroundColor: UIColor.black]
        addGesture()
        self.photo.layer.cornerRadius = photo.frame.width/2
        self.photo.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PersonalDataModel.shared.delegate = self
        PersonalDataModel.shared.fetchPersonalData()
    }
    
    //新增手勢：可以更換大頭照
    func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentPhotopicker))
        self.photo.addGestureRecognizer(tap)
    }
    
    //更換大頭照
    private func changeProfilePhoto() {
        let hud = JGProgressHUD.init()
        hud.textLabel.text = "上傳中"
        hud.show(in: self.view, animated: true)
        
        let uploadGroup = DispatchGroup()

        //上傳照片
        guard let img = photo.image , let ac = PersonalDataModel.shared.personalData?.account else { return }
        uploadGroup.enter()
        APIManager.shared.uploadImg(uploadImage: img, name: ac) { response in
            switch response{
            case .success(let data):
                self.photourl = data.data.link
                uploadGroup.leave()
            case .failure(_):
                uploadGroup.leave()
            }
        }
        
        uploadGroup.notify(queue: .global()) {
            PersonalDataModel.shared.updateProfilePhoto(imageUrl: self.photourl!) { response in
                switch response {
                case .success(_):
                    DispatchQueue.main.async {
                        hud.dismiss(animated: true)
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        hud.dismiss(animated: true)
                        AlertManager.shared.showAlert(title: "上傳照片失敗", headLine: "請再試一次", content: "重新檢查", vc: self)
                    }
                }
            }
        }
    }
    
    @objc func presentPhotopicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        let imagePickerOptionController = UIAlertController(title: "上傳照片", message: "請選擇上傳方式", preferredStyle: .actionSheet)
        let imageFromLibAction = UIAlertAction(title: "相簿", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePickerController.sourceType = .photoLibrary
                imagePickerController.sheetPresentationController?.detents = [.medium(), .large()]
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        let imageFromCamAction = UIAlertAction(title: "相機", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            imagePickerController.dismiss(animated: true, completion: nil)
        }
        
        imagePickerOptionController.addAction(imageFromLibAction)
        imagePickerOptionController.addAction(imageFromCamAction)
        imagePickerOptionController.addAction(cancelAction)
        
        self.present(imagePickerOptionController, animated: true, completion: nil)
    }

}

extension PersonalPageViewController: UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    //選取照片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imageFromPicker = info[.editedImage] as? UIImage {
            photo.contentMode = .scaleAspectFill
            photo.image = imageFromPicker
        } else if let imageFromPicker = info[.originalImage] as? UIImage {
            print("here")
            photo.contentMode = .scaleToFill
            photo.image = imageFromPicker
        } else {
            photo.image = UIImage(systemName: "person")
        }
        dismiss(animated: true, completion: nil)
        changeProfilePhoto()
    }
}

extension PersonalPageViewController: PersonalDataModelDelegate {
    func updatePersonData() {
        guard let personaData = PersonalDataModel.shared.personalData else {
            return
        }
        if let photoUrl = personaData.avatar, let url = URL(string: photoUrl){
            photo.sd_setImage(with: url, completed: nil)
        } else {
            photo.image = UIImage(named: "找不到")
        }
        userName.text = personaData.nickname
    }
}

enum PersonalRelated {
    case Posted
    case Collected
    case Joined
}
