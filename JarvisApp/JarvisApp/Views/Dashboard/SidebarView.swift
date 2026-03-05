import SwiftUI

struct SidebarView: View {
    @Binding var selectedTab: NavigationTab

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Logo area
            HStack(spacing: 10) {
                Image(systemName: "sparkle")
                    .font(.title2)
                    .foregroundStyle(JarvisTheme.accent)
                Text("Jarvis")
                    .font(.title2.bold())
                    .foregroundStyle(JarvisTheme.textPrimary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 32)

            // Navigation items
            VStack(spacing: 4) {
                ForEach(NavigationTab.allCases) { tab in
                    SidebarNavItem(tab: tab, isSelected: selectedTab == tab) {
                        selectedTab = tab
                    }
                }
            }
            .padding(.horizontal, 12)

            Spacer()

            // Status box
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle()
                        .fill(JarvisTheme.statusActive)
                        .frame(width: 8, height: 8)
                    Text("System Online")
                        .font(.caption)
                        .foregroundStyle(JarvisTheme.textSecondary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Memory Usage")
                        .font(.caption2)
                        .foregroundStyle(JarvisTheme.textMuted)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(JarvisTheme.card)
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(JarvisTheme.accent)
                                .frame(width: geo.size.width * 0.42, height: 6)
                        }
                    }
                    .frame(height: 6)
                    Text("42% of 2GB")
                        .font(.caption2)
                        .foregroundStyle(JarvisTheme.textMuted)
                }
            }
            .padding(16)
            .background(JarvisTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.cardRadius))
            .padding(.horizontal, 12)
            .padding(.bottom, 16)
        }
        .frame(width: JarvisTheme.sidebarWidth)
        .background(JarvisTheme.sidebar)
    }
}

private struct SidebarNavItem: View {
    let tab: NavigationTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: tab.icon)
                    .font(.body)
                    .frame(width: 20)
                Text(tab.rawValue)
                    .font(.body)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundStyle(isSelected ? JarvisTheme.accent : JarvisTheme.textSecondary)
            .background(isSelected ? JarvisTheme.accent.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.buttonRadius))
        }
        .buttonStyle(.plain)
    }
}
