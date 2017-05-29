//
//  Models.swift
//  FBChatbot
//
//  Created by Luis Fernando Mata on 29/05/17.
//
//

import App
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

struct Message {
    var textString = ""
    let sendJson: [String: AnyObject]
    
    init(message: JSON) {
        let senderID: String = (message["sender"]?["id"]?.string)!
        if let textString = message["message"]?["text"]?.string {
            self.textString = textString
        }
        
        let idJson: [String:String] = ["id": senderID]
        let textJson: [String: String] = ["text": self.textString]
        
        self.sendJson = ["recipient": idJson as AnyObject, "message": textJson as AnyObject]
    }
    
}
