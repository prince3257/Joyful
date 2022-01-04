//
//  SearchThemeViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/17.
//

import UIKit

class SearchThemeViewController: UIViewController {
    
    static var identifier = "SearchThemeViewController"

    @IBOutlet weak var searchBar: UITextField!{
        didSet {
            searchBar.attributedPlaceholder = NSAttributedString(
                string: "搜尋主題",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        }
    }
    
    @IBOutlet weak var tableview: UITableView!
    
    var theme = ""
    
    var selectTheme: EventData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.register(UINib(nibName: "SearchThemeTableViewCell", bundle: nil), forCellReuseIdentifier: SearchThemeTableViewCell.identifier)
        ThemeDataModel.shared.getThemes()
    }
    
}

extension SearchThemeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ThemeDataModel.shared.presentTheme.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchThemeTableViewCell.identifier, for: indexPath) as? SearchThemeTableViewCell else {
            return UITableViewCell()
        }
        let data = ThemeDataModel.shared.getDataDetail(index: indexPath.section)
        cell.setCell(title: data.title, imgUrl: data.imageurl)
        if data.title == theme {
            cell.checkMark.isHidden = false
        } else {
            cell.checkMark.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = ThemeDataModel.shared.getDataDetail(index: indexPath.section)
        searchBar.text = data.title
        theme = data.title
        tableview.reloadData()
    }
}

extension SearchThemeViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let oldText = textField.text,
           let updaterange = Range(range, in: oldText) {
            let newText = oldText.replacingCharacters(in: updaterange, with: string)
            
            if newText == ""{
                ThemeDataModel.shared.getThemes()
                print(ThemeDataModel.shared.presentTheme.count)
            } else {
                ThemeDataModel.shared.getThemes(themeName: newText)
                print(ThemeDataModel.shared.presentTheme.count)
            }
        }
        tableview.reloadData()
        return true
    }
}
