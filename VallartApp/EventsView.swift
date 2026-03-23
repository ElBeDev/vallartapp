import SwiftUI
import Combine

// MARK: - EventsView
struct EventsView: View {
    @StateObject private var vm = EventsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.sand.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Filter chips
                    filterBar
                        .padding(.vertical, AppTheme.Spacing.sm)

                    if vm.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if vm.filteredEvents.isEmpty {
                        emptyState
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: AppTheme.Spacing.md) {
                                ForEach(vm.filteredEvents) { event in
                                    NavigationLink(destination: EventDetailView(event: event)) {
                                        EventListRowView(event: event)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.bottom, AppTheme.Spacing.xxl)
                        }
                    }
                }
            }
            .navigationTitle("Events")
            .navTitleMode(.large)
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                FilterChip(title: String(localized: "events.filter.all"),      isSelected: vm.filter == .all)      { vm.filter = .all }
                FilterChip(title: String(localized: "events.filter.free"),     isSelected: vm.filter == .free)     { vm.filter = .free }
                FilterChip(title: String(localized: "events.filter.thisWeek"), isSelected: vm.filter == .thisWeek) { vm.filter = .thisWeek }
                FilterChip(title: String(localized: "events.filter.public"),   isSelected: vm.filter == .publicOnly) { vm.filter = .publicOnly }
                FilterChip(title: String(localized: "events.filter.lgbt"),     isSelected: vm.filter == .lgbt)     { vm.filter = .lgbt }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.Colors.mediumGray)
            Text("No events found")
                .font(AppTheme.Font.headline())
                .foregroundStyle(AppTheme.Colors.deepNavy)
            Text("Try a different filter")
                .font(AppTheme.Font.body())
                .foregroundStyle(AppTheme.Colors.mediumGray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - EventDetailView
struct EventDetailView: View {
    let event: Event
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Hero
                ZStack(alignment: .topLeading) {
                    // Real photo or gradient fallback
                    Group {
                        if let photoUrl = event.photos.first, let url = URL(string: photoUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let img):
                                    img.resizable().scaledToFill()
                                default:
                                    heroFallback
                                }
                            }
                        } else {
                            heroFallback
                        }
                    }
                    .frame(height: 280)
                    .clipped()

                    // Dark gradient overlay so text is always readable
                    LinearGradient(
                        colors: [.black.opacity(0.45), .clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(height: 280)

                    // Badges overlay
                    HStack(spacing: AppTheme.Spacing.xs) {
                        BadgeView(text: event.isPublic ? String(localized: "events.badge.public") : String(localized: "events.badge.private"),
                                  color: event.isPublic ? AppTheme.Colors.palmGreen : AppTheme.Colors.nightPurple)
                        if event.isFree {
                            BadgeView(text: String(localized: "events.badge.free"), color: AppTheme.Colors.teal)
                        }
                        if event.isLGBTFriendly {
                            BadgeView(text: "LGBT+", color: AppTheme.Colors.nightPurple)
                        }
                    }
                    .padding(AppTheme.Spacing.md)
                }

                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    // Title
                    Text(event.title)
                        .font(AppTheme.Font.display(26))
                        .foregroundStyle(AppTheme.Colors.deepNavy)

                    // Date & Location
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Label(event.formattedDate, systemImage: "calendar")
                            .font(AppTheme.Font.label())
                            .foregroundStyle(AppTheme.Colors.coral)

                        if event.isRecurring, let label = event.recurrenceLabel {
                            Label(label, systemImage: "repeat")
                                .font(AppTheme.Font.caption())
                                .foregroundStyle(AppTheme.Colors.mediumGray)
                        }

                        Label(event.address, systemImage: "mappin.circle.fill")
                            .font(AppTheme.Font.label())
                            .foregroundStyle(AppTheme.Colors.deepNavy)

                        Label(event.neighborhood.displayName, systemImage: "location.fill")
                            .font(AppTheme.Font.caption())
                            .foregroundStyle(AppTheme.Colors.mediumGray)
                    }

                    Divider()

                    // Price
                    if !event.isFree, let price = event.ticketPrice {
                        HStack {
                            Text(String(localized: "events.ticketsFrom"))
                                .font(AppTheme.Font.label())
                                .foregroundStyle(AppTheme.Colors.mediumGray)
                            Spacer()
                            Text("MXN $\(Int(price))")
                                .font(AppTheme.Font.headline())
                                .foregroundStyle(AppTheme.Colors.coral)
                        }
                        .padding(AppTheme.Spacing.md)
                        .background(AppTheme.Colors.lightGray)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                    }

                    // Description
                    Text(String(localized: "events.about"))
                        .font(AppTheme.Font.headline())
                        .foregroundStyle(AppTheme.Colors.deepNavy)

                    Text(event.description)
                        .font(AppTheme.Font.body())
                        .foregroundStyle(AppTheme.Colors.deepNavy.opacity(0.8))
                        .lineSpacing(4)

                    // Organizer
                    Divider()

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(localized: "events.organizedBy"))
                                .font(AppTheme.Font.caption())
                                .foregroundStyle(AppTheme.Colors.mediumGray)
                            Text(event.organizer)
                                .font(AppTheme.Font.label())
                                .foregroundStyle(AppTheme.Colors.deepNavy)
                        }
                        Spacer()
                        if let ig = event.instagram {
                            Link(destination: URL(string: "https://instagram.com/\(ig.replacingOccurrences(of: "@", with: ""))")!) {
                                Image(systemName: "camera.fill")
                                    .foregroundStyle(AppTheme.Colors.nightPurple)
                            }
                        }
                    }

                    // Tags
                    FlowTagsView(tags: event.tags)

                    // CTA
                    if let urlStr = event.ticketURL, let url = URL(string: urlStr) {
                        Link(destination: url) {
                            Text(String(localized: "events.getTickets"))
                                .font(AppTheme.Font.headline())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(AppTheme.Spacing.md)
                                .background(AppTheme.Colors.coral)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.full))
                        }
                    }
                }
                .padding(AppTheme.Spacing.md)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navTitleMode(.inline)
    }

    private var heroFallback: some View {
        ZStack {
            LinearGradient(
                colors: [AppTheme.Colors.coral.opacity(0.8), AppTheme.Colors.nightPurple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 72, weight: .light))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

// MARK: - EventsViewModel
class EventsViewModel: ObservableObject {
    enum Filter: Equatable { case all, free, thisWeek, publicOnly, lgbt }

    @Published var filter: Filter = .all { didSet { Task { await applyFilter() } } }
    @Published var filteredEvents: [Event] = []
    @Published var isLoading = false

    private let repo: EventRepositoryProtocol = SupabaseEventRepository.shared

    init() { Task { await applyFilter() } }

    @MainActor
    func applyFilter() async {
        isLoading = true
        do {
            switch filter {
            case .all:        filteredEvents = try await repo.fetchAll()
            case .free:       filteredEvents = try await repo.fetchFiltered(isFree: true,  isPublic: nil,  isLGBT: nil,  withinDays: nil)
            case .thisWeek:   filteredEvents = try await repo.fetchFiltered(isFree: nil,   isPublic: nil,  isLGBT: nil,  withinDays: 7)
            case .publicOnly: filteredEvents = try await repo.fetchFiltered(isFree: nil,   isPublic: true, isLGBT: nil,  withinDays: nil)
            case .lgbt:       filteredEvents = try await repo.fetchFiltered(isFree: nil,   isPublic: nil,  isLGBT: true, withinDays: nil)
            }
        } catch {
            filteredEvents = []
        }
        isLoading = false
    }
}

// MARK: - EventListRowView
struct EventListRowView: View {
    let event: Event

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Date badge
            VStack(spacing: 2) {
                Text(dayString)
                    .font(AppTheme.Font.caption(10))
                    .foregroundStyle(AppTheme.Colors.coral)
                    .textCase(.uppercase)
                Text(dayNumber)
                    .font(AppTheme.Font.display(22))
                    .foregroundStyle(AppTheme.Colors.deepNavy)
            }
            .frame(width: 50)
            .padding(AppTheme.Spacing.xs)
            .background(AppTheme.Colors.coral.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(event.title)
                    .font(AppTheme.Font.label())
                    .foregroundStyle(AppTheme.Colors.deepNavy)
                    .lineLimit(2)

                Text(event.neighborhood.displayName)
                    .font(AppTheme.Font.caption())
                    .foregroundStyle(AppTheme.Colors.mediumGray)

                HStack(spacing: AppTheme.Spacing.xs) {
                    BadgeView(text: event.isPublic ? "Public" : "Private",
                              color: event.isPublic ? AppTheme.Colors.palmGreen : AppTheme.Colors.nightPurple)
                    if event.isFree {
                        BadgeView(text: "Free", color: AppTheme.Colors.teal)
                    }
                    if event.isRecurring, let label = event.recurrenceLabel {
                        BadgeView(text: label, color: AppTheme.Colors.goldenSun, textColor: AppTheme.Colors.deepNavy)
                    }
                }
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppTheme.Colors.mediumGray)
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var dayString: String {
        let f = DateFormatter(); f.dateFormat = "EEE"
        return f.string(from: event.startDate)
    }
    private var dayNumber: String {
        let f = DateFormatter(); f.dateFormat = "d"
        return f.string(from: event.startDate)
    }
}
