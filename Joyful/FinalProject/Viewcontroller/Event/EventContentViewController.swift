//
//  EventContentViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/19.
//

import UIKit
import MapKit

class EventContentViewController: UIViewController {
    
    static var identifier = "EventContentViewController"
    
    var data: EventData?
    
    var dataContent: EventContent?
        
    var geoCoder = CLGeocoder()
    
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var subject: UILabel!
    
    @IBOutlet weak var level: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var eventContent: UITextView!
    
    @IBOutlet weak var attendButton: UIButton!
    
    @IBAction func turnBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    //參加活動
    @IBAction func attendEvent(_ sender: Any) {
        guard let data = dataContent else {
            return
        }
        
        if let personadata = PersonalDataModel.shared.personalData {
            if TimeManager.shared.dateFormatterToDate(startTime: data.holdTime, endTime: data.endTime, currentTime: Date()){
                if data.account == personadata.account {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StreamingViewController.identifier)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true, completion: nil)
                } else {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: AudienceViewController.identifier)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true, completion: nil)
                }
                return
            }
        }

        EventDataModel.shared.attendEvent(eventID: data.eventId) { response in
            switch response {
            case .success(_):
                self.attendButton.titleLabel?.text = "已經報名！"
                break
            case .failure(_):
                break
            }
        }
        
        
    }
    
    @IBAction func shareEvent(_ sender: Any) {
        guard let dataContent = dataContent else {
            return
        }
        guard let shareURL = URL(string: "https://optimistic-ardinghelli-fa5907.netlify.app/events/\(dataContent.eventId)") else {
            return
        }
        let items:[Any] = [shareURL]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setEventContent()
        setAttendButton()
    }
    
    private func setAttendButton() {
        guard let personadata = PersonalDataModel.shared.personalData,
              let data = dataContent else { return }
        if TimeManager.shared.dateFormatterToDate(startTime: data.holdTime, endTime: data.endTime, currentTime: Date()){
            if data.account == personadata.account {
                self.attendButton.setTitle("開始活動！", for: .normal)
            } else {
                self.attendButton.setTitle("參加活動！", for: .normal)
            }
        } else {
            guard let eventData = self.data else { return }
            if eventData.attantAcount != nil {
                self.attendButton.setTitle("已經報名！", for: .normal)
            } else {
                self.attendButton.setTitle("我要報名！", for: .normal)
            }
        }
    }
    
    private func setEventContent() {
        guard let eventContent = dataContent else {
            return
        }
        if let photo = eventContent.picture, let url = URL(string: photo) {
            self.photo.sd_setImage(with: url, completed: nil)
        } else {
            photo.image = UIImage(named: "找不到")
        }
        subject.text = eventContent.subject
        level.text = eventContent.hardnessName
        level.backgroundColor = EventDataModel.shared.getLevelColor(level: eventContent.hardnessName)
        level.layer.cornerRadius = 5
        level.clipsToBounds = true
        let startTime = TimeManager.shared.dateFormatterWithTime(originString: eventContent.holdTime)
        let endTime = TimeManager.shared.dateFormatterWithTime(originString: eventContent.endTime)
        time.text = "\(startTime) ~ \(endTime)"
        time.layer.cornerRadius = 5
        time.clipsToBounds = true
        address.text = eventContent.place
        address.layer.cornerRadius = 5
        address.clipsToBounds = true
        if let price = eventContent.price {
            self.price.text = String(price)
        }
        price.layer.cornerRadius = 5
        price.clipsToBounds = true
        //地圖
        relocate(location: eventContent.place)
        //內容
        settingPostContnet(content: eventContent.wordContent)
    }
    
    //定位活動地點
    private func relocate(location: String = "台北市") {
        // 設置地圖顯示的範圍與中心點座標
        let latDelta = 0.003
        let longDelta = 0.003
        let currentLocationSpan = MKCoordinateSpan.init(latitudeDelta: latDelta, longitudeDelta: longDelta)
        geoCoder.geocodeAddressString(location) { placements, error in
            if error != nil {
                return
            }
            guard let place = placements?[0].location else { return }
            let lat = place.coordinate.latitude
            let lon = place.coordinate.longitude
            let center:CLLocation = CLLocation(latitude: lat, longitude: lon)
            let currentRegion = MKCoordinateRegion( center: center.coordinate, span: currentLocationSpan)
            let annotation = MKPointAnnotation()
            annotation.title = location
            annotation.subtitle = "您選定的位置"
            annotation.coordinate = place.coordinate
            self.map.addAnnotation(annotation)
            self.map.setRegion(currentRegion, animated: true)
            self.map.reloadInputViews()
        }
    }
    
    //設定活動內容文章
    func settingPostContnet(content: String) {
        let splitArr = content.split(separator: "\n")
        let mutableStr = NSMutableAttributedString()
        for i in 0..<splitArr.count {
            let string = splitArr[i]
            var position = mutableStr.length
            if string.contains("<IMG>") {
                var rawUrl = string
                let index = string.index(string.startIndex, offsetBy: 5)
                rawUrl = rawUrl[index...]
                var imgUrl = String(rawUrl)
                let secIndex = imgUrl.range(of: ".jpg")!
                let finalUrl = imgUrl.prefix(upTo: secIndex.upperBound)
                imgUrl = String(finalUrl)
                guard let url = URL(string: imgUrl) else {return}
                do {
                    let data = try Data(contentsOf: url)
                    let attachment = NSTextAttachment()
                    attachment.image = UIImage(data: data)
                    let width = self.eventContent.frame.width - 2 * 5
                    let height = view.frame.height/2
                    attachment.bounds = CGRect(x: 0, y: 0,
                                               width: width,
                                               height: height)
                    let attachImg = NSAttributedString(attachment: attachment)
                    mutableStr.insert(attachImg, at: position)
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                mutableStr.insert(NSAttributedString(string: String(string)), at: position)
            }
            position = mutableStr.length
            mutableStr.insert(NSAttributedString(string: "\n"), at: position)
        }
        self.eventContent.attributedText = mutableStr
        self.eventContent.font = UIFont.systemFont(ofSize: 25)
    }
}
