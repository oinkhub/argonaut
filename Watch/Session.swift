import Foundation

struct Session: Codable {
    static func load(_ result: @escaping((Session) -> Void)) {
        queue.async {
            let session = {
                $0 == nil ? Session() : (try? JSONDecoder().decode(Session.self, from: $0!)) ?? Session()
            } (try? Data(contentsOf: url))
            DispatchQueue.main.async { result(session) }
        }
    }
    
    private static let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Session.argo")
    private static let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    var items = [Pointer]()
    
    func save() {
        Session.queue.async {
            try? JSONEncoder().encode(self).write(to: Session.url, options: .atomic)
        }
    }
}
