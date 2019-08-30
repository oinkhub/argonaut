import Argonaut
import MapKit

final class Tiler: MKTileOverlay {
    fileprivate let cart: Cart
    
    init(_ cart: Cart) {
        self.cart = cart
        super.init(urlTemplate: nil)
        tileSize = .init(width: Argonaut.tile * 2, height: Argonaut.tile * 2)
        canReplaceMapContent = true
    }
    
    override func loadTile(at: MKTileOverlayPath, result: @escaping(Data?, Error?) -> Void) {
        result(cart.tile(at.x, at.y), nil)
    }
}

final class Tiler2: MKOverlayRenderer {
    var first = false
    private let tile = Argonaut.tile * 2
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let tiler = overlay as! Tiler
        let zoom = Double(zoomScale) / tile

        let r = rect(for: mapRect)
        
//        tiler.cart.tile(Int(mapRect.minX * zoom), Int(mapRect.minY * zoom)) {

//            if self.first == false, let data = $0, let image = UIImage(data: data)?.cgImage {
//                print(self.rect(for: mapRect))
                
//                let rect = self.rect(for: mapRect)
//                context.saveGState()
//                context.translateBy(x: rect.minX * CGFloat(zoom), y: rect.minY * CGFloat(zoom))
//                context.translateBy(x: 0, y: 1024)
//                context.scaleBy(x: 1, y: -1)
                
//                context.setFillColor(.black)
//                context.addEllipse(in: r)
//                context.drawPath(using: .fill)
//                context.draw(image, in: .init(x: 0, y: 0, width: 256, height: 256), byTiling: false)
//                self.first = true
//                context.restoreGState()
                /*
                CGRect rect = [self rectForMapRect:tile.frame];
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:tile.imagePath];
                CGContextSaveGState(context);
                CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));

                // OverZoom mode - 1 when using tiles as is, 2, 4, 8 etc when overzoomed.
                CGContextScaleCTM(context, overZoom/zoomScale, overZoom/zoomScale);
                CGContextTranslateCTM(context, 0, image.size.height);
                CGContextScaleCTM(context, 1, -1);
                CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]);
                CGContextRestoreGState(context);

                // Added release here because "Analyze" was reporting a potential leak. Bug in Apple's sample code?
                [image release];*/
                
                
//            }
//        }
    }
}
