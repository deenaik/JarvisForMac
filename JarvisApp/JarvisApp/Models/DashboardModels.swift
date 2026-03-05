import SwiftUI

enum NavigationTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case workflows = "Workflows"
    case activity = "Activity Log"
    case learning = "Learning"
    case settings = "Settings"
    case help = "Help"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .workflows: return "arrow.triangle.branch"
        case .activity: return "clock.arrow.circlepath"
        case .learning: return "brain"
        case .settings: return "gearshape"
        case .help: return "questionmark.circle"
        }
    }
}

struct StatCard: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    let icon: String
    let iconColor: Color
}

struct WorkflowItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let iconColor: Color
    let status: WorkflowStatus
    let runsToday: Int
    let successRate: String
    let lastRun: String
}

enum WorkflowStatus: String {
    case active = "Active"
    case paused = "Paused"
    case error = "Error"

    var color: Color {
        switch self {
        case .active: return JarvisTheme.statusActive
        case .paused: return JarvisTheme.statusWarning
        case .error: return JarvisTheme.statusError
        }
    }
}

struct ActivityItem: Identifiable {
    let id = UUID()
    let timestamp: String
    let title: String
    let description: String
    let icon: String
    let iconColor: Color
    let category: ActivityCategory
    let isCompleted: Bool
}

enum ActivityCategory: String, CaseIterable {
    case all = "All"
    case actions = "Actions"
    case learning = "Learning"
}

struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
}
