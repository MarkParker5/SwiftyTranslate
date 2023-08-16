//
//  SwiftyTranslate.swift
//  SwiftyTranslate
//
//  Created by Mark Parker on 16/08/2023.
//

import Foundation

public struct Language: Identifiable, Hashable {
    let code: String
    let name: String
    
    public var id: String { code }
}

public extension Language {
    static let english = Language(code: "en", name: "English")
}

@available(iOS 13.0.0, *)
public class SwiftyTranslate {
    
    public var languages: [Language] {
        Locale.availableIdentifiers
            .map {
                Locale(identifier: $0)
            }
            .compactMap { locale in
                guard
                    let languageCode = locale.identifier.split(separator: "_").first.map(String.init),
                    let languageName = locale.localizedString(forLanguageCode: languageCode)
                else {
                    return nil
                }
                return Language(code: languageCode, name: languageName)
            }.reduce(into: [String: Language]()) { result, language in
                result[language.code] = language // remove duplicates
            }.values
            .sorted {
                $0.name < $1.name
            }
    }
    
    public func translate(text: String, to language: Language) async throws -> String? {
        guard var components = URLComponents(string: "https://translate.google.com/m") else { return nil }
        components.queryItems = [
            URLQueryItem(name: "tl", value: language.code),
            URLQueryItem(name: "sl", value: "auto"),
            URLQueryItem(name: "q", value: text)
        ]
        
        guard let url = components.url else { return nil }
        let request = URLRequest(url: url)
        
        let responseString: String? = try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data {
                    continuation.resume(returning: String(data: data, encoding: .utf8))
                } else {
                    continuation.resume(returning: nil)
                }
            }.resume()
        }
        
        guard let responseString else { return nil }
        
        let pattern = "(?s)class=\"(?:t0|result-container)\">(?<translated>.*?)<"
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: responseString.count)
        let match = regex.firstMatch(in: responseString, options: [], range: range)
        
        guard let tokenRange = match?.range(withName: "translated") else { return nil }
        
        return (responseString as NSString).substring(with: tokenRange)
    }
}
