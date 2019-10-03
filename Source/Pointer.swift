import Foundation

public struct Pointer: Identifiable, Hashable, Codable {
    public internal(set) var id = UUID()
    var name = ""
    var latitude = 0.0
    var longitude = 0.0
}
