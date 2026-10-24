import SwiftUI

/// "Projects" screen: displays projects with a warm cream, forest-green, and terracotta theme.
/// Features a seamless watercolor illustrated empty state, custom tab pills, and responsive cards.
struct ProjectsView: View {
    @State private var scope = "mine"
    @State private var projects: [ProjectSummary] = []
    @State private var error: String?
    @State private var creating = false
    @State private var loaded = false

    var body: some View {
        NavigationStack {
            GeometryReader { screenGeo in
                let screenWidth = screenGeo.size.width
                let screenHeight = screenGeo.size.height
                let safeAreaBottom = screenGeo.safeAreaInsets.bottom
                let bottomBarHeight: CGFloat = 62 + safeAreaBottom
                let availableContentHeight = screenHeight - bottomBarHeight

                ZStack(alignment: .top) {
                    // 1. Full-bleed Warm Cream Base Canvas
                    Theme.creamBackground
                        .ignoresSafeArea()

                    // 2. Foreground Scrollable Content
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            // Top Header: Title, Subtitle & Action Button with Doodle Rays
                            headerSection
                                .padding(.top, 10)
                                .padding(.bottom, 16)

                            // Segmented Filter Pill: "My projects" vs "Open projects"
                            segmentedFilterSection
                                .padding(.bottom, 16)

                            // Error Banner (if any)
                            if let error = error {
                                errorCard(error)
                                    .padding(.bottom, 14)
                            }

                            // Main Feed: Empty State or Populated Project List
                            if projects.isEmpty && loaded && error == nil {
                                emptyStateSection(screenWidth: screenWidth)
                            } else if !projects.isEmpty {
                                projectCardsList
                            }

                            // Bottom breathing room above the docked tab bar
                            Spacer()
                                .frame(height: 105)
                        }
                        .frame(minHeight: availableContentHeight, alignment: .top)
                        .padding(.bottom, bottomBarHeight)
                    }
                    .refreshable {
                        await load()
                    }
                    .task(id: scope) {
                        await load()
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $creating, onDismiss: { Task { await load() } }) {
                CreateProjectView()
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Projects")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(Theme.forestGreen)

                Text("Turn your ideas into reality\nwith the right people.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Theme.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            // Circular Add Button with Warm Doodle Rays
            ZStack(alignment: .trailing) {
                // 3 warm terracotta doodle rays radiating outward to the left
                ZStack {
                    Capsule()
                        .fill(Theme.terracotta.opacity(0.85))
                        .frame(width: 11, height: 2.5)
                        .rotationEffect(.degrees(-28))
                        .offset(x: -30, y: -10)

                    Capsule()
                        .fill(Theme.terracotta.opacity(0.85))
                        .frame(width: 13, height: 2.5)
                        .offset(x: -33, y: 0)

                    Capsule()
                        .fill(Theme.terracotta.opacity(0.85))
                        .frame(width: 11, height: 2.5)
                        .rotationEffect(.degrees(28))
                        .offset(x: -30, y: 10)
                }
                .frame(width: 44, height: 44)

                // Forest Green Circular Plus Button
                Button {
                    creating = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Theme.forestGreen)
                            .frame(width: 44, height: 44)
                            .shadow(color: Theme.forestGreen.opacity(0.25), radius: 5, x: 0, y: 3)

                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(ScalePressStyle())
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Segmented Filter Section
    private var segmentedFilterSection: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    scope = "mine"
                }
            } label: {
                Text("My projects")
                    .font(.system(size: 14, weight: scope == "mine" ? .semibold : .medium))
                    .foregroundColor(scope == "mine" ? .white : Theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(
                        Group {
                            if scope == "mine" {
                                Capsule()
                                    .fill(Theme.forestGreen)
                                    .shadow(color: Theme.forestGreen.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                        }
                    )
            }
            .buttonStyle(PlainButtonStyle())

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    scope = "open"
                }
            } label: {
                Text("Open projects")
                    .font(.system(size: 14, weight: scope == "open" ? .semibold : .medium))
                    .foregroundColor(scope == "open" ? .white : Theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(
                        Group {
                            if scope == "open" {
                                Capsule()
                                    .fill(Theme.forestGreen)
                                    .shadow(color: Theme.forestGreen.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                        }
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Theme.folderBg)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Empty State Section
    private func emptyStateSection(screenWidth: CGFloat) -> some View {
        VStack(spacing: 16) {
            Spacer(minLength: 16)

            // Centered Storybook Watercolor Folder Illustration (blended seamlessly into cream canvas)
            Image("hero_projects_empty")
                .resizable()
                .scaledToFit()
                .blendMode(.multiply)
                .mask(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: .black, location: 0.52),
                            .init(color: .black.opacity(0.85), location: 0.70),
                            .init(color: .clear, location: 0.94)
                        ]),
                        center: .center,
                        startRadius: 75,
                        endRadius: 145
                    )
                )
                .frame(maxWidth: min(screenWidth * 0.74, 300))
                .padding(.vertical, 4)

            // Empty State Headings
            VStack(spacing: 6) {
                Text(scope == "mine" ? "You are not in a project yet." : "No open projects right now.")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text(scope == "mine" ? "Tap + to start one." : "Be the first to start a project for others to join.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Theme.textSecondary)
            }

            // "Create a Project" Pill Button
            Button {
                creating = true
            } label: {
                HStack(spacing: 8) {
                    Text("Create a Project")
                        .font(.system(size: 15, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .frame(height: 48)
                .background(
                    Capsule()
                        .fill(Theme.forestGreen)
                )
                .shadow(color: Theme.forestGreen.opacity(0.22), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(ScalePressStyle())
            .padding(.top, 6)

            Spacer(minLength: 30)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Populated Projects Cards List
    private var projectCardsList: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(scope == "mine" ? "Your Projects" : "Open Opportunities")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Theme.forestGreen)

                Spacer()

                Text("\(projects.count) project\(projects.count == 1 ? "" : "s")")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Theme.forestGreen)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.forestGreenPill)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)

            ForEach(projects) { project in
                NavigationLink(destination: ProjectDetailView(projectId: project.id)) {
                    ProjectCardView(project: project)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
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
            let response: ProjectsResponse = try await API.shared.get("/api/projects", query: ["scope": scope])
            projects = response.projects
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
        loaded = true
    }
}

// MARK: - Dedicated Project Card for the Projects Feed
struct ProjectCardView: View {
    let project: ProjectSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row: Title & Status Badge
            HStack(alignment: .top, spacing: 10) {
                Text(project.title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.leading)

                Spacer()

                if project.status == "completed" {
                    Text("Completed")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Theme.forestGreen)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Theme.forestGreenLight)
                        .clipShape(Capsule())
                } else if project.isMember {
                    Text("Member")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Theme.terracottaDark)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Theme.terracottaLight)
                        .clipShape(Capsule())
                }
            }

            // Leader & Members Row
            HStack(spacing: 14) {
                HStack(spacing: 5) {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(Theme.forestGreen)
                        .font(.system(size: 13))
                    Text(project.leaderName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                }

                HStack(spacing: 5) {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(Theme.textMuted)
                        .font(.system(size: 12))
                    Text("\(project.members) member\(project.members == 1 ? "" : "s")")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                }
            }

            // Milestones Progress Bar
            if project.milestonesTotal > 0 {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("Milestones")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Theme.textMuted)
                        Spacer()
                        Text("\(project.milestonesDone)/\(project.milestonesTotal) done")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Theme.forestGreen)
                    }

                    GeometryReader { pGeo in
                        let progress = CGFloat(project.milestonesDone) / CGFloat(max(project.milestonesTotal, 1))
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Theme.forestGreenLight)
                                .frame(height: 6)
                            Capsule()
                                .fill(Theme.forestGreen)
                                .frame(width: max(pGeo.size.width * progress, 0), height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }

            // Open Needs / Looking For
            if !project.openNeeds.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Looking for:")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.textMuted)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(project.openNeeds, id: \.self) { role in
                                Text(role)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(Theme.forestGreen)
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 4)
                                    .background(Theme.forestGreenPill)
                                    .clipShape(Capsule())
                            }
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
