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
    var attachments: [Attachment]?
    var description: String {
        return getDescription()
    }
    
    struct Keys {
        static let ID = "mid"
        static let MessagingJSON = "messaging"
        static let MessageJSON = "message"
        static let Sequence = "seq"
        static let Text = "text"
        static let AttachmentsArray = "attachments"
        static let Sender = "sender"
        static let SenderID = "id"
        static let TimeStamp = "timestamp"
    }
    
    init() {}
    
    init(messagingJSON: JSON) {
        var auxString: String?
        if let messageJSON = messagingJSON[Keys.MessageJSON] {
            auxString = messageJSON[Keys.Sequence]?.string
            self.sequence = auxString != nil ? Int(auxString!) : nil
            self.id = messageJSON[Keys.ID]?.string
            self.text = messageJSON[Keys.Text]?.string
            if let attachmentsArrayDict = messageJSON[Keys.AttachmentsArray]?.array {
                attachments = [Attachment]()
                for attachmentJSON in attachmentsArrayDict {
                    attachments!.append(Attachment(attachmentJSON: attachmentJSON))
                }
            }
            auxString = messageJSON[Keys.TimeStamp]?.string
            self.timeStamp = auxString != nil ? Int(auxString!) : nil
        }
        if let senderDict = messagingJSON[Keys.Sender] {
            self.sender = senderDict[Keys.SenderID]?.string
        }
    }
    
    private func getDescription() -> String {
        var descriptionMessages = [String]()
        if id != nil {
            descriptionMessages.append("MessageID: \(id!)")
        }
        if text != nil {
            descriptionMessages.append("Text: \(text!)")
        }
        if sender != nil {
            descriptionMessages.append("SenderID: \(sender!)")
        }
        if timeStamp != nil {
            descriptionMessages.append("TimeStamp: \(timeStamp!)")
        }
        if sequence != nil {
            descriptionMessages.append("Sequence: \(sequence!)")
        }
        if attachments != nil {
            for attachment in attachments! {
                if attachment.description != "nil" {
                    descriptionMessages.append("Attachment: [\(attachment.description)]")
                }
            }
        }
        var descriptionString = ""
        for (counter, value) in descriptionMessages.enumerated() {
            descriptionString += value
            if counter < descriptionMessages.count - 1 {
                descriptionString += ", "
            }
        }
        
        return descriptionString != "" ? descriptionString : "nil"
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
    var description: String {
        return getDescription()
    }
                
    
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
                self.attachmentValue = "Latitude: \(latitude), Longitude: \(longitude)"
                break
            default: break
            }
        }
    }
    
    private func getDescription() -> String {
        var descriptionMessages = [String]()
        if type != nil {
            let typeString = "TypeString: \(type!.rawValue)"
            descriptionMessages.append(typeString)
        }
        if attachmentValue != nil {
            let attachmentValuestring = "Value: \(attachmentValue!)"
            descriptionMessages.append(attachmentValuestring)
        }
        var descriptionString = ""
        for (counter, value) in descriptionMessages.enumerated() {
            descriptionString += value
            if counter < descriptionMessages.count - 1 {
                descriptionString += ", "
            }
        }
        
        return descriptionString != "" ? descriptionString : "nil"
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
