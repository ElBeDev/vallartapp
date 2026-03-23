import SwiftUI
import Combine

// MARK: - SearchView
struct SearchView: View {
    @StateObject private var vm = SearchViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.sand.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    searchBar
                        .padding(AppTheme.Spacing.md)

                    // Active filters
                    if vm.hasActiveFilters {
                        activeFiltersBar
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.bottom, AppTheme.Spacing.sm)
                    }

            // Results
            if vm.query.isEmpty && !vm.hasActiveFilters {
                browseByCategory
            } else if vm.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if vm.results.isEmpty {
                        emptyState
                    } else {
                        resultsList
                    }
                }
            }
            .navigationTitle("Search")
            .navTitleMode(.large)
            .sheet(isPresented: $vm.showingFilters) {
                FilterSheetView(vm: vm)
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppTheme.Colors.mediumGray)
                TextField("Restaurants, bars, activities...", text: $vm.query)
                    .font(AppTheme.Font.body())
                if !vm.query.isEmpty {
                    Button { vm.query = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppTheme.Colors.mediumGray)
                    }
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.full))
            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)

            Button { vm.showingFilters = true } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(vm.hasActiveFilters ? .white : AppTheme.Colors.deepNavy)
                    .padding(AppTheme.Spacing.md)
                    .background(vm.hasActiveFilters ? AppTheme.Colors.coral : AppTheme.Colors.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
            }
        }
    }

    private var activeFiltersBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.xs) {
                if let cat = vm.selectedCategory {
                    ActiveFilterChip(text: cat.rawValue) { vm.selectedCategory = nil }
                }
                if let neighborhood = vm.selectedNeighborhood {
                    ActiveFilterChip(text: neighborhood.displayName) { vm.selectedNeighborhood = nil }
                }
                if vm.openNowOnly {
                    ActiveFilterChip(text: "Open Now") { vm.openNowOnly = false }
                }
                if vm.lgbtFriendlyOnly {
                    ActiveFilterChip(text: "LGBT+ Friendly") { vm.lgbtFriendlyOnly = false }
                }
            }
        }
    }

    private var browseByCategory: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                      spacing: AppTheme.Spacing.md) {
                ForEach(ListingCategory.allCases) { cat in
                    NavigationLink(destination: CategoryListView(category: cat)) {
                        CategoryGridCard(category: cat)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppTheme.Spacing.md)
            .padding(.bottom, AppTheme.Spacing.xxl)
        }
    }

    private var resultsList: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text("\(vm.results.count) results")
                    .font(AppTheme.Font.caption())
                    .foregroundStyle(AppTheme.Colors.mediumGray)
                    .padding(.horizontal, AppTheme.Spacing.md)

                LazyVStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(vm.results) { listing in
                        NavigationLink(destination: ListingDetailView(listing: listing)) {
                            ListingRowView(listing: listing)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, AppTheme.Spacing.md)
                    }
                }
            }
            .padding(.bottom, AppTheme.Spacing.xxl)
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.Colors.mediumGray)
            Text("No results found")
                .font(AppTheme.Font.headline())
                .foregroundStyle(AppTheme.Colors.deepNavy)
            Text("Try different keywords or filters")
                .font(AppTheme.Font.body())
                .foregroundStyle(AppTheme.Colors.mediumGray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - SearchViewModel
class SearchViewModel: ObservableObject {
    @Published var query: String = "" { didSet { scheduleSearch() } }
    @Published var selectedCategory: ListingCategory? = nil { didSet { Task { await runSearch() } } }
    @Published var selectedNeighborhood: Neighborhood? = nil { didSet { Task { await runSearch() } } }
    @Published var openNowOnly: Bool = false { didSet { Task { await runSearch() } } }
    @Published var lgbtFriendlyOnly: Bool = false { didSet { Task { await runSearch() } } }
    @Published var showingFilters: Bool = false
    @Published var results: [Listing] = []
    @Published var isLoading = false

    private let repo: ListingRepositoryProtocol = SupabaseListingRepository.shared
    private var searchTask: Task<Void, Never>?

    var hasActiveFilters: Bool {
        selectedCategory != nil || selectedNeighborhood != nil || openNowOnly || lgbtFriendlyOnly
    }

    // Debounce 0.35s on query changes
    private func scheduleSearch() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            await runSearch()
        }
    }

    @MainActor
    func runSearch() async {
        guard !query.isEmpty || hasActiveFilters else { results = []; return }
        isLoading = true
        do {
            results = try await repo.search(
                query: query,
                category: selectedCategory,
                neighborhood: selectedNeighborhood,
                openOnly: openNowOnly,
                lgbtOnly: lgbtFriendlyOnly
            )
        } catch {
            results = []
        }
        isLoading = false
    }
}

// MARK: - FilterSheetView
struct FilterSheetView: View {
    @ObservedObject var vm: SearchViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Category", selection: $vm.selectedCategory) {
                        Text("All").tag(Optional<ListingCategory>.none)
                        ForEach(ListingCategory.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(Optional(cat))
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Neighborhood") {
                    Picker("Neighborhood", selection: $vm.selectedNeighborhood) {
                        Text("All").tag(Optional<Neighborhood>.none)
                        ForEach(Neighborhood.allCases, id: \.self) { hood in
                            Text(hood.displayName).tag(Optional(hood))
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Options") {
                    Toggle("Open Now", isOn: $vm.openNowOnly)
                    Toggle("LGBT+ Friendly", isOn: $vm.lgbtFriendlyOnly)
                }

                Section {
                    Button("Clear All Filters", role: .destructive) {
                        vm.selectedCategory = nil
                        vm.selectedNeighborhood = nil
                        vm.openNowOnly = false
                        vm.lgbtFriendlyOnly = false
                    }
                }
            }
            .navigationTitle("Filters")
            .navTitleMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.coral)
                }
            }
        }
    }
}
