//
//  Message.swift
//  FBChatbot
//
//  Created by Luis Fernando Mata on 30/05/17.
//
//

import Foundation
import CoreLocation
import JSON

class Message {
    var id: String?
    var text: String?
    var sender: String?
    var timeStamp: Int?
    var sequence: Int?
    var read: Bool?
    var attachments: [Attachment]?
    
    struct Keys {
        static let ID = "mid"
        static let MessagingJSON = "messaging"
        static let MessageJSON = "message"
        static let Sequence = "seq"
        static let Text = "text"
        static let AttachmentsArray = "attachments"
    }
    
    init() {}
    
    init(entryJSON: JSON) {
        if let messagingJSON = entryJSON[Keys.MessagingJSON] {
            if let messageJSON = messagingJSON[Keys.MessageJSON] {
                let auxString = messageJSON[Keys.Sequence]?.string ?? "0"
                self.sequence = Int(auxString)
                self.id = messageJSON[Keys.ID]?.string
                self.text = messageJSON[Keys.Text]?.string
                if let attachmentsArrayDict = messageJSON[Keys.AttachmentsArray]?.array {
                    attachments = [Attachment]()
                    for attachmentJSON in attachmentsArrayDict {
                        attachments!.append(Attachment(attachmentJSON: attachmentJSON))
                    }
                }
            }
        }
        
    }
}

struct Attachment {
    var type: AttachmentType?
    private var attachmentValue: String?
    var attachmentURL: URL? {
        get {
            return getURL()
        }
    }
    var location: CLLocationCoordinate2D?
    
    struct Keys {
        static let TypeName = "type"
        static let Payload = "payload"
        static let URL = "url"
        static let CoordinateLat = "coordinates.lat"
        static let CoordinateLong = "coordinates.long"
    }
    
    private func getURL() -> URL? {
        if self.type != .fallback, self.type != .location, let urlString = self.attachmentValue {
            return URL(string: urlString)
        }
        
        return nil
    }
    
    init(attachmentJSON: JSON) {
        let auxValue = attachmentJSON[Keys.TypeName]?.string ?? ""
        self.type = AttachmentType(rawValue: auxValue) ?? .none
        if let payloadJSON = attachmentJSON[Keys.Payload] {
            switch self.type! {
            case .audio, .file, .image, .video:
                    self.attachmentValue = payloadJSON[Keys.URL]?.string
                break
            case .location:
                var auxString = payloadJSON[Keys.CoordinateLat]?.string ?? "0.0"
                let latitude = Double(auxString) ?? 0.0
                auxString = payloadJSON[Keys.CoordinateLong]?.string ?? "0.0"
                let longitude = Double(auxString) ?? 0.0
                self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                break
            default: break
            }
        }
    }
}

enum AttachmentType: String {
    case audio = "audio"
    case fallback = "fallback"
    case file = "file"
    case image = "image"
    case video = "video"
    case location = "location"
    case none = ""
}
