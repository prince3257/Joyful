//
//  StreamingViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2022/1/1.
//

import UIKit
import OpenTok

class StreamingViewController: UIViewController {
    
    static let identifier = "StreamingViewController"

    private let apiKey = "47410291"

    private let sessionId = "1_MX40NzQxMDI5MX5-MTY0MTAwODU2Njg4Nn4rQzc3L0dMaFJuNCt3UldOR25vdXowQ3F-fg"
    
    //pulisher
    private let tokenP = "T1==cGFydG5lcl9pZD00NzQxMDI5MSZzaWc9OGU0YTRhMGEwY2MzZDIwNmZlNzUxMjEzZmQ5YjE3MTA5ZDcwYjVhYzpzZXNzaW9uX2lkPTFfTVg0ME56UXhNREk1TVg1LU1UWTBNVEF3T0RVMk5qZzRObjRyUXpjM0wwZE1hRkp1TkN0M1VsZE9SMjV2ZFhvd1EzRi1mZyZjcmVhdGVfdGltZT0xNjQxMDA4NzMyJm5vbmNlPTAuNDE5NTcwMDQ0MDA5MjAwMDYmcm9sZT1wdWJsaXNoZXImZXhwaXJlX3RpbWU9MTY0MzYwMDczMSZpbml0aWFsX2xheW91dF9jbGFzc19saXN0PQ=="
        
    private var session: OTSession?
    
    @IBOutlet weak var warningWords: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func StartStreaming(_ sender: Any) {
        warningWords.isHidden = true
        connectToSession()
    }
    
    @IBAction func EndStreaming(_ sender: Any) {
        var error: OTError?
        session?.disconnect(&error)
        
        if let error = error {
            print("連線有問題", error)
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func connectToSession() {
        session = OTSession(
            apiKey: apiKey,
            sessionId: sessionId,
            delegate: self
        )
        
        var error: OTError?
        session?.connect(withToken: tokenP, error: &error)
        
        if let error = error {
            print("連線有問題", error)
        }
    }
    
    private func publishCamera() {
        guard let publisher = OTPublisher(delegate: nil) else {
            return
        }
        
        var error: OTError?
        session?.publish(publisher, error: &error)
        
        if let error = error {
            print("推流有問題", error)
            return
        }
        
        guard let publisherView = publisher.view else {
            return
        }
        
        warningWords.isHidden = true
        publisherView.frame = UIScreen.main.bounds
        view.insertSubview(publisherView, at: 0)
    }
    
}

extension StreamingViewController: OTSessionDelegate {
    
    func sessionDidConnect(_ session: OTSession) {
        print("成功連結到網路(Session)")
        publishCamera()
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("無法連結到網路(Session)")
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("連接Streaming有誤: \(error).")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Streaming創建")
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Streaming結束")
    }
}
