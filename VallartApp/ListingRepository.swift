import Foundation
import Supabase

// MARK: - ListingRepository Protocol
// Swap mock ↔ real by changing which impl the app uses.

protocol ListingRepositoryProtocol {
    func fetchAll() async throws -> [Listing]
    func fetchFeatured() async throws -> [Listing]
    func fetchByCategory(_ category: ListingCategory) async throws -> [Listing]
    func fetchByID(_ id: UUID) async throws -> Listing
    func search(query: String, category: ListingCategory?, neighborhood: Neighborhood?, openOnly: Bool, lgbtOnly: Bool) async throws -> [Listing]
    func fetchReviews(for listingID: UUID) async throws -> [Review]
    func submitReview(_ review: ReviewInput) async throws
}

// MARK: - Supabase Row types (snake_case matches DB columns)

struct ListingRow: Codable {
    let id: String
    let name: String
    let category: String
    let neighborhood: String
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let description: String?
    let photos: [String]?
    let rating: Double?
    let reviewCount: Int?
    let priceRange: Int?
    let phone: String?
    let website: String?
    let instagram: String?
    let tags: [String]?
    let isPremium: Bool?
    let isFeatured: Bool?
    let isOpen: Bool?
    let openHours: String?
    let isLgbtFriendly: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, category, neighborhood, address, latitude, longitude
        case description, photos, rating, phone, website, instagram, tags
        case reviewCount  = "review_count"
        case priceRange   = "price_range"
        case isPremium    = "is_premium"
        case isFeatured   = "is_featured"
        case isOpen       = "is_open"
        case openHours    = "open_hours"
        case isLgbtFriendly = "is_lgbt_friendly"
    }

    // Convert DB row → app model
    func toListing() -> Listing {
        Listing(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            category: ListingCategory(rawValue: category) ?? .restaurants,
            neighborhood: Neighborhood(rawValue: neighborhood) ?? .centro,
            address: address ?? "",
            latitude: latitude ?? 20.6534,
            longitude: longitude ?? -105.2253,
            description: description ?? "",
            photos: photos ?? [],
            rating: rating ?? 0,
            reviewCount: reviewCount ?? 0,
            priceRange: PriceRange(rawValue: priceRange ?? 2) ?? .moderate,
            phone: phone,
            website: website,
            instagram: instagram,
            tags: tags ?? [],
            isPremium: isPremium ?? false,
            isFeatured: isFeatured ?? false,
            isOpen: isOpen ?? true,
            openHours: openHours,
            isLGBTFriendly: isLgbtFriendly ?? false
        )
    }
}

struct ReviewRow: Codable {
    let id: String
    let listingId: String
    let userId: String?
    let authorName: String?
    let rating: Double?
    let text: String?
    let photos: [String]?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, rating, text, photos
        case listingId  = "listing_id"
        case userId     = "user_id"
        case authorName = "author_name"
        case createdAt  = "created_at"
    }

    func toReview() -> Review {
        let formatter = ISO8601DateFormatter()
        return Review(
            id: UUID(uuidString: id) ?? UUID(),
            listingID: UUID(uuidString: listingId) ?? UUID(),
            authorName: authorName ?? "Anonymous",
            authorAvatar: "person.circle.fill",
            rating: rating ?? 0,
            text: text ?? "",
            date: formatter.date(from: createdAt ?? "") ?? Date(),
            photos: photos ?? []
        )
    }
}

// MARK: - ReviewInput
struct ReviewInput {
    let listingID: UUID
    let userID: UUID
    let authorName: String
    let rating: Double
    let text: String
}

// MARK: - SupabaseListingRepository
class SupabaseListingRepository: ListingRepositoryProtocol {

    static let shared = SupabaseListingRepository()
    private init() {}

    func fetchAll() async throws -> [Listing] {
        let rows: [ListingRow] = try await supabase
            .from("listings")
            .select()
            .order("is_featured", ascending: false)
            .order("rating", ascending: false)
            .execute()
            .value
        return rows.map { $0.toListing() }
    }

    func fetchFeatured() async throws -> [Listing] {
        let rows: [ListingRow] = try await supabase
            .from("listings")
            .select()
            .eq("is_featured", value: true)
            .order("is_premium", ascending: false)
            .order("rating", ascending: false)
            .limit(10)
            .execute()
            .value
        return rows.map { $0.toListing() }
    }

    func fetchByCategory(_ category: ListingCategory) async throws -> [Listing] {
        let rows: [ListingRow] = try await supabase
            .from("listings")
            .select()
            .eq("category", value: category.rawValue)
            .order("is_premium", ascending: false)
            .order("rating", ascending: false)
            .execute()
            .value
        return rows.map { $0.toListing() }
    }

    func fetchByID(_ id: UUID) async throws -> Listing {
        let row: ListingRow = try await supabase
            .from("listings")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
        return row.toListing()
    }

    func search(
        query: String,
        category: ListingCategory?,
        neighborhood: Neighborhood?,
        openOnly: Bool,
        lgbtOnly: Bool
    ) async throws -> [Listing] {
        var builder = supabase
            .from("listings")
            .select()

        if !query.isEmpty {
            // PostgreSQL full-text search across name, description, tags
            builder = builder.textSearch("name", query: query, type: .plain)
        }
        if let cat = category {
            builder = builder.eq("category", value: cat.rawValue)
        }
        if let hood = neighborhood {
            builder = builder.eq("neighborhood", value: hood.rawValue)
        }
        if openOnly {
            builder = builder.eq("is_open", value: true)
        }
        if lgbtOnly {
            builder = builder.eq("is_lgbt_friendly", value: true)
        }

        let rows: [ListingRow] = try await builder
            .order("is_premium", ascending: false)
            .order("rating", ascending: false)
            .execute()
            .value
        return rows.map { $0.toListing() }
    }

    func fetchReviews(for listingID: UUID) async throws -> [Review] {
        let rows: [ReviewRow] = try await supabase
            .from("reviews")
            .select()
            .eq("listing_id", value: listingID.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        return rows.map { $0.toReview() }
    }

    func submitReview(_ input: ReviewInput) async throws {
        try await supabase
            .from("reviews")
            .insert([
                "listing_id":  input.listingID.uuidString,
                "user_id":     input.userID.uuidString,
                "author_name": input.authorName,
                "rating":      String(input.rating),
                "text":        input.text
            ])
            .execute()

        // Recalculate rating average via RPC (optional — set up in Supabase SQL)
        // try await supabase.rpc("recalculate_rating", params: ["p_listing_id": input.listingID.uuidString]).execute()
    }
}

// MARK: - MockListingRepository (keeps Phase 1 data working without Supabase)
class MockListingRepository: ListingRepositoryProtocol {
    private let data = MockDataService.shared

    func fetchAll() async throws -> [Listing] { data.listings }
    func fetchFeatured() async throws -> [Listing] { data.featuredListings }
    func fetchByCategory(_ category: ListingCategory) async throws -> [Listing] { data.listings(for: category) }
    func fetchByID(_ id: UUID) async throws -> Listing {
        guard let l = data.listings.first(where: { $0.id == id }) else {
            throw NSError(domain: "NotFound", code: 404)
        }
        return l
    }
    func search(query: String, category: ListingCategory?, neighborhood: Neighborhood?, openOnly: Bool, lgbtOnly: Bool) async throws -> [Listing] {
        data.search(query)
    }
    func fetchReviews(for listingID: UUID) async throws -> [Review] { [] }
    func submitReview(_ review: ReviewInput) async throws {}
}
