import Foundation
import ArgumentParser
import ElevenLabs

@main
struct CLI: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "A utility for interacting with the ElevenLabs API.",
        version: "0.0.1",
        subcommands: [
            Voices.self,
            SpeechCompletion.self,
            SpeechCompletionWithTimestamps.self,
        ]
    )
}

struct Options: ParsableArguments {
    @Option(help: "Your API token.")
    var token = ""
    
    @Option(help: "Model to use.")
    var model = "eleven_multilingual_v2"

    @Option(help: "Voice to use.")
    var voice = ""

    @Argument(help: "Your messages.")
    var prompt = "Hello, world!"
}

struct Voices: AsyncParsableCommand {
    @OptionGroup var options: Options

    func run() async throws {
        let client = Client(apiKey: options.token)
        let resp = try await client.voices()
        print(resp.voices.map { "\($0.voice_id) — \($0.name ?? "Unknown")" }.joined(separator: "\n"))
    }
}

struct SpeechCompletion: AsyncParsableCommand {
    @OptionGroup var options: Options
    
    func run() async throws {
        let client = Client(apiKey: options.token)
        let request = SpeechRequest(text: options.prompt, voice_id: options.voice, model_id: options.model)

        do {
            let data = try await client.textToSpeech(request)
            let filename = "\(UUID().uuidString).mp3"

            if let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.appending(component: filename) {
                try data.write(to: url)
                try FileHandle.standardOutput.write(contentsOf: url.absoluteString.data(using: .utf8)!)
            } else {
                print("unable to create URL")
            }
        } catch {
            print(error)
        }
    }
}

struct SpeechCompletionWithTimestamps: AsyncParsableCommand {
    @OptionGroup var options: Options

    func run() async throws {
        let client = Client(apiKey: options.token)
        let request = SpeechRequest(text: options.prompt, voice_id: options.voice, model_id: options.model)

        do {
            let resp = try await client.textToSpeechWithTimestamps(request)
            let filename = "\(UUID().uuidString).mp3"
            let data = Data(base64Encoded: resp.audio_base64)!

            if let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.appending(component: filename) {
                try data.write(to: url)
                try FileHandle.standardOutput.write(contentsOf: url.absoluteString.data(using: .utf8)!)
            } else {
                print("unable to create URL")
            }

            print(resp.alignment)
        } catch {
            print(error)
        }
    }
}
