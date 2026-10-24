import SwiftUI

/// "For you" screen: matches open projects to the student's skills.
/// Features a vertically balanced layout with the illustration blended seamlessly into
/// a full-screen edge-to-edge background, with no dead space at the bottom.
struct HomeView: View {
    @EnvironmentObject var app: AppModel
    @EnvironmentObject var tabCoordinator: TabCoordinator
    
    @State private var items: [MatchItem] = []
    @State private var error: String?
    @State private var loaded = false
    @State private var showNotifications = false

    /// Gender-based illustration: dynamically selects female or male character
    /// according to the user's saved avatar and gender preference.
    private var heroImageName: String {
        let gender = (app.me?.gender ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let avatar = (app.me?.avatarUrl ?? "").lowercased()
        
        if gender == "male" || avatar.contains("avatar_male") {
            return "hero_for_you_male"
        }
        return "hero_for_you_female"
    }

    var body: some View {
        NavigationStack {
            GeometryReader { screenGeo in
                let screenWidth = screenGeo.size.width
                let screenHeight = screenGeo.size.height
                let isCompact = screenHeight < 720
                
                // Bottom tab bar estimate including home indicator safe area
                let safeAreaBottom = screenGeo.safeAreaInsets.bottom
                let bottomBarHeight: CGFloat = 62 + safeAreaBottom
                
                // Hero illustration spans gracefully across 72% of the screen height
                let heroHeight = max(screenHeight * 0.72, 520)
                let illustrationTopOffset: CGFloat = isCompact ? 36 : 50
                
                // Effective scrollable viewport height above the bottom bar
                let availableContentHeight = screenHeight - bottomBarHeight

                ZStack(alignment: .top) {
                    // 1. Full-bleed Base Canvas
                    Theme.creamBackground
                        .ignoresSafeArea()

                    // 2. Seamless Full-Screen Background Illustration (Edge-to-Edge)
                    ZStack(alignment: .top) {
                        Image(heroImageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth, height: heroHeight)
                            .clipped()

                        // Soft organic watercolor fade at the bottom of the artwork
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.65),
                                .init(color: Theme.creamBackground.opacity(0.3), location: 0.82),
                                .init(color: Theme.creamBackground.opacity(0.8), location: 0.94),
                                .init(color: Theme.creamBackground, location: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(width: screenWidth, height: heroHeight)
                    }
                    .frame(width: screenWidth, height: heroHeight, alignment: .top)
                    .offset(y: illustrationTopOffset)

                    // 3. Foreground Scrollable Content (Vertically Rebalanced)
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            // Header Section floating over the top canvas
                            headerSection
                                .padding(.top, 10)
                                .padding(.bottom, 4)

                            // Floating Motivational Doodle ("Learn / Build / Grow / Together")
                            HStack {
                                Spacer()
                                motivationalDoodle
                                    .padding(.trailing, 28)
                                    .padding(.top, 4)
                            }

                            // Dynamic Expanding Spacer:
                            // Automatically uses the available screen height to showcase the character
                            // while pushing the project card down near the bottom tab bar.
                            Spacer(minLength: isCompact ? 40 : 80)

                            // Content Cards floating over the desk & watercolor base
                            VStack(alignment: .leading, spacing: 16) {
                                // Missing Resume Callout
                                if let me = app.me, !me.hasResume {
                                    resumePromptCard
                                }

                                // Error Banner
                                if let error = error {
                                    errorCard(error)
                                }

                                // Main Feed (Empty State or Recommended Matches)
                                if items.isEmpty && loaded && error == nil {
                                    emptyStateCard
                                } else if !items.isEmpty {
                                    matchedProjectsList
                                }
                            }
                            .padding(.bottom, 22) // Sits naturally 22pt above the bottom navigation dock
                        }
                        .frame(minHeight: availableContentHeight, alignment: .top)
                        .padding(.bottom, bottomBarHeight)
                    }
                    .refreshable {
                        await load()
                    }
                    .task {
                        await load()
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showNotifications) {
                NotificationsSheet()
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text("Good to see you!")
                        .font(.system(size: 27, weight: .bold, design: .serif))
                        .foregroundColor(Theme.forestGreen)
                    
                    Text("👋")
                        .font(.system(size: 24))
                }
                
                Text("Discover projects that match your skills and grow together.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Theme.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 8)
            
            // Notification Bell Button with Terracotta Unread Dot Badge
            Button {
                showNotifications = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Theme.creamCard)
                        .frame(width: 44, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Theme.cardBorder, lineWidth: 1)
                        )
                        .shadow(color: Theme.shadow, radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "bell")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Theme.forestGreen)
                        .frame(width: 44, height: 44)
                    
                    // Terracotta Badge Dot
                    Circle()
                        .fill(Theme.terracotta)
                        .frame(width: 9, height: 9)
                        .offset(x: -7, y: 7)
                }
            }
            .buttonStyle(ScalePressStyle())
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Floating Motivational Doodle
    private var motivationalDoodle: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 3) {
                Text("Learn")
                Image(systemName: "sparkle")
                    .font(.system(size: 8))
                    .foregroundColor(Theme.terracotta)
            }
            Text("Build")
            Text("Grow")
            Text("Together")
        }
        .font(.system(size: 13, weight: .medium, design: .serif))
        .italic()
        .foregroundColor(Theme.textSecondary.opacity(0.85))
    }

    // MARK: - Empty State Card
    private var emptyStateCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                // Folder icon with soft beige squircle & decorative doodle rays
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Theme.folderBg)
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: "folder.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Theme.forestGreen)
                    
                    DoodleRays()
                        .offset(x: 18, y: -16)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("No open projects match yet.")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("Check back soon, or start your own on the Projects tab.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Theme.textSecondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            // "Explore Projects" Action Button
            Button {
                tabCoordinator.selectedTab = .projects
            } label: {
                HStack(spacing: 8) {
                    Text("Explore Projects")
                        .font(.system(size: 15, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    Capsule()
                        .fill(Theme.forestGreen)
                )
                .shadow(color: Theme.forestGreen.opacity(0.22), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(ScalePressStyle())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Theme.creamCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Theme.cardBorder, lineWidth: 1)
                )
                .shadow(color: Theme.shadow, radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Matched Projects List
    private var matchedProjectsList: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Projects that fit you")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Theme.forestGreen)
                
                Spacer()
                
                Text("\(items.count) recommended")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Theme.forestGreen)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.forestGreenPill)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            
            ForEach(items) { item in
                if let projectId = item.projectId {
                    NavigationLink(destination: ProjectDetailView(projectId: projectId)) {
                        ForYouProjectCard(item: item)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    // MARK: - Resume Prompt Card
    private var resumePromptCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Theme.terracottaLight)
                        .frame(width: 42, height: 42)
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Theme.terracotta)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Add your resume")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Theme.terracottaDark)
                    Text("Upload your resume on the Profile tab to unlock personalized AI matches.")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary)
                        .lineSpacing(2)
                }
            }
            
            Button {
                tabCoordinator.selectedTab = .profile
            } label: {
                HStack(spacing: 6) {
                    Text("Go to Profile")
                        .font(.system(size: 13, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(Theme.terracottaDark)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(Theme.terracottaBorder.opacity(0.6))
                )
            }
            .buttonStyle(ScalePressStyle())
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.terracottaLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Theme.terracottaBorder, lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Error Card
    private func errorCard(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(Theme.terracotta)
            Text(message)
                .font(.footnote)
                .foregroundColor(Theme.textPrimary)
            Spacer()
            Button("Retry") {
                Task { await load() }
            }
            .font(.footnote.weight(.semibold))
            .foregroundColor(Theme.forestGreen)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.creamCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Theme.terracottaBorder, lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Network Request
    private func load() async {
        do {
            let response: MatchResponse = try await API.shared.get("/api/recommendations/projects")
            items = response.results
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
        loaded = true
    }
}

// MARK: - Dedicated Project Card for the "For You" Feed
struct ForYouProjectCard: View {
    let item: MatchItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row: Title & Match Percentage Badge
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    if !item.needRole.isEmpty {
                        HStack(spacing: 6) {
                            Text("Role:")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Theme.textMuted)
                            Text(item.needRole)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Theme.forestGreen)
                        }
                    }
                }
                
                Spacer()
                
                // Match percentage badge
                HStack(spacing: 3) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10, weight: .bold))
                    Text("\(item.percent)%")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(item.percent >= 70 ? Theme.forestGreen : (item.percent >= 45 ? Theme.terracotta : Theme.textMuted))
                )
            }
            
            // Domain badge
            if let domain = item.domain, !domain.isEmpty {
                HStack {
                    Text(domain)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Theme.forestGreen)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Theme.forestGreenLight)
                        .clipShape(Capsule())
                    Spacer()
                }
            }
            
            // "Why this match" reason box
            if !item.why.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Rectangle()
                        .fill(Theme.terracotta)
                        .frame(width: 3)
                        .cornerRadius(1.5)
                    
                    Text(item.why)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Theme.textSecondary)
                        .lineSpacing(2)
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 2)
            }
            
            // Matched skills chips
            if !item.matchedSkills.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(item.matchedSkills, id: \.self) { skill in
                            Text(skill)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Theme.forestGreen)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Theme.forestGreenPill)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            // Footer with chevron
            HStack {
                Text("View Project Details")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Theme.forestGreen)
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Theme.forestGreen)
                Spacer()
            }
            .padding(.top, 2)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Theme.creamCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Theme.cardBorder, lineWidth: 1)
                )
                .shadow(color: Theme.shadow, radius: 8, x: 0, y: 3)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Doodle Rays Decorative Component
struct DoodleRays: View {
    var body: some View {
        HStack(spacing: 3) {
            Circle()
                .fill(Theme.terracotta.opacity(0.8))
                .frame(width: 3, height: 3)
            Circle()
                .fill(Theme.terracotta.opacity(0.8))
                .frame(width: 4, height: 4)
            Circle()
                .fill(Theme.terracotta.opacity(0.8))
                .frame(width: 2.5, height: 2.5)
        }
    }
}

// MARK: - Notifications Sheet
struct NotificationsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.creamBackground.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Theme.forestGreenLight)
                            .frame(width: 64, height: 64)
                        Image(systemName: "bell.badge")
                            .font(.system(size: 28))
                            .foregroundColor(Theme.forestGreen)
                    }
                    .padding(.top, 40)
                    
                    Text("Notifications")
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(Theme.forestGreen)
                    
                    Text("You're all caught up! New project matches and invitations will appear here.")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.forestGreen)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Subtle Button Scale Press Style
struct ScalePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
