import Foundation

public final class Argonaut {
    public static let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("maps")
    public static let tile = 512.0
}
