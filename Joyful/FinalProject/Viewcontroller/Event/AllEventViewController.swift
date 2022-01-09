//
//  AllEventViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/15.
//

import UIKit

class AllEventViewController: UIViewController {
    
    // MARK: 屬性
    
    @IBOutlet weak var tableview: UITableView!
    
    var dataload = 1
    
    // MARK: function
    
    //刪選完回來
    @IBAction func turnBackSegue(segue: UIStoryboardSegue) {
        switch segue.identifier {
        case "turnBackFromLocation":
            if let sourceVC = segue.source as? FilterLocationViewController {
                let location = sourceVC.personalLocation
                if location != "" {
                    let newLocation = LocationDataModel.shared.locationIndex(name: location)
                    PersonalDataModel.shared.delegate = self
                    PersonalDataModel.shared.updateLocation(location: newLocation)
                }
            }
        case "turnBackFromTheme":
            if let sourceVC = segue.source as? FilterThemePageViewController {
                let theme = sourceVC.themes
                if !theme.isEmpty {
                    PersonalDataModel.shared.delegate = self
                    if let newthemes = ThemeDataModel.shared.themesIndex(themes: theme) {
                        PersonalDataModel.shared.updateTheme(themes: newthemes)
                    }
                }
            }            
        default:
            break
        }
    }
            
    //跳轉篩選主題
    @IBAction func filterTheme(_ sender: Any) {
        performSegue(withIdentifier: FilterThemePageViewController.identifier, sender: self)
    }

    //跳轉篩選地區
    @IBAction func filterLocation(_ sender: Any) {
        performSegue(withIdentifier: FilterLocationViewController.identifier, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: EventTableViewCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EventDataModel.shared.delegate = self
        dataload = 1
        EventDataModel.shared.fetchOnsiteEvent(page: dataload)
        ThemeDataModel.shared.getThemes()
    }

}

//表格區
extension AllEventViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print(EventDataModel.shared.onsiteEventAmt())
        return EventDataModel.shared.onsiteEventAmt()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath) as? EventTableViewCell else {
            return UITableViewCell()
        }
        guard let data = EventDataModel.shared.getOnsiteEventDetail(index: indexPath)?.event else {
            return UITableViewCell()
        }
        var register = false
        if EventDataModel.shared.getOnsiteEventDetail(index: indexPath)?.attantAcount != nil {
            register = true
        }
        cell.settingCell(photoUrl: data.picture, level: data.hardnessName, title: data.subject, price: data.price, location: data.areaName, date: data.holdTime, registered: register)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: EventContentViewController.identifier) as! EventContentViewController
        guard let data = EventDataModel.shared.getOnsiteEventDetail(index: indexPath) else {
            return
        }
        vc.data = data
        vc.dataContent = data.event
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension AllEventViewController: EventDataModelDelegate {
    func updateEventData() {
        self.tableview.reloadData()
    }
}

extension AllEventViewController: PersonalDataModelDelegate {
    func updatePersonData() {
        EventDataModel.shared.fetchOnsiteEvent(page: 1)
    }
}

//往下滑page+1
extension AllEventViewController: UISceneDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView.contentSize.height > self.tableview.frame.height else { return }
        if scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y) <= -5 {
            dataload += 1
            TopicDataModel.shared.fetchHotTopicData(page: dataload)
        }
    }
}
