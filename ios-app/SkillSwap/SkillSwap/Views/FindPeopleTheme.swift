import SwiftUI

// MARK: - Domain Meta with Icons and Accent Colors

struct DomainMeta: Identifiable {
    let id: String
    let name: String
    let iconName: String
    let iconColor: Color
    let iconBgColor: Color
}

enum DomainRegistry {
    static let items: [DomainMeta] = [
        DomainMeta(
            id: "Backend",
            name: "Backend",
            iconName: "server.rack",
            iconColor: Color(red: 22/255, green: 101/255, blue: 52/255),
            iconBgColor: Color(red: 220/255, green: 252/255, blue: 231/255)
        ),
        DomainMeta(
            id: "Frontend",
            name: "Frontend",
            iconName: "chevron.left.forwardslash.chevron.right",
            iconColor: Color(red: 67/255, green: 56/255, blue: 202/255),
            iconBgColor: Color(red: 238/255, green: 242/255, blue: 255/255)
        ),
        DomainMeta(
            id: "Mobile (iOS)",
            name: "Mobile (iOS)",
            iconName: "applelogo",
            iconColor: Color(red: 17/255, green: 24/255, blue: 39/255),
            iconBgColor: Color(red: 243/255, green: 244/255, blue: 246/255)
        ),
        DomainMeta(
            id: "Mobile (Android)",
            name: "Mobile (Android)",
            iconName: "antenna.radiowaves.left.and.right",
            iconColor: Color(red: 21/255, green: 128/255, blue: 61/255),
            iconBgColor: Color(red: 220/255, green: 252/255, blue: 231/255)
        ),
        DomainMeta(
            id: "Cross-platform Mobile",
            name: "Cross-platform Mobile",
            iconName: "iphone.gen3",
            iconColor: Color(red: 219/255, green: 39/255, blue: 119/255),
            iconBgColor: Color(red: 252/255, green: 231/255, blue: 243/255)
        ),
        DomainMeta(
            id: "UI/UX Design",
            name: "UI/UX Design",
            iconName: "paintpalette.fill",
            iconColor: Color(red: 234/255, green: 88/255, blue: 12/255),
            iconBgColor: Color(red: 254/255, green: 243/255, blue: 199/255)
        ),
        DomainMeta(
            id: "Machine Learning",
            name: "Machine Learning",
            iconName: "brain.head.profile",
            iconColor: Color(red: 37/255, green: 99/255, blue: 235/255),
            iconBgColor: Color(red: 239/255, green: 246/255, blue: 255/255)
        ),
        DomainMeta(
            id: "Data Science & Analytics",
            name: "Data Science & Analytics",
            iconName: "chart.bar.xaxis",
            iconColor: Color(red: 217/255, green: 119/255, blue: 6/255),
            iconBgColor: Color(red: 254/255, green: 243/255, blue: 199/255)
        ),
        DomainMeta(
            id: "DevOps & Cloud",
            name: "DevOps & Cloud",
            iconName: "cloud.fill",
            iconColor: Color(red: 2/255, green: 132/255, blue: 199/255),
            iconBgColor: Color(red: 224/255, green: 242/255, blue: 254/255)
        ),
        DomainMeta(
            id: "Cybersecurity",
            name: "Cybersecurity",
            iconName: "shield.lefthalf.filled",
            iconColor: Color(red: 14/255, green: 116/255, blue: 144/255),
            iconBgColor: Color(red: 207/255, green: 250/255, blue: 254/255)
        ),
        DomainMeta(
            id: "Embedded & IoT",
            name: "Embedded & IoT",
            iconName: "cpu",
            iconColor: Color(red: 194/255, green: 65/255, blue: 12/255),
            iconBgColor: Color(red: 255/255, green: 237/255, blue: 213/255)
        ),
        DomainMeta(
            id: "Game Development",
            name: "Game Development",
            iconName: "gamecontroller.fill",
            iconColor: Color(red: 124/255, green: 58/255, blue: 237/255),
            iconBgColor: Color(red: 243/255, green: 232/255, blue: 255/255)
        ),
        DomainMeta(
            id: "Product & Management",
            name: "Product & Management",
            iconName: "briefcase.fill",
            iconColor: Color(red: 220/255, green: 38/255, blue: 38/255),
            iconBgColor: Color(red: 254/255, green: 226/255, blue: 226/255)
        ),
        DomainMeta(
            id: "Content & Marketing",
            name: "Content & Marketing",
            iconName: "megaphone.fill",
            iconColor: Color(red: 225/255, green: 29/255, blue: 72/255),
            iconBgColor: Color(red: 255/255, green: 228/255, blue: 230/255)
        ),
    ]
}

// MARK: - Selectable Domain Card

struct DomainGridCard: View {
    let meta: DomainMeta
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 10) {
                // Leading Icon in rounded container
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isSelected ? Color.white.opacity(0.2) : meta.iconBgColor)
                        .frame(width: 30, height: 30)
                    
                    Image(systemName: meta.iconName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isSelected ? .white : meta.iconColor)
                }
                
                // Domain Name
                Text(meta.name)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .white : SkillSwapTheme.textDark)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? SkillSwapTheme.forestGreen : Color(red: 247/255, green: 243/255, blue: 236/255).opacity(0.95))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        isSelected ? SkillSwapTheme.forestGreen : SkillSwapTheme.cardBorder,
                        lineWidth: isSelected ? 1.5 : 0.8
                    )
            )
            .shadow(
                color: isSelected ? SkillSwapTheme.forestGreen.opacity(0.2) : Color.black.opacity(0.015),
                radius: 3,
                x: 0,
                y: 1.5
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(meta.name)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - Matching Mode Pill Selector

struct MatchModeSegmentedControl: View {
    @Binding var matchAll: Bool
    @Namespace private var modeNamespace

    var body: some View {
        HStack(spacing: 0) {
            // "Any of these" button
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    matchAll = false
                }
            } label: {
                Text("Any of these")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(!matchAll ? .white : SkillSwapTheme.textDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background {
                if !matchAll {
                    Capsule()
                        .fill(SkillSwapTheme.forestGreen)
                        .matchedGeometryEffect(id: "ACTIVE_MATCH_MODE", in: modeNamespace)
                        .shadow(color: SkillSwapTheme.forestGreen.opacity(0.25), radius: 6, x: 0, y: 3)
                }
            }
            
            // "All of these" button
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    matchAll = true
                }
            } label: {
                Text("All of these")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(matchAll ? .white : SkillSwapTheme.textDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background {
                if matchAll {
                    Capsule()
                        .fill(SkillSwapTheme.forestGreen)
                        .matchedGeometryEffect(id: "ACTIVE_MATCH_MODE", in: modeNamespace)
                        .shadow(color: SkillSwapTheme.forestGreen.opacity(0.25), radius: 6, x: 0, y: 3)
                }
            }
        }
        .padding(4)
        .background(SkillSwapTheme.segmentedTrack)
        .clipShape(Capsule())
    }
}

// MARK: - Pill-Shaped Optional Skills Search Input

struct SkillsSearchField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isFocused ? SkillSwapTheme.forestGreen : SkillSwapTheme.textSecondary)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .focused($isFocused)
                .font(.system(size: 14.5))
                .foregroundColor(SkillSwapTheme.textDark)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(SkillSwapTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(Color.white.opacity(0.85))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(isFocused ? SkillSwapTheme.forestGreen : SkillSwapTheme.inputBorder, lineWidth: isFocused ? 1.5 : 1)
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Animated Paper Plane Header Graphic

// Implemented in PaperPlaneVector.swift using native Swift graphics & gradient paths
