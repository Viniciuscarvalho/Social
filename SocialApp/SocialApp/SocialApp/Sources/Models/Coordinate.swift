import Foundation
import CoreLocation

public struct Coordinate: Codable, Equatable {
    public let latitude: Double
    public let longitude: Double
    
    public var clLocationCoordinate2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}