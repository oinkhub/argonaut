import Foundation

public struct Session: Codable {
    public struct Travel: Codable {
        public var duration = 0.0
        public var distance = 0.0
    }
    
    public struct Item: Codable {
        public var id = ""
        public var origin = ""
        public var destination = ""
        public var walking = Travel()
        public var driving = Travel()
        
        public init() { }
    }
    
    public static func load(_ result: @escaping((Session) -> Void)) {
        queue.async {
            let session = {
                $0 == nil ? Session() : (try? JSONDecoder().decode(Session.self, from: $0!)) ?? Session()
            } (UserDefaults.standard.data(forKey: "session"))
            DispatchQueue.main.async { result(session) }
        }
    }
    
    private static let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    public var items = [Item]() { didSet { save() } }
    public var rating = Calendar.current.date(byAdding: {
        var d = DateComponents()
        d.day = 3
        return d
    } (), to: Date())! { didSet { save() } }
    
    private func save() {
        Session.queue.async {
            UserDefaults.standard.set(try! JSONEncoder().encode(self), forKey: "session")
        }
    }
}
