import SwiftUI

struct TimelineEntryView: View {
    let item: ActivityItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timestamp
            Text(item.timestamp)
                .font(.caption.monospaced())
                .foregroundStyle(JarvisTheme.textMuted)
                .frame(width: 64, alignment: .trailing)

            // Icon circle
            ZStack {
                Circle()
                    .fill(item.iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: item.icon)
                    .font(.caption)
                    .foregroundStyle(item.iconColor)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(JarvisTheme.textPrimary)
                Text(item.description)
                    .font(.caption)
                    .foregroundStyle(JarvisTheme.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            // Checkmark
            if item.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(JarvisTheme.statusActive)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }
}
