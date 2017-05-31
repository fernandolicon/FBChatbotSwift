//
//  String+DotKey.swift
//  FBChatbot
//
//  Created by Luis Fernando Mata on 31/05/17.
//
//

import Foundation

extension String {
    public var dk: DotKey {
        return DotKey(self)
    }
}
