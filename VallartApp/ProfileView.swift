import SwiftUI
import Supabase
import AuthenticationServices
import PhotosUI

// MARK: - ProfileView
struct ProfileView: View {
    @StateObject private var auth = AuthService.shared
    @State private var showingLogin = false
    @State private var savedListings: [Listing] = []
    @State private var savedLoaded = false
    @State private var myReviewCount: Int = 0
    @State private var myPhotoCount: Int = 0
    @State private var showEditName = false
    @State private var editNameText = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isUploadingAvatar = false
    @State private var showSavedSheet = false
    @State private var showSettings = false
    @State private var showDeleteConfirm = false
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.sand.ignoresSafeArea()
                if auth.isLoading {
                    ProgressView()
                } else if auth.isLoggedIn {
                    loggedInView
                } else {
                    guestView
                }
            }
            .navigationTitle(String(localized: "profile.title"))
            .navTitleMode(.large)
            .sheet(isPresented: $showingLogin) { LoginView() }
            .sheet(isPresented: $showSavedSheet) { savedSheet }
            .sheet(isPresented: $showSettings) { settingsSheet }
            .alert(String(localized: "profile.editName"), isPresented: $showEditName) {
                TextField(String(localized: "profile.namePlaceholder"), text: $editNameText)
                Button(String(localized: "profile.save")) { Task { await auth.updateName(editNameText) } }
                Button(String(localized: "profile.cancel"), role: .cancel) {}
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    guard let newItem,
                          let data = try? await newItem.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) else { return }
                    isUploadingAvatar = true
                    _ = await auth.uploadAvatar(image)
                    isUploadingAvatar = false
                }
            }
            .task(id: auth.profile?.savedListingIds.count) {
                if auth.isLoggedIn && !savedLoaded {
                    async let saved    = auth.fetchSavedListings()
                    async let reviews  = auth.fetchMyReviews()
                    let fetchedReviews = await reviews
                    savedListings    = await saved
                    myReviewCount    = fetchedReviews.count
                    myPhotoCount     = fetchedReviews.flatMap { $0.photos }.count
                    savedLoaded      = true
                }
            }
        }
    }

    // MARK: Guest
    private var guestView: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(AppTheme.Colors.mediumGray)

            VStack(spacing: AppTheme.Spacing.sm) {
                Text(String(localized: "profile.welcome"))
                    .font(AppTheme.Font.headline())
                    .foregroundStyle(AppTheme.Colors.deepNavy)
                Text(String(localized: "profile.welcomeHint"))
                    .font(AppTheme.Font.body())
                    .foregroundStyle(AppTheme.Colors.mediumGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.xl)
            }

            VStack(spacing: AppTheme.Spacing.sm) {
                Button { showingLogin = true } label: {
                    Text(String(localized: "profile.signIn"))
                        .font(AppTheme.Font.headline())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(AppTheme.Spacing.md)
                        .background(AppTheme.Colors.coral)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.full))
                }
            }
            .padding(.horizontal, AppTheme.Spacing.xl)

            Divider().padding(.horizontal, AppTheme.Spacing.xl)
            businessOwnerCTA
            Spacer()
        }
    }

    private var businessOwnerCTA: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text(String(localized: "profile.business.cta"))
                .font(AppTheme.Font.label())
                .foregroundStyle(AppTheme.Colors.deepNavy)
            Text(String(localized: "profile.business.hint"))
                .font(AppTheme.Font.caption())
                .foregroundStyle(AppTheme.Colors.mediumGray)
                .multilineTextAlignment(.center)
            Button { openURL(AppConfig.businessContactURL) } label: {
                Label(String(localized: "profile.business.add"), systemImage: "building.2.fill")
                    .font(AppTheme.Font.label())
                    .foregroundStyle(AppTheme.Colors.deepNavy)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.goldenSun.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.full))
            }
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
    }

    // MARK: Logged In
    private var loggedInView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppTheme.Spacing.lg) {

                // Avatar + Name
                VStack(spacing: AppTheme.Spacing.sm) {
                    ZStack(alignment: .bottomTrailing) {
                        // Avatar image
                        Group {
                            if let avatarUrl = auth.profile?.avatarUrl, let url = URL(string: avatarUrl) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let img):
                                        img.resizable().scaledToFill()
                                    default:
                                        avatarPlaceholder
                                    }
                                }
                            } else {
                                avatarPlaceholder
                            }
                        }
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(AppTheme.Colors.coral.opacity(0.3), lineWidth: 2))

                        // Upload overlay
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            ZStack {
                                Circle().fill(AppTheme.Colors.coral).frame(width: 28, height: 28)
                                if isUploadingAvatar {
                                    ProgressView().tint(.white).scaleEffect(0.6)
                                } else {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .offset(x: 4, y: 4)
                    }

                    // Name (tap to edit)
                    Button {
                        editNameText = auth.profile?.name ?? ""
                        showEditName = true
                    } label: {
                        HStack(spacing: 4) {
                            Text(auth.profile?.name ?? "Traveler")
                                .font(AppTheme.Font.headline())
                                .foregroundStyle(AppTheme.Colors.deepNavy)
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundStyle(AppTheme.Colors.mediumGray)
                        }
                    }


                    Text(auth.session?.user.email ?? "")
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(AppTheme.Colors.mediumGray)
                }
                .padding(.top, AppTheme.Spacing.lg)

                // Stats row
                HStack(spacing: 0) {
                    StatView(value: "\(myReviewCount)", label: String(localized: "profile.stats.reviews"))
                    Divider().frame(height: 40)
                    StatView(value: "\(auth.profile?.savedListingIds.count ?? 0)", label: String(localized: "profile.stats.saved"))
                    Divider().frame(height: 40)
                    StatView(value: "\(myPhotoCount)", label: String(localized: "profile.stats.photos"))
                }
                .background(AppTheme.Colors.white)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                .padding(.horizontal, AppTheme.Spacing.md)

                // Menu
                VStack(spacing: 0) {
                    Button { showSavedSheet = true } label: {
                        ProfileMenuItem(icon: "heart.fill", title: String(localized: "profile.menu.saved"), color: AppTheme.Colors.coral)
                    }
                    .buttonStyle(.plain)
                    Divider().padding(.leading, 52)
                    NavigationLink(destination: MyReviewsView()) {
                        ProfileMenuItem(icon: "star.fill", title: String(localized: "profile.menu.reviews"), color: AppTheme.Colors.goldenSun)
                    }
                    .buttonStyle(.plain)
                    Divider().padding(.leading, 52)
                    Button {
                        // Owners manage their listing on the web portal; everyone else contacts us
                        openURL(auth.profile?.isBusinessOwner == true ? AppConfig.businessURL : AppConfig.businessContactURL)
                    } label: {
                        ProfileMenuItem(
                            icon: "building.2.fill",
                            title: String(localized: auth.profile?.isBusinessOwner == true ? "profile.menu.business" : "profile.business.add"),
                            color: AppTheme.Colors.teal
                        )
                    }
                    .buttonStyle(.plain)
                    Divider().padding(.leading, 52)
                    Button {
                        if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        ProfileMenuItem(icon: "bell.fill", title: String(localized: "profile.menu.notifications"), color: AppTheme.Colors.nightPurple)
                    }
                    .buttonStyle(.plain)
                    Divider().padding(.leading, 52)
                    Button { showSettings = true } label: {
                        ProfileMenuItem(icon: "gearshape.fill", title: String(localized: "profile.menu.settings"), color: AppTheme.Colors.mediumGray)
                    }
                    .buttonStyle(.plain)
                }
                .background(AppTheme.Colors.white)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                .padding(.horizontal, AppTheme.Spacing.md)

                // Saved listings preview (top 3)
                if !savedListings.isEmpty {
                    savedPreviewSection
                }

                if let errMsg = auth.errorMessage {
                    Text(errMsg)
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(AppTheme.Colors.coral)
                        .padding(.horizontal, AppTheme.Spacing.xl)
                }

                Button { Task { await auth.signOut() } } label: {
                    Text(String(localized: "profile.signOut"))
                        .font(AppTheme.Font.label())
                        .foregroundStyle(AppTheme.Colors.coral)
                }
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
        }
    }

    // MARK: Settings Sheet
    private var settingsSheet: some View {
        NavigationStack {
            Form {
                Section(String(localized: "settings.support")) {
                    Link(String(localized: "settings.contact"), destination: AppConfig.supportMailURL)
                    Link(String(localized: "settings.privacy"), destination: AppConfig.privacyURL)
                    Link(String(localized: "settings.terms"), destination: AppConfig.termsURL)
                }
                Section {
                    Button(String(localized: "profile.signOut"), role: .destructive) {
                        Haptic.medium()
                        Task { await auth.signOut() }
                    }
                }
                Section {
                    Button(String(localized: "settings.deleteAccount"), role: .destructive) {
                        Haptic.medium()
                        showDeleteConfirm = true
                    }
                    .disabled(auth.isLoading)
                } footer: {
                    Text(String(localized: "settings.deleteAccount.footer"))
                }
                if let errMsg = auth.errorMessage {
                    Section {
                        Text(errMsg)
                            .font(AppTheme.Font.caption())
                            .foregroundStyle(AppTheme.Colors.coral)
                    }
                }
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(AppTheme.Colors.mediumGray)
                    }
                }
            }
            .navigationTitle(String(localized: "profile.menu.settings"))
            .navTitleMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "general.done")) { showSettings = false }
                        .foregroundStyle(AppTheme.Colors.coral)
                }
            }
            .alert(String(localized: "settings.deleteAccount.title"), isPresented: $showDeleteConfirm) {
                Button(String(localized: "settings.deleteAccount.confirm"), role: .destructive) {
                    Task {
                        if await auth.deleteAccount() {
                            showSettings = false
                            savedListings = []
                            savedLoaded = false
                        }
                    }
                }
                Button(String(localized: "profile.cancel"), role: .cancel) {}
            } message: {
                Text(String(localized: "settings.deleteAccount.message"))
            }
        }
    }

    private var avatarPlaceholder: some View {
        ZStack {
            Circle().fill(AppTheme.Colors.coral.opacity(0.15))
            Image(systemName: "person.fill")
                .font(.system(size: 44))
                .foregroundStyle(AppTheme.Colors.coral)
        }
    }

    // MARK: Saved Preview
    private var savedPreviewSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Text("Saved Places")
                    .font(AppTheme.Font.headline())
                    .foregroundStyle(AppTheme.Colors.deepNavy)
                Spacer()
                Button { showSavedSheet = true } label: {
                    Text(String(format: String(localized: "saved.seeAll"), savedListings.count))
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(AppTheme.Colors.coral)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)

            ForEach(savedListings.prefix(3)) { listing in
                NavigationLink(destination: ListingDetailView(listing: listing)) {
                    ListingRowView(listing: listing)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, AppTheme.Spacing.md)
            }
        }
    }

    // MARK: Saved Sheet (full list)
    private var savedSheet: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.sand.ignoresSafeArea()
                if savedListings.isEmpty {
                    VStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 50))
                            .foregroundStyle(AppTheme.Colors.mediumGray)
                        Text(String(localized: "saved.empty"))
                            .font(AppTheme.Font.headline())
                            .foregroundStyle(AppTheme.Colors.deepNavy)
                        Text(String(localized: "saved.emptyHint"))
                            .font(AppTheme.Font.body())
                            .foregroundStyle(AppTheme.Colors.mediumGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.Spacing.xl)
                    }
                } else {
                    List {
                        ForEach(savedListings) { listing in
                            NavigationLink(destination: ListingDetailView(listing: listing)) {
                                ListingRowView(listing: listing)
                            }
                            .listRowInsets(EdgeInsets(top: AppTheme.Spacing.sm, leading: AppTheme.Spacing.md, bottom: AppTheme.Spacing.sm, trailing: AppTheme.Spacing.md))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    Task {
                                        await auth.toggleSaved(listingID: listing.id)
                                        savedListings.removeAll { $0.id == listing.id }
                                    }
                                } label: {
                                    Label(String(localized: "saved.remove"), systemImage: "heart.slash.fill")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle(String(localized: "saved.title"))
            .navTitleMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "saved.done")) { showSavedSheet = false }
                }
            }
        }
    }
}

// MARK: - LoginView
struct LoginView: View {
    @StateObject private var auth = AuthService.shared
    @Environment(\.dismiss) private var dismiss

    @State private var email    = ""
    @State private var password = ""
    @State private var name     = ""
    @State private var mode: Mode = .signIn
    @State private var magicLinkSent = false

    enum Mode { case signIn, signUp, magicLink }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.sand.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // Logo
                        VStack(spacing: AppTheme.Spacing.sm) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppTheme.Colors.coral, AppTheme.Colors.goldenSun],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 90, height: 90)
                                    .shadow(color: AppTheme.Colors.coral.opacity(0.4), radius: 12, y: 4)
                                Image(systemName: "sun.max.fill")
                                    .font(.system(size: 38, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                            Text(AppConfig.appName)
                                .font(AppTheme.Font.display())
                                .foregroundStyle(AppTheme.Colors.deepNavy)
                            Text(AppConfig.tagline)
                                .font(AppTheme.Font.body())
                                .foregroundStyle(AppTheme.Colors.mediumGray)
                        }
                        .padding(.top, AppTheme.Spacing.xl)

                        // Mode picker
                        HStack(spacing: AppTheme.Spacing.sm) {
                            FilterChip(title: "Sign In",    isSelected: mode == .signIn)    { withAnimation { mode = .signIn } }
                            FilterChip(title: "Sign Up",    isSelected: mode == .signUp)    { withAnimation { mode = .signUp } }
                            FilterChip(title: "Magic Link", icon: "wand.and.stars",
                                       isSelected: mode == .magicLink) { withAnimation { mode = .magicLink } }
                        }
                        .padding(.horizontal, AppTheme.Spacing.xl)

                        if magicLinkSent {
                            magicLinkSentView
                        } else {
                            formFields
                            primaryButton
                            divider
                            appleSignInButton
                            if AppConfig.googleSignInEnabled { googleSignInButton }
                        }

                        if let err = auth.errorMessage {
                            Text(err)
                                .font(AppTheme.Font.caption())
                                .foregroundStyle(AppTheme.Colors.coral)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppTheme.Spacing.xl)
                        }

                        Spacer(minLength: AppTheme.Spacing.xxl)
                    }
                }
            }
            .navTitleMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onChange(of: auth.isLoggedIn) { _, loggedIn in
                if loggedIn { dismiss() }
            }
        }
    }

    // MARK: Sub-views
    private var formFields: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            if mode == .signUp {
                TextField("Full Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .inputAutocap(.words)
            }
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .inputAutocap(.never)
                .iOSKeyboard(.emailAddress)
            if mode != .magicLink {
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
    }

    private var primaryButton: some View {
        Button {
            Task {
                switch mode {
                case .signIn:
                    await auth.signIn(email: email, password: password)
                case .signUp:
                    await auth.signUp(email: email, password: password, name: name)
                case .magicLink:
                    magicLinkSent = await auth.sendMagicLink(email: email)
                }
            }
        } label: {
            Group {
                if auth.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(mode == .signIn ? "Sign In" : mode == .signUp ? "Create Account" : "Send Magic Link")
                        .font(AppTheme.Font.headline())
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.coral)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.full))
        }
        .disabled(auth.isLoading)
        .padding(.horizontal, AppTheme.Spacing.xl)
    }

    private var divider: some View {
        HStack {
            Rectangle().fill(AppTheme.Colors.mediumGray.opacity(0.3)).frame(height: 1)
            Text("or").font(AppTheme.Font.caption()).foregroundStyle(AppTheme.Colors.mediumGray)
            Rectangle().fill(AppTheme.Colors.mediumGray.opacity(0.3)).frame(height: 1)
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
    }

    @ViewBuilder
    private var appleSignInButton: some View {
#if os(iOS) || os(visionOS)
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            switch result {
            case .success(let auth):
                if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                    Task { await AuthService.shared.signInWithApple(credential: credential) }
                }
            case .failure(let error):
                AuthService.shared.errorMessage = error.localizedDescription
            }
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)
        .padding(.horizontal, AppTheme.Spacing.xl)
#else
        Button { } label: {
            Label("Sign in with Apple", systemImage: "applelogo")
                .font(AppTheme.Font.headline())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(.black)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.full))
        }
        .disabled(true)
        .padding(.horizontal, AppTheme.Spacing.xl)
#endif
    }

    private var googleSignInButton: some View {
        Button {
            Task { await auth.signInWithGoogle() }
        } label: {
            HStack {
                Image(systemName: "globe")
                Text("Sign in with Google")
                    .font(AppTheme.Font.headline())
            }
            .foregroundStyle(AppTheme.Colors.deepNavy)
            .frame(maxWidth: .infinity)
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.full))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.Radius.full)
                    .strokeBorder(AppTheme.Colors.mediumGray.opacity(0.3), lineWidth: 1.5)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
    }

    private var magicLinkSentView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "envelope.badge.fill")
                .font(.system(size: 60))
                .foregroundStyle(AppTheme.Colors.teal)
            Text("Check your email!")
                .font(AppTheme.Font.headline())
                .foregroundStyle(AppTheme.Colors.deepNavy)
            Text("We sent a magic link to \(email). Tap it to sign in — no password needed.")
                .font(AppTheme.Font.body())
                .foregroundStyle(AppTheme.Colors.mediumGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)
        }
    }
}

// MARK: - Helpers
struct StatView: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(AppTheme.Font.headline())
                .foregroundStyle(AppTheme.Colors.deepNavy)
            Text(label).font(AppTheme.Font.caption())
                .foregroundStyle(AppTheme.Colors.mediumGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.sm)
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 28)
            Text(title)
                .font(AppTheme.Font.body())
                .foregroundStyle(AppTheme.Colors.deepNavy)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppTheme.Colors.mediumGray)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.md)
    }
}
