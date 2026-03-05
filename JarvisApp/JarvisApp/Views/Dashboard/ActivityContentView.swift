import SwiftUI

struct ActivityContentView: View {
    @State private var selectedCategory: ActivityCategory = .all

    private var filteredActivities: [ActivityItem] {
        if selectedCategory == .all {
            return MockData.activities
        }
        return MockData.activities.filter { $0.category == selectedCategory }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: JarvisTheme.sectionSpacing) {
                // Title bar
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Activity Log")
                            .font(.title.bold())
                            .foregroundStyle(JarvisTheme.textPrimary)
                        Text("Track all actions, learnings, and system events")
                            .font(.subheadline)
                            .foregroundStyle(JarvisTheme.textSecondary)
                    }
                    Spacer()
                }

                // Filter tabs
                HStack(spacing: 4) {
                    ForEach(ActivityCategory.allCases, id: \.rawValue) { category in
                        Button(action: { selectedCategory = category }) {
                            Text(category.rawValue)
                                .font(.subheadline)
                                .foregroundStyle(selectedCategory == category ? JarvisTheme.accent : JarvisTheme.textSecondary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(selectedCategory == category ? JarvisTheme.accent.opacity(0.1) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.buttonRadius))
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }

                // Timeline
                VStack(spacing: 0) {
                    ForEach(filteredActivities) { item in
                        TimelineEntryView(item: item)
                        if item.id != filteredActivities.last?.id {
                            Divider()
                                .background(JarvisTheme.label.opacity(0.3))
                                .padding(.leading, 76)
                        }
                    }
                }
                .background(JarvisTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.cardRadius))
            }
            .padding(JarvisTheme.sectionSpacing)
        }
    }
}
