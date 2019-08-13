import MapKit

class Callout: UIView {
    final class Item: Callout {
        required init?(coder: NSCoder) { return nil }
        @discardableResult init(_ view: MKAnnotationView, index: String) {
            super.init(view)
        }
        
        func refresh(_ title: String) {

        }
    }
    
    final class User: Callout {
        required init?(coder: NSCoder) { return nil }
        @discardableResult override init(_ view: MKAnnotationView) {
            super.init(view)
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    private init(_ view: MKAnnotationView) {
        super.init(frame: .zero)
    }
    
    final func remove() {
        
    }
}
