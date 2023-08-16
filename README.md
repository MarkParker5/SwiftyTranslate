# SwiftyTranslate

Swift wrapper for public google translate

```swift
public struct Language: Identifiable, Hashable {
    let code: String
    let name: String
    
    public var id: String { code }
}

public extension Language {
    static let english = Language(code: "en", name: "English")
}

public class SwiftyTranslate {
    
    public var languages: [Language] { get }
    
    public func translate(text: String, to language: Language) async throws -> String?
}
```

## Usage

Install as a swift package

```swift
import SwiftyTranslate

func demo() async throws {
  let translator = SwiftyTranslate()
  let translatedText = try await translator.translate(text: "Hello, World!", to: .english)
}
```
