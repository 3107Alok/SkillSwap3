import SwiftUI

/// Team building for a hackathon: search students by domain (and optionally skills).
struct FindPeopleView: View {
    @State private var selected: Set<String> = []
    @State private var matchAll = false
    @State private var skills = ""
    @State private var results: [MatchItem] = []
    @State private var searched = false
    @State private var error: String?
    @State private var busy = false
    @State private var hasAppeared = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Shared warm cream & peach background gradient with subtle organic ambient shapes
                BackgroundOrganicShapes()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Header Section with Title, Subtitle and Flying Paper Plane
                        headerSection
                            .padding(.top, 4)

                        // 14 Skill Domains Selectable Responsive Grid
                        domainGridSection

                        // Match Mode Selector ("Any of these" / "All of these")
                        MatchModeSegmentedControl(matchAll: $matchAll)
                            .padding(.top, 4)

                        // Optional Skills Search Input
                        SkillsSearchField(
                            placeholder: "Skills (optional), e.g. Swift, Figma",
                            text: $skills
                        )

                        // Search Action Button
                        SkillSwapPrimaryButton(
                            title: busy ? "Searching..." : "Search",
                            isLoading: busy,
                            isDisabled: busy || (selected.isEmpty && skills.trimmingCharacters(in: .whitespaces).isEmpty)
                        ) {
                            search()
                        }
                        .padding(.top, 2)

                        // Error Banner
                        if let err = error {
                            ErrorBanner(message: err)
                        }

                        // Search Results Section
                        resultsSection
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 32)
                    .frame(maxWidth: 600) // Optimal centered layout on mobile, tablet & desktop
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 14)
            .animation(.easeOut(duration: 0.38), value: hasAppeared)
            .onAppear {
                hasAppeared = true
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    EmptyView() // Keep navigation clean as reference has prominent in-page header
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        ZStack(alignment: .topTrailing) {
            // Paper plane flight trail illustration
            PaperPlaneHeaderDecoration()
                .offset(y: -4)

            // Header text
            VStack(alignment: .leading, spacing: 4) {
                Text("Find people")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(SkillSwapTheme.textDark)

                Text("Pick the domains you need")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(SkillSwapTheme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Domain Grid Section

    private var domainGridSection: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ],
            spacing: 10
        ) {
            ForEach(DomainRegistry.items) { meta in
                DomainGridCard(
                    meta: meta,
                    isSelected: selected.contains(meta.id)
                ) {
                    toggle(meta.id)
                }
            }
        }
    }

    // MARK: - Search Results Section

    @ViewBuilder
    private var resultsSection: some View {
        if searched && results.isEmpty && error == nil && !busy {
            VStack(spacing: 8) {
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .font(.system(size: 38))
                    .foregroundColor(SkillSwapTheme.textSecondary.opacity(0.6))
                    .padding(.top, 12)
                
                Text("Nobody matches that yet.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(SkillSwapTheme.textSecondary)
                
                Text("Try selecting fewer domains or switching to 'Any of these'.")
                    .font(.system(size: 12.5))
                    .foregroundColor(SkillSwapTheme.textSecondary.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }

        if !results.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Matching people (\(results.count))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(SkillSwapTheme.textDark)
                    .padding(.top, 8)

                ForEach(results) { item in
                    NavigationLink(destination: UserDetailView(uid: item.uid)) {
                        MatchCard(item: item)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.white.opacity(0.85))
                                    .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(SkillSwapTheme.cardBorder, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Selection & API Logic

    private func toggle(_ domain: String) {
        withAnimation(.easeInOut(duration: 0.18)) {
            if selected.contains(domain) {
                selected.remove(domain)
            } else {
                selected.insert(domain)
            }
        }
    }

    private func search() {
        var query: [String: String] = [
            "domains": Domains.all.filter { selected.contains($0) }.joined(separator: ","),
            "match": matchAll ? "all" : "any",
        ]
        let trimmed = skills.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            query["skills"] = trimmed
        }
        attempt($error, busy: $busy) {
            let response: MatchResponse = try await API.shared.get("/api/search/people", query: query)
            results = response.results
            searched = true
        }
    }
}
