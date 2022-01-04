//
//  AudienceViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2022/1/1.
//

import UIKit
import OpenTok

class AudienceViewController: UIViewController {
    
    static let identifier = "AudienceViewController"

    private let apiKey = "47410291"
    
    private let sessionId = "1_MX40NzQxMDI5MX5-MTY0MTAwODU2Njg4Nn4rQzc3L0dMaFJuNCt3UldOR25vdXowQ3F-fg"
    
    //subscriber
    private let tokenS = "T1==cGFydG5lcl9pZD00NzQxMDI5MSZzaWc9Y2VlMzdiMmFkOThlMjk2NDIzOWM0ZjkyNTJjM2Y3ZDFhMmNlNTc4MDpzZXNzaW9uX2lkPTFfTVg0ME56UXhNREk1TVg1LU1UWTBNVEF3T0RVMk5qZzRObjRyUXpjM0wwZE1hRkp1TkN0M1VsZE9SMjV2ZFhvd1EzRi1mZyZjcmVhdGVfdGltZT0xNjQxMDIxMjU2Jm5vbmNlPTAuMTQzMTc5NjY5MzkxODEwODImcm9sZT1zdWJzY3JpYmVyJmV4cGlyZV90aW1lPTE2NDM2MTMyNTUmaW5pdGlhbF9sYXlvdXRfY2xhc3NfbGlzdD0="
        
    private var session: OTSession?
    
    @IBOutlet weak var warningWords: UILabel!
            
    @IBAction func leave(_ sender: Any) {
        var error: OTError?
        session?.disconnect(&error)
        
        if let error = error {
            print("連線有問題", error)
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectToSession()
    }
    
    private func connectToSession() {
        session = OTSession(
            apiKey: apiKey,
            sessionId: sessionId,
            delegate: self
        )
        
        var error: OTError?
        session?.connect(withToken: tokenS, error: &error)
        
        if let error = error {
            print("連線有問題", error)
        }
    }
    
    private func subscribe(to stream: OTStream) {
        guard let subscriber = OTSubscriber(stream: stream, delegate: nil) else {
            return
        }
        
        var error: OTError?
        session?.subscribe(subscriber, error: &error)
        
        if let error = error {
            print("無法連到Streaming", error)
            return
        }
        
        guard let subscriberView = subscriber.view else {
            return
        }
        warningWords.isHidden = true
        subscriberView.frame = UIScreen.main.bounds
        view.insertSubview(subscriberView, at: 0)
    }

}

extension AudienceViewController: OTSessionDelegate {
    
    func sessionDidConnect(_ session: OTSession) {
        print("成功連結到網路(Session)")
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("無法連結到網路(Session)")
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("連接Streaming有誤: \(error).")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Streaming創建")
        subscribe(to: stream)
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Streaming結束")
    }
    
}
