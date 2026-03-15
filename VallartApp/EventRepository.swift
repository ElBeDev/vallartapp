import Foundation
import Supabase

// MARK: - EventRepository Protocol

protocol EventRepositoryProtocol {
    func fetchAll() async throws -> [Event]
    func fetchFeatured() async throws -> [Event]
    func fetchUpcoming(limit: Int) async throws -> [Event]
    func fetchByID(_ id: UUID) async throws -> Event
    func fetchFiltered(isFree: Bool?, isPublic: Bool?, isLGBT: Bool?, withinDays: Int?) async throws -> [Event]
}

// MARK: - Supabase Row

struct EventRow: Codable {
    let id: String
    let title: String
    let description: String?
    let neighborhood: String?
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let startDate: String?
    let endDate: String?
    let isPublic: Bool?
    let isFree: Bool?
    let ticketPrice: Double?
    let ticketUrl: String?
    let photos: [String]?
    let tags: [String]?
    let organizer: String?
    let phone: String?
    let instagram: String?
    let isPremium: Bool?
    let isFeatured: Bool?
    let isLgbtFriendly: Bool?
    let isRecurring: Bool?
    let recurrenceLabel: String?

    enum CodingKeys: String, CodingKey {
        case id, title, description, neighborhood, address
        case latitude, longitude, photos, tags, organizer, phone, instagram
        case startDate       = "start_date"
        case endDate         = "end_date"
        case isPublic        = "is_public"
        case isFree          = "is_free"
        case ticketPrice     = "ticket_price"
        case ticketUrl       = "ticket_url"
        case isPremium       = "is_premium"
        case isFeatured      = "is_featured"
        case isLgbtFriendly  = "is_lgbt_friendly"
        case isRecurring     = "is_recurring"
        case recurrenceLabel = "recurrence_label"
    }

    func toEvent() -> Event {
        let iso = ISO8601DateFormatter()
        return Event(
            id: UUID(uuidString: id) ?? UUID(),
            title: title,
            description: description ?? "",
            neighborhood: Neighborhood(rawValue: neighborhood ?? "") ?? .centro,
            address: address ?? "",
            latitude: latitude ?? 20.6534,
            longitude: longitude ?? -105.2253,
            startDate: iso.date(from: startDate ?? "") ?? Date(),
            endDate: iso.date(from: endDate ?? "") ?? Date(),
            isPublic: isPublic ?? true,
            isFree: isFree ?? true,
            ticketPrice: ticketPrice,
            ticketURL: ticketUrl,
            photos: photos ?? [],
            tags: tags ?? [],
            organizer: organizer ?? "",
            phone: phone,
            instagram: instagram,
            isPremium: isPremium ?? false,
            isFeatured: isFeatured ?? false,
            isLGBTFriendly: isLgbtFriendly ?? false,
            isRecurring: isRecurring ?? false,
            recurrenceLabel: recurrenceLabel
        )
    }
}

// MARK: - SupabaseEventRepository

class SupabaseEventRepository: EventRepositoryProtocol {

    static let shared = SupabaseEventRepository()
    private init() {}

    func fetchAll() async throws -> [Event] {
        let rows: [EventRow] = try await supabase
            .from("events")
            .select()
            .gte("end_date", value: ISO8601DateFormatter().string(from: Date()))
            .order("start_date", ascending: true)
            .execute()
            .value
        return rows.map { $0.toEvent() }
    }

    func fetchFeatured() async throws -> [Event] {
        let rows: [EventRow] = try await supabase
            .from("events")
            .select()
            .eq("is_featured", value: true)
            .gte("end_date", value: ISO8601DateFormatter().string(from: Date()))
            .order("start_date", ascending: true)
            .limit(6)
            .execute()
            .value
        return rows.map { $0.toEvent() }
    }

    func fetchUpcoming(limit: Int = 10) async throws -> [Event] {
        let rows: [EventRow] = try await supabase
            .from("events")
            .select()
            .gte("start_date", value: ISO8601DateFormatter().string(from: Date()))
            .order("start_date", ascending: true)
            .limit(limit)
            .execute()
            .value
        return rows.map { $0.toEvent() }
    }

    func fetchByID(_ id: UUID) async throws -> Event {
        let row: EventRow = try await supabase
            .from("events")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
        return row.toEvent()
    }

    func fetchFiltered(
        isFree: Bool? = nil,
        isPublic: Bool? = nil,
        isLGBT: Bool? = nil,
        withinDays: Int? = nil
    ) async throws -> [Event] {
        var builder = supabase
            .from("events")
            .select()
            .gte("end_date", value: ISO8601DateFormatter().string(from: Date()))

        if let free = isFree    { builder = builder.eq("is_free",         value: free) }
        if let pub  = isPublic  { builder = builder.eq("is_public",       value: pub)  }
        if let lgbt = isLGBT    { builder = builder.eq("is_lgbt_friendly", value: lgbt) }
        if let days = withinDays {
            let cutoff = Calendar.current.date(byAdding: .day, value: days, to: Date())!
            builder = builder.lte("start_date", value: ISO8601DateFormatter().string(from: cutoff))
        }

        let rows: [EventRow] = try await builder
            .order("start_date", ascending: true)
            .execute()
            .value
        return rows.map { $0.toEvent() }
    }
}

// MARK: - MockEventRepository
class MockEventRepository: EventRepositoryProtocol {
    private let data = MockDataService.shared

    func fetchAll() async throws -> [Event] { data.events }
    func fetchFeatured() async throws -> [Event] { data.featuredEvents }
    func fetchUpcoming(limit: Int) async throws -> [Event] { Array(data.events.prefix(limit)) }
    func fetchByID(_ id: UUID) async throws -> Event {
        guard let e = data.events.first(where: { $0.id == id }) else {
            throw NSError(domain: "NotFound", code: 404)
        }
        return e
    }
    func fetchFiltered(isFree: Bool?, isPublic: Bool?, isLGBT: Bool?, withinDays: Int?) async throws -> [Event] {
        var events = data.events
        if let free = isFree    { events = events.filter { $0.isFree == free } }
        if let pub  = isPublic  { events = events.filter { $0.isPublic == pub } }
        if let lgbt = isLGBT    { events = events.filter { $0.isLGBTFriendly == lgbt } }
        if let days = withinDays {
            let cutoff = Calendar.current.date(byAdding: .day, value: days, to: Date())!
            events = events.filter { $0.startDate <= cutoff }
        }
        return events
    }
}
