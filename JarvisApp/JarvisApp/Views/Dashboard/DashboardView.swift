import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(selectedTab: $appState.selectedTab)

            // Content area
            ZStack {
                JarvisTheme.background
                    .ignoresSafeArea()

                switch appState.selectedTab {
                case .dashboard:
                    DashboardContentView()
                case .workflows:
                    WorkflowsContentView()
                case .activity:
                    ActivityContentView()
                case .learning:
                    LearningContentView()
                case .settings:
                    SettingsContentView()
                case .help:
                    HelpContentView()
                }
            }
        }
        .background(JarvisTheme.background)
    }
}