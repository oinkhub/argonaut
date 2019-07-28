import Foundation

struct Fail: LocalizedError {
    var errorDescription: String?
    init(_ message: String) { errorDescription = message }
}
