//
//  FilterThemePageViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/16.
//

import UIKit

class FilterThemePageViewController: UIViewController {
    
    static var identifier = "FilterThemePageViewController"
    
    var themes: [String] = []
    
    @IBAction func confirm(_ sender: Any) {
        //更新Data
        for i in 1...ThemeDataModel.shared.allThemes.count {
            if let theme = ThemeDataModel.shared.themeName(index: i) {
                themes.append(theme)
            }
        }
        
        //更新畫面
        collectionview.reloadData()
    }
    
    @IBAction func removeAll(_ sender: Any) {
        //更新Data
        themes = []
        
        //更新畫面
        collectionview.reloadData()
    }
    
    @IBOutlet weak var collectionview: UICollectionView!
    
    lazy var collectionviewLayout: UICollectionViewLayout = {
        
        //表格設定
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5) , heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        //表格群設定
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.4))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        //區塊設定
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionview.register(UINib(nibName: "ThemeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ThemeCollectionViewCell.identifier)
        collectionview.collectionViewLayout = collectionviewLayout
        PersonalDataModel.shared.delegate = self
        PersonalDataModel.shared.fetchPersonalData()
    }
    
}

extension FilterThemePageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ThemeDataModel.shared.allThemes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThemeCollectionViewCell.identifier, for: indexPath) as? ThemeCollectionViewCell else {
            return UICollectionViewCell()
        }
        let data = ThemeDataModel.shared.getDataDetail(index: indexPath.item)
        cell.setCell(title: data.title, imgUrl: data.imageurl)
        
        //如果我喜歡的主題有這個 -> check
        if themes.contains(where: { theme in
            return theme == data.title
        }) {
            cell.check = true
        } else {
            cell.check = false
        }
        
        if cell.check {
            cell.checkView.isHidden = false
        } else {
            cell.checkView.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let cell = collectionView.cellForItem(at: indexPath) as? ThemeCollectionViewCell else { return }
        //我喜歡的主題增減
        cell.checkView.isHidden = !cell.checkView.isHidden
        let theme = ThemeDataModel.shared.getDataDetail(index: indexPath.item).title
        if themes.contains(theme) {
            guard let index = themes.firstIndex(of: theme) else { return }
            themes.remove(at: index)
        } else {
            themes.append(theme)
        }
    }
    
}

extension FilterThemePageViewController: PersonalDataModelDelegate {
    func updatePersonData() {
        if let personInterest = PersonalDataModel.shared.personInterest{
            var interestArr:[String] = []
            for i in 0..<personInterest.count {
                if let theme = ThemeDataModel.shared.themeName(index: personInterest[i]) {
                    interestArr.append(theme)
                }
            }
            themes = interestArr
        }
        collectionview.reloadData()
    }
    
}
