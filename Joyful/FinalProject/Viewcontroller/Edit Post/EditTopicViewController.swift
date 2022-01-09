//
//  EditTopicViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/17.
//

import UIKit
import Alamofire
import JGProgressHUD

class EditTopicViewController: UIViewController {
    
    //MARK: 屬性
    
    static var identifier = "EditTopicViewController"
    
    @IBOutlet weak var turnbackButton: UIButton!
    
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var theme: UITextField!{
        didSet {
            theme.attributedPlaceholder = NSAttributedString(
                string: "篩選主題",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        }
    }
    
    @IBOutlet weak var postTitle: UITextField!{
        didSet {
            postTitle.attributedPlaceholder = NSAttributedString(
                string: "文章標題",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        }
    }
    
    @IBOutlet weak var postContent: UITextView!
    
    @IBOutlet weak var scrollview: UIScrollView!
    
    var firstPhoto: String?
    
    var searchTheme: String?
    
    //MARK: function
    
    @IBAction func turnback(_ sender: Any) {
        dismiss(animated: true)
    }
    
    //從主題篩選完回來
    @IBAction func turnBackSegue(segue: UIStoryboardSegue) {
        if let sourceVC = segue.source as? SearchThemeViewController {
            if sourceVC.theme != "" {
                theme.text = sourceVC.theme
            }
        }
    }
    
    //設定搜尋主題頁的高度
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SearchThemeViewController.identifier {
            let desVC = segue.destination as! SearchThemeViewController
            desVC.sheetPresentationController?.detents = [.medium()]
        }
    }

    //完成文章
    @IBAction func finishPost(_ sender: Any) {
        var finishedText = postContent.text
        var attachmentLocation:[Int] = []
        var img:[UIImage] = []
        var imgUrl:[String] = []

        let hud = JGProgressHUD.init()
        hud.textLabel.text = "上傳中"
        hud.show(in: self.view, animated: true)
        
        postContent.attributedText.enumerateAttribute(.attachment, in: NSRange(0..<postContent.attributedText.length), options: .longestEffectiveRangeNotRequired) { value, range, stop in
            if let attachment = value as? NSTextAttachment {
                attachmentLocation.append(range.location)
                if let image = attachment.image {
                    img.append(image)
                }
                
            }
        }
        
        let group = DispatchGroup()
        
        for i in 0..<img.count {
            group.enter()
            APIManager.shared.uploadImg(uploadImage: img[i], name: String(i)) { response in
                switch response {
                case .success(let data):
                    print("[uploadImage]上傳完成")
                    imgUrl.append(data.data.link)
                    group.leave()
                case .failure(_):
                    print("[uploadImage]上傳有誤")
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            print("上傳結束")
            for i in 0..<attachmentLocation.count {
                let index = (finishedText?.index(finishedText!.startIndex, offsetBy: attachmentLocation.reversed()[i]))!
                finishedText?.insert(contentsOf: "<IMG>\(imgUrl[i])", at: index)
            }
            
            if !imgUrl.isEmpty {
                self.firstPhoto?.append(imgUrl[0])
            }
            
            if let article = self.prepareForUpload(content:finishedText,firstImg: imgUrl.first) {
                DispatchQueue.global().async {
                    TopicDataModel.shared.uploadArticle(article: article) { response in
                        switch response {
                        case .success(_):
                            DispatchQueue.main.async {
                                hud.dismiss(animated: true)
                                self.turnback(self)
                            }
                        case .failure(_):
                            DispatchQueue.main.async {
                                hud.dismiss(animated: true)
                                AlertManager.shared.showAlert(title: "上傳失敗", headLine: "上傳文章失敗，請檢查網路", content: "", vc: self)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGesture()
        keyboardNotificationSetting()
        settingTopic()
    }
    
    private func settingTopic() {
        guard let personalData = PersonalDataModel.shared.personalData else {
            return
        }
        let bar = UIToolbar()
        let photoButton = UIBarButtonItem(image: UIImage(systemName: "camera"), style: .plain, target: self, action: #selector(openPhotopicker))
        bar.items = [photoButton]
        bar.sizeToFit()
        postContent.inputAccessoryView = bar
        
        self.photo.layer.cornerRadius = photo.frame.width/2
        photo.clipsToBounds = true
        
        if let urlString = personalData.avatar ,
           let url = URL(string: urlString) {
            self.photo.sd_setImage(with: url, completed: nil)
        } else {
            self.photo.image = UIImage(systemName: "person.fill")
        }
        self.userName.text = personalData.nickname
    }
    
    @objc func openPhotopicker() {
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
    
    //跳轉到搜尋主題
    @objc func opentheme() {
        performSegue(withIdentifier: SearchThemeViewController.identifier, sender: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //新增手勢：點擊空白處收回鍵盤
    func addGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(opentheme))
        theme.addGestureRecognizer(gesture)
    }
    
    //註冊鍵盤監聽
    private func keyboardNotificationSetting() {
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyborad), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //顯示鍵盤
    @objc func showKeyboard(_ notification: NSNotification) {
        guard let info = notification.userInfo,
              let keyboardFrameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardSize = keyboardFrame.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        scrollview.contentInset = contentInsets
        scrollview.scrollIndicatorInsets = contentInsets
    }
    
    //隱藏鍵盤
    @objc func hideKeyborad(_ notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollview.contentInset = contentInsets
        scrollview.scrollIndicatorInsets = contentInsets
    }
    
    //隱藏鍵盤
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
    //準備上傳
    private func prepareForUpload(content:String?, firstImg: String?) -> TopicDataUpload? {
        guard let personData = PersonalDataModel.shared.personalData else { return nil }
        guard let interest = theme.text else { return nil }
        let themeID = ThemeDataModel.shared.themeIndex(name: interest)
        guard let title = postTitle.text else { return nil }
        let article = TopicDataUpload(themeId: themeID, subject: title, account: personData.account, wordContent: content!, picture: firstImg, nickname: personData.nickname, likeCount: 0)
        return article
    }
}

extension EditTopicViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            return false
        } else {
            return true
        }
    }
    
}

extension EditTopicViewController: UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    //選取照片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imageFromPicker = info[.editedImage] as? UIImage {
            insertPictureToTextView(image: imageFromPicker)
        } else if let imageFromPicker = info[.originalImage] as? UIImage {
            insertPictureToTextView(image: imageFromPicker)
        } else {
            return
        }
        dismiss(animated: true, completion: nil)
    }
    
    //將文章圖片穿插其中
    func insertPictureToTextView(image:UIImage){
        // 產生可夾帶檔案的附件
        let attachment = NSTextAttachment()
        // 調整圖片的比例
        let imageAspectRatio = image.size.height / image.size.width
        let padding: CGFloat = 5
        let imageWidth = postContent.frame.width - 2 * padding
        let imageHeight = imageWidth * imageAspectRatio

        attachment.image = UIImage(data: image.jpegData(compressionQuality: 0.5)!)
        attachment.bounds = CGRect(x: 0, y: 0,
                                   width: imageWidth,
                                   height: imageHeight)
        // 產生可包含圖片的字串物件
        let attImage = NSAttributedString(attachment: attachment)
        let mutableStr = NSMutableAttributedString(attributedString: postContent.attributedText)
        // 取得當前滑鼠位置
        let selectedRange = postContent.selectedRange
        mutableStr.insert(NSAttributedString(string: "\n"), at: selectedRange.location)
        mutableStr.insert(attImage, at: selectedRange.location)
        mutableStr.insert(NSAttributedString(string: "\n"), at: selectedRange.location)
        // 更新目前的貼文
        postContent.attributedText = mutableStr
        postContent.font = UIFont.systemFont(ofSize: 25)
    }
}

