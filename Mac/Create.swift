import Argonaut
import AppKit

final class Create: NSWindow {
    private let factory = Factory()
    
    init(_ plan: [Route]) {
        super.init(contentRect: .init(origin: .init(x: app.list.frame.maxX + 4, y: app.list.frame.minY + 400), size: .init(width: 400, height: 400)), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        toolbar = .init(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.factory.plan = plan
            self?.factory.error = {
                app.alert("Error", message: $0.localizedDescription)
            }
            self?.factory.measure()
            self?.factory.divide()
            self?.factory.shoot()
        }
    }
}
