import SwiftUI

struct Navigate: View {
    @ObservedObject var places: Places
    var item: Session.Item
    private var formatter: MeasurementFormatter {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.unitOptions = .naturalScale
        formatter.numberFormatter.maximumFractionDigits = 1
        return formatter
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                ZStack {
                    ForEach((2...142), id: \.self) { p in
                        Path {
                            let side = min(geo.size.width, geo.size.height) * 0.47
                            $0.move(to: .init(x: geo.size.width / 2, y: (geo.size.height / 2) - side - 2))
                            $0.addLine(to: .init(x: geo.size.width / 2, y: (geo.size.height / 2) - side + 2))
                        }
                        .stroke(Color("halo"), style: .init(lineWidth: 1, lineCap: .round)).rotationEffect(.degrees(Double(p) * 2.5))
                    }
                    
                    Path {
                        let side = min(geo.size.width, geo.size.height) * 0.47
                        $0.addArc(center: .init(x: geo.size.width / 2, y: (geo.size.height / 2) - side), radius: 4, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
                    }
                    .stroke(Color("halo"), style: .init(lineWidth: 1, lineCap: .round))

                    Path {
                        let x = CGFloat(self.item.longitude - self.places.coordinate.1)
                        let y = CGFloat(self.places.coordinate.0 - self.item.latitude)
                        let side = min(geo.size.width, geo.size.height) * 0.27
                        let rate = max(abs(x), abs(y)) / side
                        $0.move(to: .init(x: geo.size.width / 2, y: geo.size.height / 2))
                        $0.addLine(to: .init(x: (geo.size.width / 2) + (x / rate), y: (geo.size.height / 2) + (y / rate)))
                    }
                    .stroke(Color(white: 0.1), style: .init(lineWidth: 12, lineCap: .round))
                    
                    Path {
                        let x = CGFloat(self.item.longitude - self.places.coordinate.1)
                        let y = CGFloat(self.places.coordinate.0 - self.item.latitude)
                        let side = min(geo.size.width, geo.size.height) * 0.27
                        let rate = max(abs(x), abs(y)) / side
                        $0.addArc(center: .init(x: (geo.size.width / 2) + (x / rate), y: (geo.size.height / 2) + (y / rate)), radius: 8, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
                    }
                    .fill(Color("halo"))
                }
            }
            .rotationEffect(.degrees(places.heading))
            .navigationBarTitle(item.name)
            
            Image("heading")
            
            Text(formatter.string(from: .init(value: CLLocation(latitude: item.latitude, longitude: item.longitude).distance(from: .init(latitude: places.coordinate.0, longitude: places.coordinate.1)), unit: UnitLength.meters)))
                .offset(x: 0, y: 25)
        }
    }
}
