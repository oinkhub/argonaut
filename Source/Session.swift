import Foundation

public class Session: Codable {
    public struct Travel: Codable {
        public var duration = 0.0
        public var distance = 0.0
    }
    
    public class Item: Codable {
        public var id = ""
        public var title = ""
        public var origin = ""
        public var destination = ""
        public var walking = Travel()
        public var driving = Travel()
        
        public init() { }
    }
    
    public struct Onboard: Codable {
        public var first = true
        public var created = true
        public var newDown = true
        public var newUp = true
        public var navigateDown = true
        public var navigateUp = true
        public var added = true
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
    public var items = [Item]()
    public var onboard = Onboard()
    public var rating = Calendar.current.date(byAdding: {
        var d = DateComponents()
        d.day = 3
        return d
    } (), to: Date())!
    
    public func save() {
        Session.queue.async {
            UserDefaults.standard.set(try! JSONEncoder().encode(self), forKey: "session")
        }
    }
    
    public func update(_ item: Item) {
        items.removeAll { $0.id == item.id }
        items.append(item)
    }
}
