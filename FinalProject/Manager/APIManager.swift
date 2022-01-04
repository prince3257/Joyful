//
//  APIManager.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/18.
//

import Foundation
import SwiftKeychainWrapper
import Alamofire



class APIManager: NSObject {
    
    static var shared = APIManager()
    
    let certificates: [Data] = []
    
    private override init() {}
    
    // MARK: 登入註冊相關
    
    //登入(OK)
    func login(with account: String, with password: String, completion: @escaping (Result<Bool, Error>) -> Void ) {
        let url = "https://stoked-cirrus-333609.appspot.com/api/Member/logintoken"
        
        let headers: HTTPHeaders = [.contentType("application/json")]
        let parameter: [String:String] = ["account":account,"password":password]
        
        AF.request(url, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: headers).response { response in
            if response.error != nil {
                print("[Login]登入失敗，無法取得回傳資料")
                completion(.failure(response.error!))
            }
            switch response.result{
            case .success(let data):
                do {
                    guard let data = data else { return }
                    let json = try JSONDecoder().decode(TokenModel.self, from: data) as TokenModel
                    guard let accessToken = json.token,
                          let refreshToken = json.refreshToken else { return }
                    if KeychainWrapper.standard.set(accessToken, forKey: "accessToken") {
                        print("[Login]成功紀錄AccessToken")
                    }
                    if KeychainWrapper.standard.set(refreshToken, forKey: "refreshToken") {
                        print("[Login]成功紀錄RefreshToken")
                    }
                    if KeychainWrapper.standard.set(account, forKey: "account") {
                        print("[Login]成功紀錄Account")
                    }
                    print("[Login]登入成功")
                    completion(.success(true))
                } catch let error {
                    print("[Login]紀錄Token有問題\(error.localizedDescription)")
                    completion(.failure(error))
                }
                break
            case .failure(let error):
                print("[Login]登入失敗")
                completion(.failure(error))
                break
            }
        }
    }
    
    //註冊(OK)
    func signup(account: String, password: String, name: String,nickName: String, birthday: String, avatar: String?, completion: @escaping (Result<Bool, Error>) -> Void ) {
        let url = "https://stoked-cirrus-333609.appspot.com/api/Member/register"
        let headers: HTTPHeaders = [.contentType("application/json")]
        var parameter: [String:String] = ["account":account,"password":password,"name":name,"nickname": nickName,"birthday":birthday]
        if let avatar = avatar {
            parameter.updateValue(avatar, forKey: "avatar")
        }
        AF.request(url, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: headers).response { response in
            if response.error != nil {
                print("[SignUp]註冊失敗，無法取得回傳資料")
                completion(.failure(response.error!))
            }
            switch response.result{
            case .success(_):
                print("[SignUp]註冊成功！")
                if KeychainWrapper.standard.set(account, forKey: "account") {
                    print("[SignUp]成功紀錄Account")
                }
                completion(.success(true))
                break
            case .failure(let error):
                print("[SignUp]註冊失敗")
                completion(.failure(error))
                break
            }
        }
    }
    
    //檢查登入狀態(OK)
    func checkLogedIn() -> Bool {
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        if accessToken != nil {
            print("[SignIn]預設登入成功，使用暫存Token")
            return true
        }
        print("[SignIn]預設登入失敗，找不到暫存Token")
        return false
    }
    
    //登出(OK)
    func signOut() {
        print("[SignOut]登出成功，刪除暫存Token")
        KeychainWrapper.standard.removeObject(forKey: "accessToken")
        KeychainWrapper.standard.removeObject(forKey: "refreshToken")
        KeychainWrapper.standard.removeObject(forKey: "account")
    }
    
    // MARK: 上傳資料區
    
    //更換大頭照(OK)
    func uploadProfilePhoto(imgUrl: String, completion: @escaping ((Result<Bool, Error>) -> Void)) {
        guard let account = KeychainWrapper.standard.string(forKey: "account"),
              let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
            print("[Personl-ProfilePhoto]錯誤 -> 找不到Account或AccessToken")
            completion(.success(false))
            return
        }
        guard let url = URL(string: "https://stoked-cirrus-333609.appspot.com/api/Member/updatePersonalData") else {
            print("[Personl-ProfilePhoto]錯誤，連結失敗")
            return
        }
        let headers: HTTPHeaders = [.contentType("application/json"), .authorization(bearerToken: token)]
        let parameter: [String:Any] = ["avatar":imgUrl,"account":account]
        AF.request(url, method: .patch, parameters: parameter, encoding: JSONEncoding.default, headers: headers).response { response in
            if response.error != nil {
                print("[Personl-ProfilePhoto]上傳照片失敗，無法取得回傳資料")
                completion(.failure(response.error!))
            }
            switch response.result{
            case .success(_):
                print("[Personl-ProfilePhoto]已上傳照片")
                completion(.success(true))
                break
            case .failure(let error):
                print("[Personl-ProfilePhoto]錯誤，無法上傳照片")
                completion(.failure(error))
                break
            }
        }
    }
    
    //上傳主題(OK)
    func uploadThemes(themes: [Int],completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = "https://stoked-cirrus-333609.appspot.com/api/Member/maintainInterest"
        
        guard let account = KeychainWrapper.standard.string(forKey: "account") else {
                  print("[uploadThemes]上傳主題失敗 -> 找不到Account或AccessToken")
                  completion(.success(false))
                  return
              }
        let headers: HTTPHeaders = [.contentType("application/json")]
        let parameter: [String:Any] = ["account":account,"interestArr":themes]
        
        AF.request(url, method: .put, parameters: parameter, encoding: JSONEncoding.default, headers: headers).response { response in
            if response.error != nil {
                print("[uploadThemes]上傳主題失敗，無法取得回傳資料")
                completion(.failure(response.error!))
            }
            switch response.result{
            case .success(_):
                print("[uploadThemes]上傳主題成功")
                completion(.success(true))
                break
            case .failure(let error):
                print("[uploadThemes]上傳主題失敗")
                completion(.failure(error))
                break
            }
        }
    }
    
    //上傳地區(OK)
    func uploadlocation(location: Int,completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = "https://stoked-cirrus-333609.appspot.com/api/Member/maintainLocation"
        guard let account = KeychainWrapper.standard.string(forKey: "account") else {
            print("[uploadLocation]上傳主題失敗 -> 找不到Account或AccessToken")
            completion(.success(false))
            return
        }
        let headers: HTTPHeaders = [.contentType("application/json")]
        let parameter: [String:Any] = ["account":account,"areaID":location]
        
        AF.request(url, method: .put, parameters: parameter, encoding: JSONEncoding.default, headers: headers).response { response in
            if response.error != nil {
                print("[uploadLocation]上傳地區失敗，無法取得回傳資料")
                completion(.failure(response.error!))
            }
            switch response.result{
            case .success(_):
                print("[uploadLocation]上傳地區成功")
                completion(.success(true))
                break
            case .failure(let error):
                print("[uploadLocation]上傳地區失敗")
                completion(.failure(error))
                break
            }
        }
    }
    
    //上傳圖片(OK)
    func uploadImg(uploadImage: UIImage,name: String ,completion: @escaping (Result<ImageData, Error>) -> Void){
        guard let imgData = uploadImage.jpegData(compressionQuality: 0.5) else {
            print("[uploadImage]上傳圖片失敗，轉換JpegData有誤")
            return
        }
        let headers: HTTPHeaders = [.authorization("Client-ID 05b6a90f6d2df8e")]
        
        AF.upload(multipartFormData: { data in
            data.append(imgData, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
            data.append(name.data(using: String.Encoding.utf8)!, withName: "title")

        }, to: "https://api.imgur.com/3/image", headers: headers).response(completionHandler: { response in
            switch response.result {
            case .success(let data):
                guard let data = data else {return}
                print("[uploadImage]上傳圖片成功")
                let object = try? JSONDecoder().decode(ImageData.self, from: data) as ImageData
                guard let object = object else { return }
                completion(.success(object))
                break
            case .failure(let error):
                print("[uploadImage]上傳圖片失敗")
                completion(.failure(error))
                break
            }
        })
    }
    
    //上傳文章(OK)
    func uploadArticle(article: TopicDataUpload, completion: @escaping ((Result<Bool, Error>) -> Void)) {
        guard let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
            print("[Topic-Upload]錯誤 -> 找不到Account或AccessToken")
            return
        }
        guard let url = URL(string: "https://stoked-cirrus-333609.appspot.com/api/Social/Article") else {
            print("[Topic-Upload]錯誤，連結失敗")
            return
        }
        do {
            let jsonData = try JSONEncoder().encode(article)
            var request = URLRequest(url: url)
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.method = .post
            AF.request(request).response { response in
                switch response.result {
                case .success(_):
                    print("[Topic-Upload]成功上傳文章")
                    completion(.success(true))
                    break
                case .failure(let error):
                    print("[Topic-Upload]錯誤，上傳文章失敗")
                    completion(.failure(error))
                    break
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //上傳留言(OK)
    func uploadMessage(message: MessageUpload, completion: @escaping ((Result<Bool, Error>) -> Void)) {
        guard let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
            print("[Message-Upload]錯誤 -> 找不到Account或AccessToken")
            return
        }
        guard let url = URL(string: "https://stoked-cirrus-333609.appspot.com/api/Social/Message") else {
            print("[Message-Upload]錯誤，連結失敗")
            return
        }
        do {
            let jsonData = try JSONEncoder().encode(message)
            var request = URLRequest(url: url)
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.method = .post
            AF.request(request).response { response in
                switch response.result {
                case .success(_):
                    print("[Message-Upload]成功上傳留言")
                    completion(.success(true))
                    break
                case .failure(let error):
                    print("[Message-Upload]錯誤，上傳留言失敗")
                    completion(.failure(error))
                    break
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //上傳文章按讚(OK)
    func uploadLikeArticle(articleID: Int, completion: @escaping ((Result<Bool, Error>) -> Void)) {
        guard let account = KeychainWrapper.standard.string(forKey: "account"),
              let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
            print("[Topic-Like]錯誤 -> 找不到Account或AccessToken")
            completion(.success(false))
            return
        }
        guard let url = URL(string: "https://stoked-cirrus-333609.appspot.com/api/Social/Article") else {
            print("[Topic-Like]錯誤，連結失敗")
            return
        }
        let headers: HTTPHeaders = [.contentType("application/json"), .authorization(bearerToken: token)]
        let parameter: [String:Any] = ["articleId":articleID,"account":account]
        AF.request(url, method: .patch, parameters: parameter, encoding: JSONEncoding.default, headers: headers).response { response in
            if response.error != nil {
                print("[Topic-Like]按讚文章失敗，無法取得回傳資料")
                completion(.failure(response.error!))
            }
            switch response.result{
            case .success(_):
                print("[Topic-Like]已按讚文章")
                completion(.success(true))
                break
            case .failure(let error):
                print("[Topic-Like]錯誤，無法按讚文章")
                completion(.failure(error))
                break
            }
        }
    }
    
    //上傳文章收藏(OK)
    func uploadSaveArticle(articleID: Int, completion: @escaping ((Result<Bool, Error>) -> Void)) {
        guard let url = URL(string: "https://stoked-cirrus-333609.appspot.com/api/Social/Article/collect") else {
            print("[Topic-Save]錯誤，連結失敗")
            return
        }
        guard let account = KeychainWrapper.standard.string(forKey: "account"),
              let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
                  print("[Topic-Save]錯誤 -> 找不到Account或AccessToken")
                  return
              }
        let headers: HTTPHeaders = [ .contentType("application/json"), .authorization(bearerToken: token)]
        let parameter:[String:Any] = ["articleId": articleID, "account": account]
        AF.request(url,method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: headers).response { response in
            switch response.result {
            case .success(_):
                print("[Topic-Save]成功，取得資料")
                completion(.success(true))
                break
            case .failure(let error):
                print("[Topic-Save]錯誤，取得資料失敗")
                completion(.failure(error))
                break
            }
        }
    }

    
    //上傳留言按讚(OK)
    func uploadLikedMessage(messageID: Int, completion: @escaping ((Result<Bool, Error>) -> Void)) {
        guard let account = KeychainWrapper.standard.string(forKey: "account"),
              let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
            print("[Message-Like]錯誤 -> 找不到Account或AccessToken")
            completion(.success(false))
            return
        }
        guard let url = URL(string: "https://stoked-cirrus-333609.appspot.com/api/Social/Message") else {
            print("[Message-Like]錯誤，連結失敗")
            return
        }
        let headers: HTTPHeaders = [.contentType("application/json"), .authorization(bearerToken: token)]
        let parameter: [String:Any] = ["messageID":messageID,"account":account]
        AF.request(url, method: .patch, parameters: parameter, encoding: JSONEncoding.default, headers: headers).response { response in
            if response.error != nil {
                print("[Message-Like]按讚留言失敗，無法取得回傳資料")
                completion(.failure(response.error!))
            }
            switch response.result{
            case .success(_):
                print("[Message-Like]已按讚留言")
                completion(.success(true))
                break
            case .failure(let error):
                print("[Message-Like]錯誤，無法按讚留言")
                completion(.failure(error))
                break
            }
        }
    }
    
    //上傳活動(OK)
    func uploadEvent(event: EventDataUpload, completion: @escaping ((Result<Bool, Error>) -> Void)) {
        guard let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
            print("[Event-Upload]錯誤 -> 找不到Account或AccessToken")
            return
        }
        guard let url = URL(string: "https://stoked-cirrus-333609.appspot.com/api/Social/Event") else {
            print("[Event-Upload]錯誤，連結失敗")
            return
        }
        do {
            let jsonData = try JSONEncoder().encode(event)
            var request = URLRequest(url: url)
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.method = .post
            AF.request(request).response { response in
                switch response.result {
                case .success(_):
                    print("[Event-Upload]成功上傳活動")
                    completion(.success(true))
                    break
                case .failure(let error):
                    print("[Event-Upload]錯誤，上傳活動失敗")
                    completion(.failure(error))
                    break
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //參加活動(OK)
    func attendEvent(eventID: Int, completion: @escaping ((Result<Bool, Error>) -> Void)) {
        guard let account = KeychainWrapper.standard.string(forKey: "account"),
              let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
            print("[Event-Attend]錯誤 -> 找不到Account或AccessToken")
            completion(.success(false))
            return
        }
        guard let url = URL(string: "https://stoked-cirrus-333609.appspot.com/api/Social/Event") else {
            print("[Event-Attend]錯誤，連結失敗")
            return
        }
        let headers: HTTPHeaders = [.contentType("application/json"), .authorization(bearerToken: token)]
        let parameter: [String:Any] = ["eventId":eventID,"account":account]
        AF.request(url, method: .patch, parameters: parameter, encoding: JSONEncoding.default, headers: headers).response { response in
            if response.error != nil {
                print("[Event-Attend]參加活動失敗，無法取得回傳資料")
                completion(.failure(response.error!))
            }
            switch response.result{
            case .success(_):
                print("[Event-Attend]已參加活動")
                completion(.success(true))
                break
            case .failure(let error):
                print("[Event-Attend]錯誤，無法參加活動")
                completion(.failure(error))
                break
            }
        }
    }
    
    // MARK: 取得資料區
    
    //取得個人資料(OK)
    func getPersonalData(completion: @escaping ((Result<PersonalData, Error>)-> Void)) {
        guard let account = KeychainWrapper.standard.string(forKey: "account"),
              let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
            print("[Personl-Data]錯誤 -> 找不到Account或AccessToken")
            return
        }
        let headers: HTTPHeaders = [.contentType("application/json"), .authorization(bearerToken: token)]
        guard let url = URL(string: "https://stoked-cirrus-333609.appspot.com/api/Member/personalData?account=\(account)") else {
            print("[Personl-Data]錯誤，連結失敗")
            return
        }
        AF.request(url, method: .post, headers: headers).response { response in
            switch response.result {
            case .success(let data):
                guard let data = data else { return }
                do {
                    let object = try JSONDecoder().decode(PersonalData.self, from: data)
                    print("[Personl-Data]成功，取得資料")
                    completion(.success(object))
                } catch let error {
                    print("Personal有問題 -> \(error.localizedDescription)")
                }
                break
            case .failure(let error):
                print("[Personl-Data]錯誤，取得資料失敗")
                completion(.failure(error))
                break
            }
        }
    }
    
    //取得個人發布、收藏文章(OK)
    func getPersonalRelatedArticle(page:Int, articleType:ArticleType ,completion: @escaping ((Result<[TopicContent], Error>)-> Void)) {
        guard let account = KeychainWrapper.standard.string(forKey: "account"),
              let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
            print("[Personl-RelatedArticle]錯誤 -> 找不到Account或AccessToken")
            return
        }
        var urlName = "Posted"
        switch articleType {
        case .Posted:
            break
        case .Collected:
            urlName = "Collected"
            break
        }
        guard let url = URL(string: "https://stoked-cirrus-333609.appspot.com/api/Individual/\(urlName)Article") else {
            print("[Personl-RelatedArticle]錯誤，連結失敗")
            return
        }
        let headers: HTTPHeaders = [.contentType("application/json"), .authorization(bearerToken: token)]
        let parameter: [String:Any] = ["page":page, "account":account]
        AF.request(url, method: .post,parameters: parameter,encoding: JSONEncoding.default, headers: headers).response { response in
            switch response.result {
            case .success(let data):
                guard let data = data else { return }
                do {
                    let object = try JSONDecoder().decode([TopicContent].self, from: data)
                    print("[Personl-RelatedArticle]成功，取得資料")
                    completion(.success(object))
                } catch let error {
                    print("[Personl-RelatedArticle]有問題 -> \(error.localizedDescription)")
                }
                break
            case .failure(let error):
                print("[Personl-RelatedArticle]錯誤，取得資料失敗")
                completion(.failure(error))
                break
            }
        }
    }
    
    //取得個人參加過、發起活動(OK)
    func getPersonalRelatedEvent(page:Int,completion: @escaping ((Result<[EventContent], Error>)-> Void)) {
        guard let account = KeychainWrapper.standard.string(forKey: "account"),
              let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
            print("[Personl-RelatedEvent]錯誤 -> 找不到Account或AccessToken")
            return
        }
        guard let url = URL(string: "https://stoked-cirrus-333609.appspot.com/api/Individual/RelatedEvent") else {
            print("[Personl-RelatedEvent]錯誤，連結失敗")
            return
        }
        let headers: HTTPHeaders = [.contentType("application/json"), .authorization(bearerToken: token)]
        let parameter: [String:Any] = ["page":page, "account":account,  "isCombinePostedAndAttent": true ]
        AF.request(url, method: .post,parameters: parameter,encoding: JSONEncoding.default, headers: headers).response { response in
            switch response.result {
            case .success(let data):
                guard let data = data else { return }
                do {
                    let object = try JSONDecoder().decode([EventContent].self, from: data)
                    print("[Personl-RelatedEvent]成功，取得資料")
                    completion(.success(object))
                } catch let error {
                    print("[Personl-RelatedEvent]有問題 -> \(error.localizedDescription)")
                }
                break
            case .failure(let error):
                print("[Personl-RelatedEvent]錯誤，取得資料失敗")
                completion(.failure(error))
                break
            }
        }
    }
    
    //取得個人興趣(OK)
    func getPersonalInterest(completion: @escaping ((Result<[String], Error>)-> Void)) {
        guard let account = PersonalDataModel.shared.personalData?.account,
              let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
            print("[Personl-Interest]錯誤 -> 找不到Account或AccessToken")
            return
        }
        let headers: HTTPHeaders = [.contentType("application/json"), .authorization(bearerToken: token)]
        guard let url = URL(string: "https://stoked-cirrus-333609.appspot.com/api/Member/personalInterest?account=\(account)") else {
            print("[Personl-Interest]錯誤，連結失敗")
            return
        }
        AF.request(url, method: .get, headers: headers).response { response in
            switch response.result {
            case .success(let data):
                guard let data = data else { return }
                guard let object = try? JSONDecoder().decode([String].self, from: data) else {
                    print("[Personl-Interest]錯誤，無法轉換JSON")
                    return
                }
                print("[Personl-Interest]成功，取得資料")
                completion(.success(object))
                break
            case .failure(let error):
                print("[Personl-Interest]錯誤，取得資料失敗")
                completion(.failure(error))
                break
            }
        }
    }
    
    //取得個人地區(OK)
    func getPersonalLocation(completion: @escaping ((Result<String, Error>)-> Void)) {
        guard let account = KeychainWrapper.standard.string(forKey: "accessToken") ,
              let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
            print("[Personl-Location]錯誤 -> 找不到Account或AccessToken")
            return
        }
        let headers: HTTPHeaders = [.contentType("application/json"), .authorization(bearerToken: token)]
        guard let url = URL(string: "https://stoked-cirrus-333609.appspot.com/api/Member/api/Member/personalLocation?account=\(account)") else {
            print("[Personl-Location]錯誤，連結失敗")
            return
        }
        AF.request(url, method: .get, headers: headers).response { response in
            switch response.result {
            case .success(let data):
                guard let data = data else { return }
                guard let object = try? JSONDecoder().decode(String.self, from: data) else {
                    print("[Personl-Location]錯誤，無法轉換JSON")
                    return
                }
                print("[Personl-Location]成功，取得資料")
                completion(.success(object))
                break
            case .failure(let error):
                print("[Personl-Location]錯誤，取得資料失敗")
                completion(.failure(error))
                break
            }
        }
    }
    
    //取得文章資料(OK)
    func getTopicData(topicType:TopicType,page:Int, completion: @escaping ((Result<[TopicData], Error>)-> Void)) {
        var urlName = "hot"
        switch topicType {
        case .HotTopic:
            break
        case .PersonalTopic:
            urlName = "personalized"
            break
        }
        guard let url = URL(string: "https://stoked-cirrus-333609.appspot.com/api/Social/Article/\(urlName)") else {
            print("[Topic-\(topicType)]錯誤，連結失敗")
            return
        }
        guard let account = KeychainWrapper.standard.string(forKey: "account"),
              let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
                  print("[Topic-\(topicType)]錯誤 -> 找不到Account或AccessToken")
                  return
              }
        let headers: HTTPHeaders = [ .contentType("application/json"), .authorization(bearerToken: token)]
        let parameter:[String:Any] = ["page": page, "account": account]
        AF.request(url,method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: headers).response { response in
            switch response.result {
            case .success(let data):
                guard let data = data else {
                    print("[Topic-\(topicType)]錯誤，無法取得資料")
                    return
                }
                if let object = try? JSONDecoder().decode([TopicData].self, from: data) {
                    completion(.success(object))
                    print("[Topic-\(topicType)]成功，取得資料")
                    return
                }
                print("[Topic-\(topicType)]錯誤，轉換資料")
                break
            case .failure(let error):
                print("[Topic-\(topicType)]錯誤，取得資料失敗")
                completion(.failure(error))
                break
            }
        }
    }
    
    //取得特定文章資料(OK)
    func getSpecificTopicData(topicID: Int, completion: @escaping ((Result<[TopicData], Error>)-> Void)) {
        guard let url = URL(string: "https://stoked-cirrus-333609.appspot.com/api/Social/Article/specific") else {
            print("[Topic-Specific]錯誤，連結失敗")
            return
        }
        guard let account = KeychainWrapper.standard.string(forKey: "account"),
                let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
                  print("[Topic-Specific]錯誤 -> 找不到Account或AccessToken")
                  return
              }
        let headers: HTTPHeaders = [ .contentType("application/json"), .authorization(bearerToken: token)]
        let parameter:[String:Any] = ["articleId":topicID,"account": account]
        AF.request(url,method: .post,parameters: parameter,encoding: JSONEncoding.default, headers: headers).response { response in
            switch response.result {
            case .success(let data):
                guard let data = data else {
                    print("[Topic-Specific]錯誤，無法取得資料")
                    return
                }
                if let object = try? JSONDecoder().decode([TopicData].self, from: data) {
                    completion(.success(object))
                    print("[Topic-Specific]成功，取得資料")
                    return
                }
                print("[Topic-Specific]錯誤，轉換資料")
                break
            case .failure(let error):
                print("[Topic-Specific]錯誤，取得資料失敗")
                completion(.failure(error))
                break
            }
        }
    }
    
    //取得文章留言(OK)
    func getTopicMessageData(articleID: Int,page:Int,completion: @escaping ((Result<[MessageData], Error>)-> Void)) {
        guard let url = URL(string: "https://stoked-cirrus-333609.appspot.com/api/Social/Message/belongArticle") else {
            print("[Topic-Message]錯誤，連結失敗")
            return
        }
        guard let token = KeychainWrapper.standard.string(forKey: "accessToken"),
              let account = KeychainWrapper.standard.string(forKey: "account") else {
                  print("[Topic-Message]錯誤 -> 找不到AccessToken")
                  return
              }
        let headers: HTTPHeaders = [ .authorization(bearerToken: token), .contentType("application/json")]
        let parameter: [String:Any] = ["page": page, "account":account, "articleId":articleID]
        AF.request(url,method: .post,parameters: parameter,encoding: JSONEncoding.default, headers: headers).response { response in
            switch response.result {
            case .success(let data):
                guard let data = data else {
                    print("[Topic-Message]成功，但資料為空")
                    return
                }
                guard let object = try? JSONDecoder().decode([MessageData].self, from: data) else {
                    print("[Topic-Message]錯誤，無法轉換JSON")
                    return
                }
                print("[Topic-Message]成功，取得資料")
                completion(.success(object))
                break
            case .failure(let error):
                print("[Topic-Message]錯誤，取得資料失敗")
                completion(.failure(error))
                break
            }
        }
    }
    
    //取得活動資料(OK)
    func getEventData(eventType: EventType, page:Int, completion: @escaping ((Result<[EventData], Error>)-> Void)) {
        var onlineType = false
        var urlName = "hot"
        switch eventType {
        case .HotEvent:
            break
        case .OnsiteEvent:
            urlName = "personalized"
            break
        case .OnlineEvent:
            onlineType = true
            urlName = "personalized"
            break
        }
        
        guard let url = URL(string: "https://stoked-cirrus-333609.appspot.com/api/Social/Event/\(urlName)") else {
            print("[Event-\(eventType)]錯誤，連結失敗")
            return
        }
        guard let account = KeychainWrapper.standard.string(forKey: "account"),
              let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
            print("[Event-\(eventType)]錯誤 -> 找不到Account或AccessToken")
            return
        }
        var headers: HTTPHeaders = [.contentType("application/json")]
        if eventType != .HotEvent {
            headers.add(.authorization(bearerToken: token))
        }
        let parameter:[String:Any] = ["page":page, "account":account, "isOnLine": onlineType]
        AF.request(url,method: .post,parameters: parameter,encoding: JSONEncoding.default, headers: headers).response { response in
            switch response.result {
            case .success(let data):
                guard let data = data else {
                    print("[Event-\(eventType)]錯誤，無法取得資料")
                    return
                }
                if let object = try? JSONDecoder().decode([EventData].self, from: data) {
                    print("[Event-\(eventType)]成功，取得資料")
                    completion(.success(object))
                    return
                }
                print("[Event-\(eventType)]錯誤，轉換資料")
                break
            case .failure(let error):
                print("[Event-\(eventType)]錯誤，取得資料失敗")
                completion(.failure(error))
                break
            }
        }
    }
    
    //取得特定活動資料(OK)
    func getSpecificEventData(eventID: String, completion: @escaping ((Result<[EventData], Error>)-> Void)) {
        guard let url = URL(string: "https://stoked-cirrus-333609.appspot.com/api/Social/Event/specific") else {
            print("[Event-Specific]錯誤，連結失敗")
            return
        }
        guard let account = KeychainWrapper.standard.string(forKey: "account"),
                let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
                  print("[Event-Specific]錯誤 -> 找不到Account或AccessToken")
                  return
              }
        let headers: HTTPHeaders = [ .contentType("application/json"), .authorization(bearerToken: token)]
        let parameter:[String:Any] = ["eventId":eventID,"account": account]
        AF.request(url,method: .post,parameters: parameter,encoding: JSONEncoding.default, headers: headers).response { response in
            switch response.result {
            case .success(let data):
                guard let data = data else {
                    print("[Event-Specific]錯誤，無法取得資料")
                    return
                }
                if let object = try? JSONDecoder().decode([EventData].self, from: data) {
                    completion(.success(object))
                    print("[Event-Specific]成功，取得資料")
                    return
                }
                print("[Event-Specific]錯誤，轉換資料")
                break
            case .failure(let error):
                print("[Event-Specific]錯誤，取得資料失敗")
                completion(.failure(error))
                break
            }
        }
    }
    
    //取得每月挑戰影片(OK)
    func getChallengeVideoData(completion: @escaping ((Result<VideoData, Error>)-> Void)) {
        guard let url = URL(string: "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet,contentDetails,status&playlistId=\(Info.playlistID)&key=\(Info.APIKEY)&maxResults=10") else {
            print("[Challenge-Video]錯誤，連結失敗")
            return
        }
        let headers: HTTPHeaders = [ .contentType("application/json")]
        AF.request(url,headers: headers).response { response in
            switch response.result {
            case .success(let data):
                guard let data = data else {
                    print("[Challenge-Video]成功，但資料為空")
                    return
                }
                guard let object = try? JSONDecoder().decode(VideoData.self, from: data) else {
                    print("[Challenge-Video]錯誤，無法轉換JSON")
                    return
                }
                print("[Challenge-Video]成功，取得資料")
                completion(.success(object))
                break
            case .failure(let error):
                print("[Challenge-Video]錯誤，取得資料失敗")
                completion(.failure(error))
                break
            }
        }
    }
    
}

enum ArticleType {
    case Posted
    case Collected
}
