import Foundation
import CoreLocation

public struct Location: Codable, Equatable {
    public var name: String
    public var address: String?
    public var city: String
    public var state: String
    public var country: String
    public var coordinate: Coordinate
    
    public init(name: String, address: String? = nil, city: String, 
         state: String, country: String, coordinate: Coordinate) {
        self.name = name
        self.address = address
        self.city = city
        self.state = state
        self.country = country
        self.coordinate = coordinate
    }
}

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
