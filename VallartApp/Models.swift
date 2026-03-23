import Foundation
import CoreLocation

// MARK: - ListingCategory
enum ListingCategory: String, CaseIterable, Codable, Identifiable {
    case restaurants    = "Restaurants"
    case bars           = "Bars & Nightlife"
    case hotels         = "Hotels"
    case activities     = "Activities"
    case yachts         = "Yacht Rentals"
    case rentals        = "Car & Moto Rental"
    case events         = "Events"
    case beaches        = "Beaches"
    case shopping       = "Shopping"
    case spas           = "Spas & Wellness"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .restaurants: return "fork.knife"
        case .bars:        return "music.note"
        case .hotels:      return "bed.double.fill"
        case .activities:  return "figure.surfing"
        case .yachts:      return "sailboat.fill"
        case .rentals:     return "car.fill"
        case .events:      return "calendar"
        case .beaches:     return "sun.max.fill"
        case .shopping:    return "bag.fill"
        case .spas:        return "leaf.fill"
        }
    }


}

// MARK: - Neighborhood
enum Neighborhood: String, CaseIterable, Codable {
    case centro          = "centro"
    case zonaRomantica   = "zonaRomantica"
    case marina          = "marina"
    case hotelZone       = "hotelZone"
    case nuevaVallarta   = "nuevaVallarta"
    case bucerías        = "bucerías"
    case laCruz          = "laCruz"
    case puntaMita       = "puntaMita"
    case sayulita        = "sayulita"
    case sanPancho       = "sanPancho"
    case yelapa          = "yelapa"
    case mismaloya       = "mismaloya"

    var displayName: String {
        switch self {
        case .centro:        return "Centro"
        case .zonaRomantica: return "Zona Romántica"
        case .marina:        return "Marina Vallarta"
        case .hotelZone:     return "Hotel Zone"
        case .nuevaVallarta: return "Nuevo Vallarta"
        case .bucerías:      return "Bucerías"
        case .laCruz:        return "La Cruz"
        case .puntaMita:     return "Punta Mita"
        case .sayulita:      return "Sayulita"
        case .sanPancho:     return "San Pancho"
        case .yelapa:        return "Yelapa"
        case .mismaloya:     return "Mismaloya"
        }
    }
}

// MARK: - PriceRange
enum PriceRange: Int, Codable, CaseIterable {
    case free     = 0
    case budget   = 1
    case moderate = 2
    case upscale  = 3
    case luxury   = 4

    var symbol: String {
        switch self {
        case .free:     return "Free"
        case .budget:   return "$"
        case .moderate: return "$$"
        case .upscale:  return "$$$"
        case .luxury:   return "$$$$"
        }
    }
}

// MARK: - Listing
struct Listing: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var category: ListingCategory
    var neighborhood: Neighborhood
    var address: String
    var latitude: Double
    var longitude: Double
    var description: String
    var photos: [String]
    var rating: Double
    var reviewCount: Int
    var priceRange: PriceRange
    var phone: String?
    var website: String?
    var instagram: String?
    var tags: [String]
    var isPremium: Bool      = false
    var isFeatured: Bool     = false
    var isOpen: Bool         = true
    var openHours: String?
    var isLGBTFriendly: Bool = false

    var heroPhoto: String { photos.first ?? "photo" }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func == (lhs: Listing, rhs: Listing) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Event
struct Event: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var neighborhood: Neighborhood
    var address: String
    var latitude: Double
    var longitude: Double
    var startDate: Date
    var endDate: Date
    var isPublic: Bool
    var isFree: Bool
    var ticketPrice: Double?
    var ticketURL: String?
    var photos: [String]
    var tags: [String]
    var organizer: String
    var phone: String?
    var instagram: String?
    var isPremium: Bool      = false
    var isFeatured: Bool     = false
    var isLGBTFriendly: Bool = false
    var isRecurring: Bool    = false
    var recurrenceLabel: String?

    var heroPhoto: String { photos.first ?? "calendar" }

    var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: startDate)
    }

    static func == (lhs: Event, rhs: Event) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Review
struct Review: Identifiable, Codable {
    let id: UUID
    var listingID: UUID
    var authorName: String
    var authorAvatar: String
    var rating: Double
    var text: String
    var date: Date
    var photos: [String]

    var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
}

// MARK: - AppUser
struct AppUser: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var avatar: String
    var isBusinessOwner: Bool
    var savedListingIDs: [UUID]
    var joinedDate: Date
}
