import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 2 // Default to Find People for testing/reference verification

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("For you", systemImage: "house") }
                .tag(0)

            ProjectsView()
                .tabItem { Label("Projects", systemImage: "folder") }
                .tag(1)

            FindPeopleView()
                .tabItem { Label("Find people", systemImage: "person.2.fill") }
                .tag(2)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                .tag(3)
        }
        .tint(SkillSwapTheme.forestGreen)
    }
}
