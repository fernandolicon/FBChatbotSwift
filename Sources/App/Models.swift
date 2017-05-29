//
//  Models.swift
//  FBChatbot
//
//  Created by Luis Fernando Mata on 29/05/17.
//
//

import JSON
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

struct Message {
    var textString = ""
    let sendJson: [String: AnyObject]
    
    init(message: JSON) {
        
    }
    
}
