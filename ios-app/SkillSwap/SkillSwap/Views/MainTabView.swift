import SwiftUI

/// Main application navigation with a warm cream and forest green bottom bar,
/// matching the reference mockup layout, pill highlights, and typography.
struct MainTabView: View {
    @StateObject private var tabCoordinator = TabCoordinator()

    init() {
        // Hide standard system tab bar to render our custom warm-themed navigation dock
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $tabCoordinator.selectedTab) {
                HomeView()
                    .tag(AppTab.forYou)
                
                ProjectsView()
                    .tag(AppTab.projects)
                
                FindPeopleView()
                    .tag(AppTab.findPeople)
                
                ProfileView()
                    .tag(AppTab.profile)
            }
            .environmentObject(tabCoordinator)

            // Warm Cream Floating / Docked Bottom Bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    // MARK: - Custom Bottom Navigation Bar
    private var customTabBar: some View {
        VStack(spacing: 0) {
            // Subtle top border separator
            Rectangle()
                .fill(Theme.cardBorder)
                .frame(height: 1)
            
            HStack(spacing: 8) {
                ForEach(AppTab.allCases) { tab in
                    tabButton(for: tab)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 6)
            .background(
                Theme.creamBackground
                    .ignoresSafeArea(edges: .bottom)
            )
        }
        .background(Theme.creamBackground)
    }

    private func tabButton(for tab: AppTab) -> some View {
        let isSelected = tabCoordinator.selectedTab == tab
        
        return Button {
            if !isSelected {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                withAnimation(.easeInOut(duration: 0.18)) {
                    tabCoordinator.selectedTab = tab
                }
            }
        } label: {
            VStack(spacing: 4) {
                if isSelected {
                    // Selected Tab: Soft sage pill container with forest-green icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Theme.forestGreenPill)
                            .frame(width: 58, height: 32)
                        
                        Image(systemName: tab.activeIcon)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Theme.forestGreen)
                    }
                    
                    Text(tab.title)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Theme.forestGreen)
                } else {
                    // Unselected Tab: Clean understated icon & label
                    ZStack {
                        Color.clear
                            .frame(width: 58, height: 32)
                        
                        Image(systemName: tab.inactiveIcon)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(Theme.textSecondary)
                    }
                    
                    Text(tab.title)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
