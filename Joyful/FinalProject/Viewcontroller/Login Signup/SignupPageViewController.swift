//
//  ViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/13.
//

import UIKit
import JGProgressHUD

struct UploadImage:Encodable {
    let imageFileB64: String
}

class SignupPageViewController: UIViewController {
    
    @IBOutlet weak var returnButton: UIButton!
    
    @IBAction func turnBackSegue(segue: UIStoryboardSegue) {
        switch segue.identifier {
        case "turnBackFromLocation":
            if let sourceVC = segue.source as? FilterLocationViewController {
                location.text = sourceVC.personalLocation
            }
            //上傳到個人
        case "turnBackFromTheme":
            var array:[String] = []
            if let sourceVC = segue.source as? FilterThemePageViewController {
                sourceVC.themes.forEach { theme in
                    array.append(theme)
                }
                themes.text = array.joined(separator: ",")
            }
            //上傳到個人
        default:
            break
        }
    }

    @IBAction func backToLogin(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUp(_ sender: Any) {
        
        let hud = JGProgressHUD.init()
        hud.textLabel.text = "註冊中"
        hud.show(in: self.view, animated: true)
        
        guard let ac = account.text, ac != "", let pw = password.text, pw != "", let na = name.text, na != "",
              let nm = nickName.text, nm != "", let bd = birth.text, bd != "",
              let theme = themes.text, theme != "", let location = location.text, location != "" else {
            hud.dismiss(animated: true)
            AlertManager.shared.showAlert(title: "註冊失敗", headLine: "請確認資料是否齊全", content: "重新檢查", vc: self)
            return
        }
        
        if !validateEmail(candidate: ac) {
            AlertManager.shared.showAlert(title: "註冊失敗", headLine: "請確認信箱格式是否正確", content: "重新檢查", vc: self)
            return
        }

        let uploadGroup = DispatchGroup()

            guard let img = photo.image else { return }
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
            let birthD = TimeManager.shared.formatForUpdate(date: self.birthDate!)
            APIManager.shared.signup(account: ac, password: pw, name: na, nickName: nm, birthday: birthD, avatar: self.photourl) { outcome in
                switch outcome {
                case .failure(_):
                    DispatchQueue.main.async {
                        hud.dismiss(animated: true)
                        AlertManager.shared.showAlert(title: "註冊失敗", headLine: "請確認資料是否有誤", content: "重新檢查", vc: self)
                    }
                case .success(_):
                    
                    //把主題跟地點上傳
                    let group = DispatchGroup()

                    let locationIndex = LocationDataModel.shared.locationIndex(name: location)
                    var themesIndex:[Int] = []
                    theme.split(separator: ",").forEach { certainTheme in
                        let savedtheme = ThemeDataModel.shared.themeIndex(name: String(certainTheme))
                        themesIndex.append(savedtheme)
                    }
                    
                    //用PUT上傳資料
                    group.enter()
                    APIManager.shared.uploadThemes(themes: themesIndex) { response in
                        switch response {
                        case .success(_):
                            group.leave()
                        case .failure(_):
                            group.leave()
                        }
                    }
                    
                    group.enter()
                    APIManager.shared.uploadlocation(location: locationIndex) { response in
                        switch response {
                        case .success(_):
                            group.leave()
                        case .failure(_):
                            group.leave()
                        }
                    }
                    //做完這兩個才能接下面
                    
                    group.notify(queue: .main) {
                        hud.dismiss(animated: true)
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginPageViewController") as! LoginPageViewController
                        vc.cacheACPW = [ac,pw]
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        }
        
    }
    
    @IBOutlet weak var photo: UIImageView!
    
    var photourl: String?
    
    @IBOutlet weak var account: CustomTextField!{
        didSet {
            account.attributedPlaceholder = NSAttributedString(
                string: "您的信箱",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        }
    }
    
    @IBOutlet weak var password: CustomTextField!{
        didSet {
            password.attributedPlaceholder = NSAttributedString(
                string: "您的密碼",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        }
    }
    
    @IBOutlet weak var name: CustomTextField!{
        didSet {
            name.attributedPlaceholder = NSAttributedString(
                string: "您的姓名",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        }
    }
    
    @IBOutlet weak var birth: CustomTextField!{
        didSet {
            birth.attributedPlaceholder = NSAttributedString(
                string: "您的生日",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        }
    }
    
    var birthDate: Date?
        
    @IBOutlet weak var nickName: CustomTextField!{
        didSet {
            nickName.attributedPlaceholder = NSAttributedString(
                string: "您的暱稱",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        }
    }
    
    @IBOutlet weak var themes: CustomTextField!{
        didSet {
            themes.attributedPlaceholder = NSAttributedString(
                string: "感興趣的主題",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        }
    }
    
    @IBOutlet weak var location: CustomTextField!{
        didSet {
            location.attributedPlaceholder = NSAttributedString(
                string: "感興趣的地區",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        }
    }
    
    @IBOutlet weak var signupButton: UIButton!
        
    @IBOutlet weak var scrollView: UIScrollView!
    
    var datePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        addGesture()
        keyboardNotificationSetting()
        buttonSetting()
        photoViewSetting()
        datePickerSetting()
        ThemeDataModel.shared.getThemes()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //設定按鈕
    func buttonSetting() {
        returnButton.layer.cornerRadius = 15
    }
    
    //調整照片＆增加手勢
    func photoViewSetting() {
        photo.layer.cornerRadius = photo.frame.width/2
        photo.layer.borderWidth = 3
        photo.layer.borderColor = UIColor.lightGray.cgColor
        photo.clipsToBounds = true
        let geature = UITapGestureRecognizer(target: self, action: #selector(presentPhotopicker))
        photo.addGestureRecognizer(geature)
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

    //新增手勢：點擊空白處收回鍵盤
    func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
        let themeTap = UITapGestureRecognizer(target: self, action: #selector(presentTheme))
        let locationTap = UITapGestureRecognizer(target: self, action: #selector(presentLocation))
        self.themes.addGestureRecognizer(themeTap)
        self.location.addGestureRecognizer(locationTap)
    }
    
    @objc func presentTheme() {
        performSegue(withIdentifier: FilterThemePageViewController.identifier, sender: self)
    }
    
    @objc func presentLocation() {
        performSegue(withIdentifier: FilterLocationViewController.identifier, sender: self)

    }
    
    //註冊鍵盤監聽
    func keyboardNotificationSetting() {
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyborad), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
   
    
    @objc func showKeyboard(_ notification: NSNotification) {
        guard let info = notification.userInfo,
              let keyboardFrameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardSize = keyboardFrame.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func hideKeyborad(_ notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
    //日期選擇
    func datePickerSetting() {
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControl.Event.valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.datePickerMode = .date
        datePicker.date = Date()
        datePicker.locale = Locale(identifier: "zh_CN")
        birth.inputView = datePicker
    }
    
    @objc func dateChange(datePicker: UIDatePicker) {
        birth.text = TimeManager.shared.formatBirthDate(date: datePicker.date)
        birthDate = datePicker.date
    }
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }

}

extension SignupPageViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == account{
            password.becomeFirstResponder()
        }
        if textField == password{
            name.becomeFirstResponder()
        }
        if textField == name{
            birth.becomeFirstResponder()
        }
        if textField == birth{
            nickName.becomeFirstResponder()
        }
        if textField == nickName{
            themes.becomeFirstResponder()
        }
        if textField == themes{
            location.becomeFirstResponder()
        }
        if textField == location{
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == themes || textField == location {
            return false
        } else {
            return true
        }
    }

    
}

extension SignupPageViewController: UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
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
    }
}

