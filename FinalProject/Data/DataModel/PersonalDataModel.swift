//
//  PersonalDataModel.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/22.
//

import Foundation
import UIKit

protocol PersonalDataModelDelegate: AnyObject{
    func updatePersonData()
}

class PersonalDataModel {
    
    static var shared = PersonalDataModel()
    
    private init () {}
    
    var personalData: PersonalData?
    
    var personInterest: [Int]?
    
    var personLocation: Int?
    
    weak var delegate: PersonalDataModelDelegate?
    
    // MARK: 取得資料區

    //取得個人資料
    func fetchPersonalData() {
        APIManager.shared.getPersonalData { response in
            switch response {
            case .success(let data):
                self.personalData = data
                self.delegate?.updatePersonData()
            case .failure(_):
                break
            }
        }
    }
    
    //取得個人興趣
    func fetchPersonalInterest() {
        APIManager.shared.getPersonalInterest { response in
            switch response {
            case .success(let data):
                self.personInterest = ThemeDataModel.shared.themesIndex(themes: data)
            case .failure(_):
                break
            }
        }
    }
    
    //取得個人地區
    func fetchPersonalLocation() {
        APIManager.shared.getPersonalLocation { response in
            switch response {
            case .success(let data):
                self.personLocation = LocationDataModel.shared.locationIndex(name: data)
            case .failure(_):
                break
            }
        }
    }
    
    // MARK: 更新資料區
    
    // 更新個人資料 - 照片
    func updateProfilePhoto(imageUrl: String, completion: @escaping (Result<Bool, Error>) -> Void ) {
        APIManager.shared.uploadProfilePhoto(imgUrl: imageUrl) { response in
            switch response {
            case .success(let data):
                completion(.success(data))
                break
            case .failure(let error):
                completion(.failure(error))
                break
            }
        }
    }
    
    // 更新篩選條件 - 主題
    func updateTheme(themes: [Int]) {
        APIManager.shared.uploadThemes(themes: themes) { response in
            switch response {
            case .success(_):
                self.delegate?.updatePersonData()
                //回去call下載更新數據
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // 更新篩選條件 - 地區
    func updateLocation(location: Int) {
        APIManager.shared.uploadlocation(location: location) { response in
            switch response {
            case .success(_):
                self.delegate?.updatePersonData()
                //回去call下載更新數據
            case .failure(let error):
                print(error)
            }
        }
    }
    
    deinit{
        print{"PersonData Missing"}
    }
    
}
