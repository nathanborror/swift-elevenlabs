import Foundation
import ArgumentParser
import ElevenLabs

@main
struct Command: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "A utility for interacting with the ElevenLabs API.",
        version: "0.0.1",
        subcommands: [
            Models.self,
            Voices.self,
            Speak.self,
            SpeakWithTimestamps.self,
            Transcribe.self,
        ]
    )
}

struct GlobalOptions: ParsableArguments {
    @Option(name: .shortAndLong, help: "Your API key.")
    var key: String

    @Option(name: .shortAndLong, help: "Model to use.")
    var model: String?

    @Option(name: .shortAndLong, help: "Voice to use.")
    var voice: String?
}

struct Models: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "models",
        abstract: "Returns available models."
    )

    @OptionGroup
    var global: GlobalOptions

    func run() async throws {
        let client = Client(apiKey: global.key)
        let models = try await client.models()
        print(models.map { "\($0.model_id) — \($0.name)" }.joined(separator: "\n"))
    }
}

struct Voices: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "voices",
        abstract: "Returns available voices."
    )

    @OptionGroup
    var global: GlobalOptions

    func run() async throws {
        let client = Client(apiKey: global.key)
        let resp = try await client.voices()
        print(resp.voices.map { "\($0.voice_id) — \($0.name ?? "Unknown")" }.joined(separator: "\n"))
    }
}

struct Speak: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "speak",
        abstract: "Returns an audio file containing the completion of the given text."
    )

    @OptionGroup
    var global: GlobalOptions

    @Argument(help: "Text to convert to speech.")
    var text: String

    func run() async throws {
        guard let model = global.model else {
            fatalError("missing model")
        }
        guard let voice = global.voice else {
            fatalError("missing model")
        }

        let client = Client(apiKey: global.key)
        let request = SpeechRequest(text: text, voice_id: voice, model_id: model)

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

struct SpeakWithTimestamps: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "speak-with-timestamps",
        abstract: "Returns an audio file containing the completion of the given text."
    )

    @OptionGroup
    var global: GlobalOptions

    @Argument(help: "Text to convert to speech.")
    var text: String

    func run() async throws {
        guard let model = global.model else {
            fatalError("missing model")
        }
        guard let voice = global.voice else {
            fatalError("missing model")
        }

        let client = Client(apiKey: global.key)
        let request = SpeechRequest(text: text, voice_id: voice, model_id: model)

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

struct Transcribe: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "transcribe",
        abstract: "Returns an audio transcription."
    )

    @OptionGroup
    var global: GlobalOptions

    @Argument(help: "Audio to transcribe.", completion: .file(), transform: URL.init(fileURLWithPath:))
    var file: URL

    func run() async throws {
        let client = Client(apiKey: global.key)
        let request = TranscriptionRequest(
            file: file,
            model_id: global.model ?? "scribe_v1"
        )
        let resp = try await client.speechToText(request)
        print(resp)
    }
}
