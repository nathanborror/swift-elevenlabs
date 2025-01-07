import Foundation

extension URLRequest {

    public var queryParameters: [String: String] {
        get {
            guard let url = self.url else {
                return [:]
            }
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
                return [:]
            }
            return components.reduce(into: [String: String]()) { (result, item) in
                result[item.name] = item.value
            }
        }
        set {
            guard let url = self.url else { return }
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = newValue.map { URLQueryItem(name: $0.key, value: $0.value) }
            self.url = components?.url ?? self.url
        }
    }
}
