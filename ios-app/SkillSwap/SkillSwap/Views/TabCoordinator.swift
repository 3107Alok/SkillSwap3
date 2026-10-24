import SwiftUI
import Combine

enum AppTab: Int, CaseIterable, Identifiable {
    case forYou = 0
    case projects = 1
    case findPeople = 2
    case profile = 3
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .forYou: return "For you"
        case .projects: return "Projects"
        case .findPeople: return "Find people"
        case .profile: return "Profile"
        }
    }
    
    var activeIcon: String {
        switch self {
        case .forYou: return "house.fill"
        case .projects: return "folder.fill"
        case .findPeople: return "person.2.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
    
    var inactiveIcon: String {
        switch self {
        case .forYou: return "house"
        case .projects: return "folder"
        case .findPeople: return "person.2"
        case .profile: return "person.crop.circle"
        }
    }
}

final class TabCoordinator: ObservableObject {
    @Published var selectedTab: AppTab = .forYou
}
