import App
import Darwin

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
    print("Missing config values")
    exit(1)
}

drop.get("webhook") { request in
    drop.console.print("get webhook", newLine: true)
	guard let token = request.data["hub.verify_token"]?.string else {
        drop.console.print("Couldn't get token", newLine: true)
		throw Abort.badRequest
	}
	guard let response = request.data["hub.challenge"]?.string else {
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

try drop.run()
