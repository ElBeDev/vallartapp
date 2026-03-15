import Foundation
import Combine

// MARK: - MockDataService
class MockDataService: ObservableObject {

    static let shared = MockDataService()

    // MARK: Listings
    let listings: [Listing] = [

        // MARK: Restaurants
        Listing(id: UUID(), name: "Café des Artistes",
                category: .restaurants, neighborhood: .centro,
                address: "Guadalupe Sánchez 740, Centro",
                latitude: 20.6060, longitude: -105.2370,
                description: "Puerto Vallarta's most celebrated fine dining restaurant. Set in a stunning art-filled mansion, offering contemporary Mexican cuisine with French influences.",
                photos: ["fork.knife"], rating: 4.9, reviewCount: 842,
                priceRange: .luxury, phone: "+52 322 222 3228",
                website: "https://cafedesartistes.com", instagram: "@cafedesartistes_pv",
                tags: ["Fine Dining", "Mexican", "Romantic", "Art"], isPremium: true, isFeatured: true, isOpen: true, openHours: "6:00 PM – 11:30 PM"),

        Listing(id: UUID(), name: "El Arrayán",
                category: .restaurants, neighborhood: .zonaRomantica,
                address: "Allende 344, Zona Romántica",
                latitude: 20.5990, longitude: -105.2380,
                description: "Award-winning restaurant serving authentic Mexican home cooking with a twist. Famous for their mole and mezcal selection.",
                photos: ["fork.knife"], rating: 4.7, reviewCount: 612,
                priceRange: .upscale, phone: "+52 322 222 7195",
                tags: ["Mexican", "Mole", "Mezcal", "Authentic"], isPremium: true, isFeatured: true, isOpen: true, openHours: "5:30 PM – 11:00 PM"),

        Listing(id: UUID(), name: "La Palapa",
                category: .restaurants, neighborhood: .zonaRomantica,
                address: "Pulpito 103, Playa Los Muertos",
                latitude: 20.5975, longitude: -105.2395,
                description: "Iconic beachfront restaurant on Los Muertos Beach. Fresh seafood, tropical cocktails, and your feet in the sand.",
                photos: ["fork.knife"], rating: 4.6, reviewCount: 1203,
                priceRange: .upscale, phone: "+52 322 222 5225",
                tags: ["Seafood", "Beachfront", "Tropical", "Brunch"], isPremium: true, isFeatured: false, isOpen: true, openHours: "8:00 AM – 11:00 PM",
                isLGBTFriendly: true),

        Listing(id: UUID(), name: "Taco Bar Sayulita",
                category: .restaurants, neighborhood: .sayulita,
                address: "Calle Revolución s/n, Sayulita",
                latitude: 20.8695, longitude: -105.4450,
                description: "The best street tacos in Sayulita. Legendary al pastor, fresh tortillas, and cold cervezas.",
                photos: ["fork.knife"], rating: 4.8, reviewCount: 378,
                priceRange: .budget, tags: ["Tacos", "Street Food", "Local", "Casual"], isPremium: false, isFeatured: false, isOpen: true, openHours: "12:00 PM – 10:00 PM"),

        // MARK: Bars & Nightlife
        Listing(id: UUID(), name: "Los Muertos Brewing",
                category: .bars, neighborhood: .zonaRomantica,
                address: "Lázaro Cárdenas 302, Zona Romántica",
                latitude: 20.5985, longitude: -105.2378,
                description: "Puerto Vallarta's first craft brewery. Tropical-inspired beers brewed on-site, lively rooftop terrace with ocean views.",
                photos: ["music.note"], rating: 4.7, reviewCount: 521,
                priceRange: .moderate, phone: "+52 322 222 6516",
                tags: ["Craft Beer", "Rooftop", "LGBT Friendly", "Live Music"], isPremium: true, isFeatured: true, isOpen: true, openHours: "2:00 PM – 1:00 AM",
                isLGBTFriendly: true),

        Listing(id: UUID(), name: "Mandala Beach Club",
                category: .bars, neighborhood: .hotelZone,
                address: "Blvd. Francisco Medina Ascencio, Zona Hotelera",
                latitude: 20.6350, longitude: -105.2410,
                description: "Puerto Vallarta's hottest beach club and nightclub. International DJs, bottle service, swim-up bar.",
                photos: ["music.note"], rating: 4.4, reviewCount: 897,
                priceRange: .upscale, tags: ["Club", "Beach Club", "DJ", "Party"], isPremium: true, isFeatured: true, isOpen: false, openHours: "10:00 PM – 5:00 AM"),

        Listing(id: UUID(), name: "La Noche Bar",
                category: .bars, neighborhood: .zonaRomantica,
                address: "Lázaro Cárdenas 257, Zona Romántica",
                latitude: 20.5982, longitude: -105.2375,
                description: "Beloved LGBT+ bar in the heart of Zona Romántica. Weekly drag shows, theme nights, and the friendliest staff in PV.",
                photos: ["music.note"], rating: 4.8, reviewCount: 443,
                priceRange: .moderate, instagram: "@lanochepv",
                tags: ["LGBT+", "Drag Shows", "Gay Bar", "Fun"], isPremium: false, isFeatured: true, isOpen: true, openHours: "6:00 PM – 3:00 AM",
                isLGBTFriendly: true),

        // MARK: Hotels
        Listing(id: UUID(), name: "Garza Blanca Preserve Resort & Spa",
                category: .hotels, neighborhood: .hotelZone,
                address: "Carr. Barra de Navidad Km 7.5",
                latitude: 20.5610, longitude: -105.2570,
                description: "Ultra-luxury 5-star resort with private beach, multiple pools, gourmet restaurants, and world-class spa. The pinnacle of Vallarta luxury.",
                photos: ["bed.double.fill"], rating: 4.9, reviewCount: 1876,
                priceRange: .luxury, phone: "+52 322 176 0700",
                website: "https://garzablanca.com",
                tags: ["5-Star", "Luxury", "Spa", "Private Beach", "All-Inclusive Option"], isPremium: true, isFeatured: true, isOpen: true, openHours: "24 hours"),

        Listing(id: UUID(), name: "Casa Kimberly",
                category: .hotels, neighborhood: .centro,
                address: "Zaragoza 445, Centro",
                latitude: 20.6048, longitude: -105.2360,
                description: "The legendary former home of Elizabeth Taylor & Richard Burton, converted into a stunning boutique luxury hotel. History, romance, and views.",
                photos: ["bed.double.fill"], rating: 4.8, reviewCount: 634,
                priceRange: .luxury, phone: "+52 322 222 1336",
                website: "https://casakimberly.com",
                tags: ["Boutique", "Historic", "Romantic", "Views", "Adults Only"], isPremium: true, isFeatured: true, isOpen: true, openHours: "24 hours"),

        Listing(id: UUID(), name: "W Punta de Mita",
                category: .hotels, neighborhood: .puntaMita,
                address: "Lote H-1, Corral del Risco, Punta de Mita",
                latitude: 20.7715, longitude: -105.4970,
                description: "Ultra-cool luxury resort in Punta Mita. Celebrity hotspot with stunning beach, W Lounge, and insane pool scene.",
                photos: ["bed.double.fill"], rating: 4.7, reviewCount: 912,
                priceRange: .luxury, tags: ["5-Star", "Beach", "Pool", "Celebrity", "Surfing"], isPremium: true, isFeatured: false, isOpen: true, openHours: "24 hours"),

        // MARK: Activities
        Listing(id: UUID(), name: "Marietas Islands Snorkeling & Hiddenbeach",
                category: .activities, neighborhood: .puntaMita,
                address: "Departs from La Cruz Marina",
                latitude: 20.7130, longitude: -105.5600,
                description: "Iconic tour to the Marieta Islands — a UNESCO protected area. Snorkel with sea turtles, manta rays, and visit the famous Hidden Beach (Playa del Amor).",
                photos: ["figure.surfing"], rating: 4.9, reviewCount: 2341,
                priceRange: .moderate, phone: "+52 322 297 1212",
                tags: ["Snorkeling", "Wildlife", "UNESCO", "Hidden Beach", "Day Trip"], isPremium: false, isFeatured: true, isOpen: true, openHours: "8:00 AM – 5:00 PM"),

        Listing(id: UUID(), name: "Canopy River Zip-line & ATV",
                category: .activities, neighborhood: .centro,
                address: "Carr. a Boca de Tomatlán Km 3",
                latitude: 20.5720, longitude: -105.2490,
                description: "Thrilling zip-line tour through the jungle canopy above the Cuale River. Combine with ATV adventure and a traditional Mexican lunch.",
                photos: ["figure.surfing"], rating: 4.7, reviewCount: 1564,
                priceRange: .upscale, phone: "+52 322 222 4330",
                tags: ["Zip-line", "ATV", "Jungle", "Adventure", "Family"], isPremium: true, isFeatured: true, isOpen: true, openHours: "8:00 AM – 5:00 PM"),

        Listing(id: UUID(), name: "Whale Watching PV (Nov–Mar)",
                category: .activities, neighborhood: .marina,
                address: "Departs from Marina Vallarta",
                latitude: 20.6720, longitude: -105.2540,
                description: "Seasonal humpback whale watching tours. Puerto Vallarta's Banderas Bay is one of the world's best spots to see humpback whales November through March.",
                photos: ["figure.surfing"], rating: 4.9, reviewCount: 876,
                priceRange: .moderate, tags: ["Whale Watching", "Seasonal", "Wildlife", "Ocean", "Photography"], isPremium: false, isFeatured: true, isOpen: false, openHours: "Nov–Mar: 8:00 AM – 1:00 PM"),

        Listing(id: UUID(), name: "Sayulita Surf School",
                category: .activities, neighborhood: .sayulita,
                address: "Playa Sayulita, Sayulita",
                latitude: 20.8690, longitude: -105.4460,
                description: "Learn to surf in one of Mexico's most famous surf towns. Beginners to advanced lessons, board rentals, daily surf camps.",
                photos: ["figure.surfing"], rating: 4.8, reviewCount: 445,
                priceRange: .moderate, instagram: "@sayulitasurf",
                tags: ["Surfing", "Lessons", "Beginner", "Sayulita", "Beach"], isPremium: false, isFeatured: true, isOpen: true, openHours: "7:00 AM – 6:00 PM"),

        // MARK: Yacht Rentals
        Listing(id: UUID(), name: "Sunset Sailing Cruise PV",
                category: .yachts, neighborhood: .marina,
                address: "Marina Vallarta, Dock B",
                latitude: 20.6715, longitude: -105.2545,
                description: "4-hour sunset sailing cruise aboard a 42ft catamaran. Open bar, snorkeling stop, live music. The most romantic experience in Puerto Vallarta.",
                photos: ["sailboat.fill"], rating: 4.9, reviewCount: 1123,
                priceRange: .upscale, phone: "+52 322 225 4777",
                tags: ["Sunset", "Catamaran", "Open Bar", "Snorkeling", "Romantic"], isPremium: true, isFeatured: true, isOpen: true, openHours: "3:00 PM – 7:00 PM",
                isLGBTFriendly: true),

        Listing(id: UUID(), name: "Private Yacht Charter — Marietas",
                category: .yachts, neighborhood: .marina,
                address: "Marina Vallarta",
                latitude: 20.6718, longitude: -105.2548,
                description: "Full-day private yacht charter to the Marieta Islands. Up to 12 guests. Includes captain, crew, gourmet catering, snorkel equipment, paddleboards.",
                photos: ["sailboat.fill"], rating: 4.8, reviewCount: 312,
                priceRange: .luxury, phone: "+52 322 225 5000",
                tags: ["Private", "Charter", "Full Day", "Luxury", "Snorkeling"], isPremium: true, isFeatured: false, isOpen: true, openHours: "8:00 AM – 6:00 PM"),

        Listing(id: UUID(), name: "PV Sport Fishing Charter",
                category: .yachts, neighborhood: .marina,
                address: "Marina Vallarta, Dock C",
                latitude: 20.6720, longitude: -105.2550,
                description: "World-class sport fishing in Banderas Bay. Full-day and half-day charters. Target: Marlin, Sailfish, Mahi-Mahi, Tuna. All equipment included.",
                photos: ["sailboat.fill"], rating: 4.7, reviewCount: 234,
                priceRange: .luxury, tags: ["Fishing", "Sport Fishing", "Marlin", "Deep Sea", "Charter"], isPremium: false, isFeatured: false, isOpen: true, openHours: "6:00 AM – 3:00 PM"),

        // MARK: Car & Moto Rentals
        Listing(id: UUID(), name: "Vallarta Car Rental",
                category: .rentals, neighborhood: .centro,
                address: "Blvd. Francisco Medina Ascencio 1728",
                latitude: 20.6320, longitude: -105.2430,
                description: "Best rates on car rentals in Puerto Vallarta. Large fleet: economy cars, SUVs, convertibles. Airport pickup available.",
                photos: ["car.fill"], rating: 4.5, reviewCount: 678,
                priceRange: .moderate, phone: "+52 322 222 0999",
                tags: ["Car Rental", "Airport", "SUV", "Economy", "Convertible"], isPremium: true, isFeatured: false, isOpen: true, openHours: "8:00 AM – 8:00 PM"),

        Listing(id: UUID(), name: "Moto Rent PV",
                category: .rentals, neighborhood: .zonaRomantica,
                address: "Olas Altas 390, Zona Romántica",
                latitude: 20.5988, longitude: -105.2371,
                description: "Scooters, motorbikes, and ATVs for rent by the hour or day. Explore PV on two wheels. Helmets and insurance included.",
                photos: ["car.fill"], rating: 4.6, reviewCount: 289,
                priceRange: .budget, phone: "+52 322 222 1234",
                instagram: "@motorentpv",
                tags: ["Moto", "Scooter", "ATV", "Hourly", "Daily"], isPremium: false, isFeatured: false, isOpen: true, openHours: "9:00 AM – 7:00 PM"),

        // MARK: Beaches
        Listing(id: UUID(), name: "Playa Los Muertos",
                category: .beaches, neighborhood: .zonaRomantica,
                address: "Playa Los Muertos, Zona Romántica",
                latitude: 20.5970, longitude: -105.2400,
                description: "Puerto Vallarta's most famous and vibrant beach. Gay-friendly south end (Blue Chairs), beach restaurants, volleyball, parasailing, and legendary sunsets.",
                photos: ["sun.max.fill"], rating: 4.8, reviewCount: 4521,
                priceRange: .free, tags: ["Gay Friendly", "Beach Bars", "Sunset", "Volleyball", "Central"], isPremium: false, isFeatured: true, isOpen: true, openHours: "Always open",
                isLGBTFriendly: true),

        Listing(id: UUID(), name: "Playa Sayulita",
                category: .beaches, neighborhood: .sayulita,
                address: "Sayulita, Nayarit",
                latitude: 20.8685, longitude: -105.4458,
                description: "Charming bohemian surf beach in Sayulita. Mexican fishermen, surfers, and hippie travelers all coexist. Colorful town, great tacos nearby.",
                photos: ["sun.max.fill"], rating: 4.7, reviewCount: 2134,
                priceRange: .free, tags: ["Surf", "Bohemian", "Town", "Colorful", "Fishing"], isPremium: false, isFeatured: true, isOpen: true, openHours: "Always open"),

        // MARK: Spas
        Listing(id: UUID(), name: "Garza Blanca Spa",
                category: .spas, neighborhood: .hotelZone,
                address: "Carr. Barra de Navidad Km 7.5",
                latitude: 20.5612, longitude: -105.2572,
                description: "World-class spa at Garza Blanca Resort. Signature treatments inspired by Mexican healing traditions. Ocean views, hydrotherapy, couples suites.",
                photos: ["leaf.fill"], rating: 4.9, reviewCount: 456,
                priceRange: .luxury, phone: "+52 322 176 0700",
                tags: ["Luxury Spa", "Couples", "Hydrotherapy", "Ocean Views", "Massage"], isPremium: true, isFeatured: true, isOpen: true, openHours: "9:00 AM – 9:00 PM"),
    ]

    // MARK: Events
    let events: [Event] = {
        let cal = Calendar.current
        let now = Date()
        func date(_ daysFromNow: Int, hour: Int = 20) -> Date {
            cal.date(byAdding: .day, value: daysFromNow, to: cal.startOfDay(for: now))
                .flatMap { cal.date(bySettingHour: hour, minute: 0, second: 0, of: $0) } ?? now
        }
        return [
            Event(id: UUID(), title: "Vallarta Pride 2026",
                  description: "Puerto Vallarta's world-famous Pride festival. Week-long celebration in Zona Romántica with parades, concerts, beach parties, and the iconic Pride parade along the Malecón.",
                  neighborhood: .zonaRomantica,
                  address: "Zona Romántica & Malecón",
                  latitude: 20.5985, longitude: -105.2380,
                  startDate: date(14), endDate: date(21),
                  isPublic: true, isFree: true,
                  photos: ["calendar"], tags: ["Pride", "LGBT+", "Parade", "Festival", "Annual"],
                  organizer: "Vallarta Pride Organization", instagram: "@vallartapride",
                  isFeatured: true, isLGBTFriendly: true,
                  isRecurring: true, recurrenceLabel: "Annual"),

            Event(id: UUID(), title: "Moonlight Jazz at the Marina",
                  description: "Exclusive monthly jazz evening at Marina Vallarta's premier yacht club. Live jazz quartet, gourmet tapas, and craft cocktails under the stars. Limited tickets.",
                  neighborhood: .marina,
                  address: "Yacht Club Marina Vallarta",
                  latitude: 20.6715, longitude: -105.2545,
                  startDate: date(3, hour: 19), endDate: date(3, hour: 23),
                  isPublic: false, isFree: false, ticketPrice: 850,
                  photos: ["calendar"], tags: ["Jazz", "Live Music", "Cocktails", "Exclusive", "Marina"],
                  organizer: "Marina Yacht Club", isPremium: true,
                  isRecurring: true, recurrenceLabel: "Monthly"),

            Event(id: UUID(), title: "Sayulita Surf Competition",
                  description: "Annual amateur and pro surf competition at Playa Sayulita. Watch world-class surfers tear up the waves. Free entry for spectators, food and craft vendors.",
                  neighborhood: .sayulita,
                  address: "Playa Sayulita",
                  latitude: 20.8685, longitude: -105.4458,
                  startDate: date(7, hour: 8), endDate: date(9, hour: 18),
                  isPublic: true, isFree: true,
                  photos: ["calendar"], tags: ["Surf", "Competition", "Sayulita", "Sport", "Annual"],
                  organizer: "Sayulita Surf Club", isFeatured: true,
                  isRecurring: true, recurrenceLabel: "Annual"),

            Event(id: UUID(), title: "Gourmet Food & Wine Festival",
                  description: "Puerto Vallarta's renowned Gourmet Festival. 10 days of special menus, wine pairings, and culinary events at 50+ top restaurants. The ultimate foodie event in Mexico.",
                  neighborhood: .centro,
                  address: "Multiple venues, Puerto Vallarta",
                  latitude: 20.6060, longitude: -105.2370,
                  startDate: date(30, hour: 12), endDate: date(40, hour: 23),
                  isPublic: true, isFree: false, ticketPrice: 500,
                  photos: ["calendar"], tags: ["Gourmet", "Wine", "Restaurants", "Festival", "Annual"],
                  organizer: "Festival Gourmet International", isFeatured: true,
                  isRecurring: true, recurrenceLabel: "Annual - November"),

            Event(id: UUID(), title: "Thursday Night Art Walk",
                  description: "Every Thursday the Centro galleries open late for a self-guided art walk. Meet local and international artists, enjoy wine, and discover PV's thriving art scene.",
                  neighborhood: .centro,
                  address: "Zona Centro, starting at Galería Dante",
                  latitude: 20.6050, longitude: -105.2355,
                  startDate: date(4, hour: 18), endDate: date(4, hour: 22),
                  isPublic: true, isFree: true,
                  photos: ["calendar"], tags: ["Art", "Galleries", "Culture", "Wine", "Weekly"],
                  organizer: "PV Art Galleries Association",
                  isRecurring: true, recurrenceLabel: "Every Thursday"),

            Event(id: UUID(), title: "Sunset Beach Party — Blue Chairs",
                  description: "The legendary daily sunset party at Blue Chairs Resort on Los Muertos Beach. DJs, dancers, signature cocktails, and the best sunset view in town.",
                  neighborhood: .zonaRomantica,
                  address: "Blue Chairs Resort, Playa Los Muertos",
                  latitude: 20.5968, longitude: -105.2398,
                  startDate: date(1, hour: 17), endDate: date(1, hour: 21),
                  isPublic: true, isFree: true,
                  photos: ["calendar"], tags: ["Sunset", "DJ", "Beach", "LGBT+", "Daily"],
                  organizer: "Blue Chairs Resort", isFeatured: true, isLGBTFriendly: true,
                  isRecurring: true, recurrenceLabel: "Daily"),
        ]
    }()

    // MARK: Helpers
    func listings(for category: ListingCategory) -> [Listing] {
        listings.filter { $0.category == category }
    }

    var featuredListings: [Listing] {
        listings.filter { $0.isFeatured }
    }

    var featuredEvents: [Event] {
        events.filter { $0.isFeatured }
    }

    func search(_ query: String) -> [Listing] {
        guard !query.isEmpty else { return listings }
        let q = query.lowercased()
        return listings.filter {
            $0.name.lowercased().contains(q) ||
            $0.description.lowercased().contains(q) ||
            $0.tags.contains(where: { $0.lowercased().contains(q) }) ||
            $0.neighborhood.rawValue.lowercased().contains(q)
        }
    }
}
