import Foundation
import ArgumentParser
import ElevenLabs
import SharedKit

@main
struct Cmd: AsyncParsableCommand {
    
    static var configuration = CommandConfiguration(
        abstract: "A utility for interacting with the ElevenLabs API.",
        version: "0.0.1",
        subcommands: [
            SpeechCompletion.self,
        ]
    )
}

struct Options: ParsableArguments {
    @Option(help: "Your API token.")
    var token = ""
    
    @Option(help: "Model to use.")
    var model = ""
    
    @Argument(help: "Your messages.")
    var prompt = ""
}

struct SpeechCompletion: AsyncParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Completes a speech request.")
    
    @OptionGroup var options: Options
    
    func run() async throws {
        let client = ElevenLabsClient(token: options.token)
        let query = SpeechRequest(text: "Hello, world!")
        let data = try await client.speech(query, voice: "21m00Tcm4TlvDq8ikWAM")
        
        try FileHandle.standardOutput.write(contentsOf: data)
    }
}
