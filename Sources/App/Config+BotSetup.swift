//
//  Config+BotSetup.swift
//  FBChatbot
//
//  Created by Luis Fernando Mata on 24/05/17.
//
//

import Foundation

extension Config {
    public func setupBot() -> (appSecret: String, validationToken: String, pageAccessToken: String, serverURL: String)? {
        let botConfig = self["server","chatbot"]
        let appSecret = botConfig?["appSecret"]?.string ?? self["app","appSecret"]?.string
        let validationToken = botConfig?["validationToken"]?.string ?? self["app","validationToken"]?.string
        let pageAccessToken = botConfig?["pageAccessToken"]?.string ?? self["app","pageAccessToken"]?.string
        let serverURL = botConfig?["serverURL"]?.string ?? self["app","serverURL"]?.string
        if appSecret == nil || validationToken == nil || pageAccessToken == nil || serverURL == nil {
            return nil
        }
        if appSecret == "" || validationToken == "" || pageAccessToken == "" || serverURL == "" {
            return nil
        }
        
        return (appSecret: appSecret!, validationToken: validationToken!, pageAccessToken: pageAccessToken!, serverURL: serverURL!)
    }
}
