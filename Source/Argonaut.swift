import Foundation

final class Argonaut {
    static let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("maps")
}
