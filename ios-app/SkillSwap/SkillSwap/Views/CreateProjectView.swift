import SwiftUI

struct RoleDraft: Identifiable {
    let id = UUID()
    var role = ""
    var domain = ""
    var skills = ""
}

/// "New project" creation screen matching the warm cream, forest-green, and terracotta theme.
/// Seamlessly blends the gender-based character illustration into the background and presents
/// modern card-based inputs for project details and role requirements.
struct CreateProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var app: AppModel

    @State private var title = ""
    @State private var details = ""
    @State private var roles: [RoleDraft] = [RoleDraft()]
    @State private var error: String?
    @State private var busy = false

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

    private var canCreate: Bool {
        title.trimmingCharacters(in: .whitespaces).count >= 3 && !busy
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let screenWidth = geo.size.width
                let screenHeight = geo.size.height

                ZStack(alignment: .top) {
                    // 1. Full-Bleed Warm Cream Base Canvas
                    Theme.creamBackground
                        .ignoresSafeArea()

                    // 2. Seamless Storybook Background Illustration (Full-Height Edge-to-Edge)
                    // Placed in the background with multiply blend mode so it melts naturally into the canvas
                    ZStack(alignment: .topTrailing) {
                        Image(heroImageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth * 1.15, height: max(screenHeight, 750))
                            .offset(x: screenWidth * 0.12, y: -20)
                            .blendMode(.multiply)
                            .opacity(0.95)
                    }
                    .frame(width: screenWidth, height: screenHeight, alignment: .topTrailing)
                    .clipped()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                    // 3. Foreground Scrollable Content
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            // Top Navigation Bar
                            topNavigationBar
                                .padding(.top, 14)
                                .padding(.bottom, 12)

                            // Header: "New project" Title & Subtitle
                            headerSection
                                .padding(.bottom, 16)

                            // Error Banner (if any)
                            if let error = error {
                                errorCard(error)
                                    .padding(.bottom, 14)
                            }

                            // Card 1: Project Details
                            projectCard
                                .padding(.bottom, 14)

                            // Card 2: Roles you still need
                            rolesCard
                                .padding(.bottom, 36)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            // Cancel Pill Button
            Button {
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                    Text("Cancel")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Theme.folderBg)
                )
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            // Create Pill Button
            Button {
                create()
            } label: {
                HStack(spacing: 6) {
                    if busy {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    Text(busy ? "Saving..." : "Create")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 22)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Theme.forestGreen)
                )
                .shadow(color: Theme.forestGreen.opacity(canCreate ? 0.25 : 0.0), radius: 4, x: 0, y: 2)
                .opacity(canCreate ? 1.0 : 0.45)
            }
            .disabled(!canCreate)
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("New project")
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundColor(Theme.forestGreen)

            Text("Turn your ideas into reality\nwith the right people.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Theme.textSecondary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }

    // MARK: - Card 1: Project Information
    private var projectCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row: Icon Badge & Titles
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.forestGreenPill)
                        .frame(width: 40, height: 40)
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Theme.forestGreen)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Project")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Theme.textPrimary)

                    Text("Give a clear title and description.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Theme.textSecondary)
                }
                Spacer()
            }

            // Title Field
            HStack(spacing: 12) {
                Image(systemName: "doc.plaintext")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.textMuted)
                    .frame(width: 20)

                TextField("Title", text: $title)
                    .font(.system(size: 15))
                    .foregroundColor(Theme.textPrimary)
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Theme.creamCardSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Theme.cardBorder, lineWidth: 1)
                    )
            )

            // Description / Details Field with Character Counter
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.textMuted)
                        .frame(width: 20)
                        .padding(.top, 2)

                    TextField(
                        "What are you building? (the AI plans from this)",
                        text: Binding(
                            get: { details },
                            set: { details = $0.count > 500 ? String($0.prefix(500)) : $0 }
                        ),
                        axis: .vertical
                    )
                    .lineLimit(4...8)
                    .font(.system(size: 15))
                    .foregroundColor(Theme.textPrimary)
                }

                Text("\(details.count)/500")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Theme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Theme.creamCardSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Theme.cardBorder, lineWidth: 1)
                    )
            )
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Theme.creamCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Theme.cardBorder, lineWidth: 1)
                )
                .shadow(color: Theme.shadow, radius: 8, x: 0, y: 3)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Card 2: Roles You Still Need
    private var rolesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row: Icon Badge & Titles
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.terracottaLight)
                        .frame(width: 40, height: 40)
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Theme.terracottaDark)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Roles you still need")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Theme.textPrimary)

                    Text("Add the roles and skills you’re looking for.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Theme.textSecondary)
                }
                Spacer()
            }

            // Role Rows
            ForEach(roles.indices, id: \.self) { index in
                VStack(alignment: .leading, spacing: 10) {
                    if roles.count > 1 {
                        HStack {
                            Text("Role #\(index + 1)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Theme.forestGreen)
                            Spacer()
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    roles.remove(at: index)
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "trash")
                                    Text("Remove")
                                }
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Theme.terracotta)
                            }
                        }
                        .padding(.top, index > 0 ? 6 : 0)
                    }

                    // Domain Selector Row
                    HStack(spacing: 12) {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 15))
                            .foregroundColor(Theme.textMuted)
                            .frame(width: 20)

                        Text("Domain")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Theme.textPrimary)

                        Spacer()

                        Menu {
                            Button("Any") {
                                roles[index].domain = ""
                            }
                            ForEach(Domains.all, id: \.self) { domain in
                                Button(domain) {
                                    roles[index].domain = domain
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(roles[index].domain.isEmpty ? "Any" : roles[index].domain)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Theme.textSecondary)
                                    .lineLimit(1)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(Theme.textSecondary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.03))
                            )
                        }
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Theme.creamCardSecondary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Theme.cardBorder, lineWidth: 1)
                            )
                    )

                    // Skills Input Row
                    HStack(spacing: 12) {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.textMuted)
                            .frame(width: 20)

                        TextField("Skills, e.g. Swift, SwiftUI", text: $roles[index].skills)
                            .font(.system(size: 15))
                            .foregroundColor(Theme.textPrimary)
                            .textInputAutocapitalization(.never)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Theme.creamCardSecondary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Theme.cardBorder, lineWidth: 1)
                            )
                    )
                }
            }

            // "Add another role" Button
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    roles.append(RoleDraft())
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 15, weight: .medium))
                    Text("Add another role")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(Theme.forestGreen)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Theme.forestGreenPill.opacity(0.45))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Theme.forestGreen.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4]))
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 2)

            // Tip / Footnote
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lightbulb")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textMuted)
                    .padding(.top, 1)

                Text("Pick the domain and list skills, comma separated. We suggest the best-fitting students for each role.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Theme.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 4)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Theme.creamCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Theme.cardBorder, lineWidth: 1)
                )
                .shadow(color: Theme.shadow, radius: 8, x: 0, y: 3)
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
    private func create() {
        attempt($error, busy: $busy) {
            let needs: [[String: Any]] = roles
                .filter {
                    !$0.role.trimmingCharacters(in: .whitespaces).isEmpty ||
                    !$0.domain.trimmingCharacters(in: .whitespaces).isEmpty ||
                    !$0.skills.trimmingCharacters(in: .whitespaces).isEmpty
                }
                .map { (draft: RoleDraft) -> [String: Any] in
                    let skills = draft.skills.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    let effectiveRole: String = {
                        if !draft.role.trimmingCharacters(in: .whitespaces).isEmpty {
                            return draft.role.trimmingCharacters(in: .whitespaces)
                        }
                        if !draft.domain.isEmpty {
                            return "\(draft.domain) Contributor"
                        }
                        if let first = skills.first, !first.isEmpty {
                            return "\(first) Specialist"
                        }
                        return "Collaborator"
                    }()
                    return ["role": effectiveRole, "domain": draft.domain, "skills": skills]
                }
            let _: ProjectDetail = try await API.shared.post(
                "/api/projects", body: ["title": title, "description": details, "needs": needs])
            dismiss()
        }
    }
}
