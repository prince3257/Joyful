//
//  VideoDataModel.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/30.
//

import Foundation



protocol VideoDataModelDelegate: AnyObject {
    func updateVideoData()
}

class VideoDataModel {

    static var shared = VideoDataModel()
    
    private init() {}
    
    weak var delegate: VideoDataModelDelegate?
    
    var videoData: VideoData?
    
    var videos: [SingleVideo]?
    
    func fetchVideoData(completion: @escaping (Result<Bool, Error>) -> Void ) {
        APIManager.shared.getChallengeVideoData { response in
            switch response {
            case .success(let data):
                self.videoData = data
//                if self.consolidateVideo() {
//                    completion(.success(true))
//                } else {
//                    completion(.success(false))
//                }
                completion(.success(self.consolidateVideo()))
                self.delegate?.updateVideoData()
                break
            case .failure(let error):
                print(error)
                completion(.failure(error))
                break
            }
        }
    }
    
    private func consolidateVideo() -> Bool {
        guard let videoData = videoData else {
            return false
        }
        videos = videoData.items
        return true
    }
    
    func getVideoAmt() -> Int {
        return videos?.count ?? 0
    }
    
    func getVideoData(index: IndexPath) -> SingleVideo? {
        guard let videos = videos else {
            return nil
        }
        if index.section < videos.count {
            return videos[index.section]
        } else {
            return nil
        }
    }
}
