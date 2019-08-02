import MapKit

public final class Line: MKPolyline {
    public private(set) weak var path: Plan.Path!
    public private(set) weak var option: Plan.Option!
    
    public init(_ path: Plan.Path, option: Plan.Option) {
        super.init()
        self.path = path
        self.option = option
    }
    
//    public override func points() -> UnsafeMutablePointer<MKMapPoint> {
//        return option.po
//    }
}
