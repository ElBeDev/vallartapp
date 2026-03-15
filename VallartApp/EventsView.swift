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
                FilterChip(title: "All", isSelected: vm.filter == .all) { vm.filter = .all }
                FilterChip(title: "Free", isSelected: vm.filter == .free) { vm.filter = .free }
                FilterChip(title: "This Week", isSelected: vm.filter == .thisWeek) { vm.filter = .thisWeek }
                FilterChip(title: "Public", isSelected: vm.filter == .publicOnly) { vm.filter = .publicOnly }
                FilterChip(title: "LGBT+", isSelected: vm.filter == .lgbt) { vm.filter = .lgbt }
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
                    RoundedRectangle(cornerRadius: 0)
                        .fill(AppTheme.Colors.coral.opacity(0.15))
                        .frame(height: 260)
                        .overlay {
                            Image(systemName: event.heroPhoto)
                                .font(.system(size: 80))
                                .foregroundStyle(AppTheme.Colors.coral)
                        }

                    // Badges overlay
                    HStack(spacing: AppTheme.Spacing.xs) {
                        BadgeView(text: event.isPublic ? "Public" : "Private",
                                  color: event.isPublic ? AppTheme.Colors.palmGreen : AppTheme.Colors.nightPurple)
                        if event.isFree {
                            BadgeView(text: "Free", color: AppTheme.Colors.teal)
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

                        Label(event.neighborhood.rawValue, systemImage: "location.fill")
                            .font(AppTheme.Font.caption())
                            .foregroundStyle(AppTheme.Colors.mediumGray)
                    }

                    Divider()

                    // Price
                    if !event.isFree, let price = event.ticketPrice {
                        HStack {
                            Text("Tickets from")
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
                    Text("About")
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
                            Text("Organized by")
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
                            Text("Get Tickets")
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
            case .free:       filteredEvents = try await repo.fetchFiltered(isFree: true, isPublic: nil, isLGBT: nil, withinDays: nil)
            case .thisWeek:   filteredEvents = try await repo.fetchFiltered(isFree: nil, isPublic: nil, isLGBT: nil, withinDays: 7)
            case .publicOnly: filteredEvents = try await repo.fetchFiltered(isFree: nil, isPublic: true, isLGBT: nil, withinDays: nil)
            case .lgbt:       filteredEvents = try await repo.fetchFiltered(isFree: nil, isPublic: nil, isLGBT: true, withinDays: nil)
            }
        } catch {
            // Fallback to mock
            let mock = MockDataService.shared
            let all = mock.events
            switch filter {
            case .all:        filteredEvents = all
            case .free:       filteredEvents = all.filter { $0.isFree }
            case .thisWeek:
                let end = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
                filteredEvents = all.filter { $0.startDate <= end }
            case .publicOnly: filteredEvents = all.filter { $0.isPublic }
            case .lgbt:       filteredEvents = all.filter { $0.isLGBTFriendly }
            }
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

                Text(event.neighborhood.rawValue)
                    .font(AppTheme.Font.caption())
                    .foregroundStyle(AppTheme.Colors.mediumGray)

                HStack(spacing: AppTheme.Spacing.xs) {
                    BadgeView(text: event.isPublic ? "Public" : "Private",
                              color: event.isPublic ? AppTheme.Colors.palmGreen : AppTheme.Colors.nightPurple)
                    if event.isFree {
                        BadgeView(text: "Free", color: AppTheme.Colors.teal)
                    }
                    if event.isRecurring, let label = event.recurrenceLabel {
                        BadgeView(text: label, color: AppTheme.Colors.goldenSun)
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
