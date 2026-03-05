import SwiftUI

struct WorkflowCardView: View {
    let workflow: WorkflowItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: icon + status
            HStack {
                Image(systemName: workflow.icon)
                    .font(.title2)
                    .foregroundStyle(workflow.iconColor)
                Spacer()
                Text(workflow.status.rawValue)
                    .font(.caption.bold())
                    .foregroundStyle(workflow.status.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(workflow.status.color.opacity(0.15))
                    .clipShape(Capsule())
            }

            // Name
            Text(workflow.name)
                .font(.headline)
                .foregroundStyle(JarvisTheme.textPrimary)

            // Description
            Text(workflow.description)
                .font(.caption)
                .foregroundStyle(JarvisTheme.textSecondary)
                .lineLimit(2)

            Spacer(minLength: 0)

            // Stats row
            HStack(spacing: 16) {
                Label {
                    Text("\(workflow.runsToday) today")
                        .font(.caption2)
                        .foregroundStyle(JarvisTheme.textMuted)
                } icon: {
                    Image(systemName: "play.fill")
                        .font(.caption2)
                        .foregroundStyle(JarvisTheme.textMuted)
                }

                Label {
                    Text(workflow.successRate)
                        .font(.caption2)
                        .foregroundStyle(JarvisTheme.textMuted)
                } icon: {
                    Image(systemName: "checkmark.circle")
                        .font(.caption2)
                        .foregroundStyle(JarvisTheme.textMuted)
                }

                Spacer()

                Text(workflow.lastRun)
                    .font(.caption2)
                    .foregroundStyle(JarvisTheme.textMuted)
            }
        }
        .padding(JarvisTheme.cardPadding)
        .frame(minHeight: 180)
        .background(JarvisTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.cardRadius))
    }
}
