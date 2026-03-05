import SwiftUI

struct DashboardContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: JarvisTheme.sectionSpacing) {
                // Greeting
                VStack(alignment: .leading, spacing: 4) {
                    Text("Good afternoon, Deepak")
                        .font(.title.bold())
                        .foregroundStyle(JarvisTheme.textPrimary)
                    Text("Here's what's happening with your workflows")
                        .font(.subheadline)
                        .foregroundStyle(JarvisTheme.textSecondary)
                }

                // Search bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(JarvisTheme.textMuted)
                    Text("Search tasks, workflows, or ask Jarvis...")
                        .foregroundStyle(JarvisTheme.textMuted)
                    Spacer()
                    Text("⌘K")
                        .font(.caption.monospaced())
                        .foregroundStyle(JarvisTheme.textMuted)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(JarvisTheme.sidebar)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .padding(12)
                .background(JarvisTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.buttonRadius))

                // Stat cards grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
                    ForEach(MockData.stats) { stat in
                        StatCardView(stat: stat)
                    }
                }

                // Bottom section: Recent Activity + Quick Actions
                HStack(alignment: .top, spacing: 16) {
                    // Recent activity
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Activity")
                            .font(.headline)
                            .foregroundStyle(JarvisTheme.textPrimary)

                        VStack(spacing: 0) {
                            ForEach(MockData.activities.prefix(4)) { item in
                                HStack(spacing: 12) {
                                    Image(systemName: item.icon)
                                        .font(.body)
                                        .foregroundStyle(item.iconColor)
                                        .frame(width: 24)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.title)
                                            .font(.subheadline)
                                            .foregroundStyle(JarvisTheme.textPrimary)
                                        Text(item.description)
                                            .font(.caption)
                                            .foregroundStyle(JarvisTheme.textMuted)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    Text(item.timestamp)
                                        .font(.caption.monospaced())
                                        .foregroundStyle(JarvisTheme.textMuted)
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                if item.id != MockData.activities.prefix(4).last?.id {
                                    Divider()
                                        .background(JarvisTheme.label.opacity(0.3))
                                }
                            }
                        }
                        .background(JarvisTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.cardRadius))
                    }
                    .frame(maxWidth: .infinity)

                    // Quick actions
                    QuickActionsView(actions: MockData.quickActions)
                        .frame(width: 260)
                }
            }
            .padding(JarvisTheme.sectionSpacing)
        }
    }
}
