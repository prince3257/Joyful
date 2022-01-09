//
//  FilterLocationViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/16.
//

import UIKit
import CoreLocation
import MapKit

class FilterLocationViewController: UIViewController {

    static var identifier = "FilterLocationViewController"
    
    let myLocationManager = CLLocationManager()
    
    let geoCoder = CLGeocoder()
        
    var personalLocation = ""
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var myMapView: MKMapView!

    @IBOutlet weak var location: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PersonalDataModel.shared.delegate = self
        PersonalDataModel.shared.fetchPersonalData()
        location.text = personalLocation
        tableView.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: LocationTableViewCell.identifier)
        mapSetting()
        relocate()

    }
    
    private func relocate(location: String = "台北市") {
        // 設置地圖顯示的範圍與中心點座標
        let latDelta = 0.1
        let longDelta = 0.1
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
            self.myMapView.addAnnotation(annotation)
            self.myMapView.setRegion(currentRegion, animated: true)
            self.myMapView.reloadInputViews()
        }
    }
    
    
    private func mapSetting() {
        myLocationManager.delegate = self
        //移動多遠距離才觸發更新位置
        myLocationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        //取得自身定位的精確度
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 地圖樣式
        myMapView.mapType = .standard
        // 顯示自身定位位置
        myMapView.showsUserLocation = true
        // 允許縮放地圖
        myMapView.isZoomEnabled = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch myLocationManager.authorizationStatus {
        case .notDetermined:
            myLocationManager.requestWhenInUseAuthorization()
            myLocationManager.startUpdatingLocation()
        case .authorizedWhenInUse, .authorizedAlways:
            myLocationManager.startUpdatingLocation()
        case .denied, .restricted:
            AlertManager.shared.showAlert(title: "無法定位", headLine: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟", content: "返回確認", vc: self)
        @unknown default:
            myLocationManager.startUpdatingLocation()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        myLocationManager.stopUpdatingLocation()
    }
    

}

extension FilterLocationViewController: CLLocationManagerDelegate, MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "myMapPin"
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        return annotationView

    }
}

extension FilterLocationViewController: UITableViewDelegate, UITableViewDataSource {
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return LocationDataModel.shared.getLocationSectionAmt()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = LocationDataModel.shared.getLocationSection(section: section)
        if section.opened {
            return section.sectionData.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = LocationDataModel.shared.getLocationSection(section: indexPath.section)
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell") else {
                return UITableViewCell()
            }
            var content = cell.defaultContentConfiguration()
            content.text = section.title
            content.textProperties.alignment = .center
            content.textProperties.font = .systemFont(ofSize: 25, weight: .semibold)
            cell.contentConfiguration = content
            cell.backgroundColor = UIColor(red: 255/255, green: 199/255, blue: 89/255, alpha: 1)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell") as? LocationTableViewCell else {
                return UITableViewCell()
            }
            cell.title.text = section.sectionData[indexPath.row-1]
            if personalLocation == section.sectionData[indexPath.row-1] {
                cell.checked.isHidden = false
            } else {
                cell.checked.isHidden = true
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = LocationDataModel.shared.getLocationSection(section: indexPath.section)
        if indexPath.row == 0 {
            if !section.opened {
                section.opened = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            } else {
                section.opened = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
        } else {
            personalLocation = section.sectionData[indexPath.row-1]
            location.text = personalLocation
            relocate(location: personalLocation)
            tableView.reloadData()

        }
        
    }
    
    
}

extension FilterLocationViewController: PersonalDataModelDelegate {
    func updatePersonData() {
        if let location = PersonalDataModel.shared.personLocation,
           let name = LocationDataModel.shared.locationName(index: location){
            personalLocation = name
            self.location.text = personalLocation
        }
        tableView.reloadData()
        relocate(location: personalLocation)
    }
}
