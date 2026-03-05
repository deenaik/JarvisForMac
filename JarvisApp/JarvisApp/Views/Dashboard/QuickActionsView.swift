import SwiftUI

struct QuickActionsView: View {
    let actions: [QuickAction]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundStyle(JarvisTheme.textPrimary)

            VStack(spacing: 8) {
                ForEach(actions) { action in
                    Button(action: {}) {
                        HStack(spacing: 12) {
                            Image(systemName: action.icon)
                                .font(.body)
                                .foregroundStyle(action.color)
                                .frame(width: 24)
                            Text(action.title)
                                .font(.subheadline)
                                .foregroundStyle(JarvisTheme.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(JarvisTheme.textMuted)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(JarvisTheme.sidebar.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.buttonRadius))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(JarvisTheme.cardPadding)
        .background(JarvisTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.cardRadius))
    }
}
