import Foundation

public struct Session: Codable {
    public struct Item: Codable {
        public var name = ""
        public var id = ""
        public init() { }
    }
    
    public static func load(_ result: @escaping((Session) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            let session = {
                $0 == nil ? Session() : (try? JSONDecoder().decode(Session.self, from: $0!)) ?? Session()
            } (UserDefaults.standard.data(forKey: "session"))
            DispatchQueue.main.async { result(session) }
        }
    }
    
    public var items = [Item]() { didSet { save() } }
    public var rating = Calendar.current.date(byAdding: {
        var d = DateComponents()
        d.day = 3
        return d
    } (), to: Date())! { didSet { save() } }
    
    private func save() {
        DispatchQueue.global(qos: .background).async {
            UserDefaults.standard.set(try! JSONEncoder().encode(self), forKey: "session")
        }
    }
}
