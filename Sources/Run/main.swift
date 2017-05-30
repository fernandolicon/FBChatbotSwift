import App
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

/// We have isolated all of our App's logic into
/// the App module because it makes our app
/// more testable.
///
/// In general, the executable portion of our App
/// shouldn't include much more code than is presented
/// here.
///
/// We simply initialize our Droplet, optionally
/// passing in values if necessary
/// Then, we pass it to our App's setup function
/// this should setup all the routes and special
/// features of our app
///
/// .run() runs the Droplet's commands, 
/// if no command is given, it will default to "serve"
let config = try Config()
try config.setup()


let drop = try Droplet(config)
try drop.setup()

guard let botConfig = config.setupBot() else {
    drop.console.print("Missing config values", newLine: true)
    exit(1)
}

drop.get("webhook") { request in
    drop.console.print("Received get", newLine: true)
    let queryData = request.query?.wrapped.object
    
	guard let token = queryData?["hub.verify_token"]?.string else {
        drop.console.print("Couldn't get token", newLine: true)
		throw Abort.badRequest
	}
	guard let response = queryData?["hub.challenge"]?.string else {
        drop.console.print("Error in response", newLine: true)
		throw Abort.badRequest	
	}
    
    if token == botConfig.validationToken {
        drop.console.print("Everything is correct", newLine: true)
        return Response(status: .ok, body: response)
    } else {
        drop.console.print("Request doesn't come from Facebook", newLine: true)
        return Response(status: .forbidden)
    }
}

drop.post("webhook") { request in
    let url = "https://graph.facebook.com/v2.6/me/messages?access_token=" + botConfig.pageAccessToken
    let bytes = request.body.bytes
    let json = try JSON(bytes: bytes!)
    drop.console.print("\(json)", newLine: true)
    guard let entry: JSON = json["entry"]?.array?.first else {
        drop.console.print("Couldn't get message", newLine: true)
        return Response(status: .ok)
    }
    guard entry["object"]?.string == "page" else {
        drop.console.print("Message doesn't come from Facebook chat", newLine: true)
        return Response(status: .ok)
    }
    guard let messageJSON = entry["messaging"]?.array?.first else {
        drop.console.print("Couldn't get message", newLine: true)
        return Response(status: .ok)
    }
    let newMessage = Message(messagingJSON: messageJSON)
    drop.console.print(newMessage.description, newLine: true)
    
    return Response(status: .ok, body: "message")
}

try drop.run()
