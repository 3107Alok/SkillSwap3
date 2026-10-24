import SwiftUI

/// "Projects" screen: displays projects with a warm cream, forest-green, and terracotta theme.
/// Distinctly separates "My projects" (joined/created) from "Open projects" (discoverable with join action).
struct ProjectsView: View {
    @State private var scope = "mine"
    @State private var projects: [ProjectSummary] = []
    @State private var error: String?
    @State private var notice: String?
    @State private var creating = false
    @State private var loaded = false
    @State private var joiningProject: ProjectSummary?

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

                            // Notice Banner (e.g. after successfully applying)
                            if let notice = notice {
                                noticeCard(notice)
                                    .padding(.bottom, 14)
                            }

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
            .sheet(item: $joiningProject) { project in
                JoinProjectSheet(project: project) {
                    notice = "Application submitted for \"\(project.title)\"! The leader has been notified."
                    await load()
                }
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

                Text(scope == "mine" ? "Manage and track the projects\nyou've joined or created." : "Discover open opportunities and\ncollaborate with the right people.")
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

                // Forest Green Circular Plus Button (Always active in both tabs)
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
            // My Projects Button
            Button {
                if scope != "mine" {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        scope = "mine"
                        notice = nil
                    }
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

            // Open Projects Button
            Button {
                if scope != "open" {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        scope = "open"
                        notice = nil
                    }
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

    // MARK: - Distinct Empty State Section
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

            if scope == "mine" {
                // My Projects Empty State: Guides user to discover open projects or start their own
                VStack(spacing: 6) {
                    Text("You are not in a project yet")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(Theme.textPrimary)

                    Text("Discover open projects looking for your skills,\nor start your own project.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                VStack(spacing: 12) {
                    // Primary Action: Explore Open Projects
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            scope = "open"
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text("Discover Open Projects")
                                .font(.system(size: 15, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .frame(height: 48)
                        .background(
                            Capsule()
                                .fill(Theme.forestGreen)
                        )
                        .shadow(color: Theme.forestGreen.opacity(0.22), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(ScalePressStyle())

                    // Secondary Action: Create Project
                    Button {
                        creating = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Create a Project")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(Theme.forestGreen)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 4)

            } else {
                // Open Projects Empty State: Informs user that no projects are currently open
                VStack(spacing: 6) {
                    Text("No open projects right now")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(Theme.textPrimary)

                    Text("All current projects have filled their roles.\nCheck back soon or create your own.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                VStack(spacing: 12) {
                    // Primary Action: Refresh
                    Button {
                        Task { await load() }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Refresh List")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .frame(height: 48)
                        .background(
                            Capsule()
                                .fill(Theme.forestGreen)
                        )
                        .shadow(color: Theme.forestGreen.opacity(0.22), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(ScalePressStyle())

                    // Secondary Action: Create Project
                    Button {
                        creating = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Start a New Project")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(Theme.forestGreen)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 4)
            }

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
                ProjectCardView(project: project, scope: scope) {
                    joiningProject = project
                }
            }
        }
    }

    // MARK: - Notice Banner Card
    private func noticeCard(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Theme.forestGreen)
            Text(message)
                .font(.footnote.weight(.medium))
                .foregroundColor(Theme.forestGreenDark)
            Spacer()
            Button {
                withAnimation { notice = nil }
            } label: {
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.forestGreenPill)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Theme.forestGreenBorder, lineWidth: 1)
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
    let scope: String
    let onJoin: () -> Void

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
                    Text(scope == "mine" ? "Member" : "Joined ✓")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Theme.terracottaDark)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Theme.terracottaLight)
                        .clipShape(Capsule())
                } else if scope == "open" {
                    Text("Open to Join")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Theme.forestGreen)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Theme.forestGreenPill)
                        .clipShape(Capsule())
                }
            }

            // Description Snippet (especially helpful in Open Projects to discover what it is)
            if !project.description.isEmpty {
                Text(project.description)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(2)
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

            // Milestones Progress Bar (Shown in My Projects, or if Milestones exist)
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

            // Open Needs / Looking For Roles
            if !project.openNeeds.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text(scope == "open" ? "Roles available:" : "Looking for:")
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

            // Footer Actions: Differentiated between My Projects and Open Projects
            HStack {
                if scope == "open" && !project.isMember {
                    // Direct "Join Project" Action in Open Projects
                    Button {
                        onJoin()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 11))
                            Text("Join Project")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Theme.forestGreen)
                        )
                        .shadow(color: Theme.forestGreen.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(ScalePressStyle())

                    Spacer()

                    // Navigation to full detail
                    NavigationLink(destination: ProjectDetailView(projectId: project.id)) {
                        HStack(spacing: 4) {
                            Text("Details")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Theme.forestGreen)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Theme.forestGreen)
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(PlainButtonStyle())

                } else {
                    // Standard navigation for My Projects
                    NavigationLink(destination: ProjectDetailView(projectId: project.id)) {
                        HStack {
                            Text(scope == "mine" ? "Manage Project" : "View Project Details")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Theme.forestGreen)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Theme.forestGreen)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
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

// MARK: - Join / Apply Project Sheet
struct JoinProjectSheet: View {
    let project: ProjectSummary
    let onApplied: () async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var message = ""
    @State private var selectedNeedIndex: Int? = nil
    @State private var busy = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.creamBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        // Project Overview Card
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(project.title)
                                    .font(.system(size: 20, weight: .bold, design: .serif))
                                    .foregroundColor(Theme.textPrimary)
                                Spacer()
                                Text("Open")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(Theme.forestGreen)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Theme.forestGreenPill)
                                    .clipShape(Capsule())
                            }

                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Image(systemName: "person.circle.fill")
                                        .foregroundColor(Theme.forestGreen)
                                        .font(.system(size: 12))
                                    Text("Led by \(project.leaderName)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Theme.textSecondary)
                                }

                                HStack(spacing: 4) {
                                    Image(systemName: "person.2.fill")
                                        .foregroundColor(Theme.textMuted)
                                        .font(.system(size: 12))
                                    Text("\(project.members) member\(project.members == 1 ? "" : "s")")
                                        .font(.system(size: 12))
                                        .foregroundColor(Theme.textSecondary)
                                }
                            }

                            if !project.description.isEmpty {
                                Text(project.description)
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.textSecondary)
                                    .lineSpacing(2)
                                    .padding(.top, 2)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Theme.creamCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Theme.cardBorder, lineWidth: 1)
                                )
                        )

                        // Role Selection (if project has specific open needs)
                        if !project.openNeeds.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Select Role to Apply For")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Theme.forestGreen)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        // General Contributor Option
                                        Button {
                                            selectedNeedIndex = nil
                                        } label: {
                                            Text("General Contributor")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(selectedNeedIndex == nil ? .white : Theme.textPrimary)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 8)
                                                .background(
                                                    Capsule()
                                                        .fill(selectedNeedIndex == nil ? Theme.forestGreen : Theme.creamCard)
                                                )
                                                .overlay(
                                                    Capsule()
                                                        .stroke(selectedNeedIndex == nil ? Color.clear : Theme.cardBorder, lineWidth: 1)
                                                )
                                        }

                                        // Specific Roles from the project
                                        ForEach(Array(project.openNeeds.enumerated()), id: \.offset) { index, role in
                                            Button {
                                                selectedNeedIndex = index
                                            } label: {
                                                Text(role)
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundColor(selectedNeedIndex == index ? .white : Theme.textPrimary)
                                                    .padding(.horizontal, 14)
                                                    .padding(.vertical, 8)
                                                    .background(
                                                        Capsule()
                                                            .fill(selectedNeedIndex == index ? Theme.forestGreen : Theme.creamCard)
                                                    )
                                                    .overlay(
                                                        Capsule()
                                                            .stroke(selectedNeedIndex == index ? Color.clear : Theme.cardBorder, lineWidth: 1)
                                                    )
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Message Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Note to Project Leader (Optional)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Theme.forestGreen)

                            TextField("Why do you want to join? (e.g. skills you can offer)", text: $message, axis: .vertical)
                                .lineLimit(3...5)
                                .font(.system(size: 14))
                                .foregroundColor(Theme.textPrimary)
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Theme.creamCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Theme.cardBorder, lineWidth: 1)
                                        )
                                )
                        }

                        // Error Banner if any
                        if let error = error {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(Theme.terracotta)
                                Text(error)
                                    .font(.footnote)
                                    .foregroundColor(Theme.textPrimary)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Theme.terracottaLight)
                            )
                        }

                        // Submit Application Button
                        Button {
                            submit()
                        } label: {
                            HStack(spacing: 8) {
                                if busy {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text(busy ? "Sending Application..." : "Submit Join Request")
                                    .font(.system(size: 15, weight: .semibold))
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                Capsule()
                                    .fill(Theme.forestGreen)
                            )
                            .shadow(color: Theme.forestGreen.opacity(0.25), radius: 6, x: 0, y: 3)
                            .opacity(busy ? 0.6 : 1.0)
                        }
                        .disabled(busy)
                        .padding(.top, 4)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Join Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.forestGreen)
                }
            }
        }
    }

    private func submit() {
        busy = true
        error = nil
        Task {
            do {
                var body: [String: Any] = ["message": message]
                if let index = selectedNeedIndex {
                    body["need_index"] = index
                }
                let _: OkResponse = try await API.shared.post("/api/projects/\(project.id)/apply", body: body)
                await onApplied()
                dismiss()
            } catch {
                self.error = error.localizedDescription
                self.busy = false
            }
        }
    }
}
