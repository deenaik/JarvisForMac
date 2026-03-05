import SwiftUI

struct StatCardView: View {
    let stat: StatCard

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: stat.icon)
                    .font(.title3)
                    .foregroundStyle(stat.iconColor)
                Spacer()
                Text(stat.change)
                    .font(.caption.bold())
                    .foregroundStyle(stat.isPositive ? JarvisTheme.statusActive : JarvisTheme.statusError)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        (stat.isPositive ? JarvisTheme.statusActive : JarvisTheme.statusError)
                            .opacity(0.15)
                    )
                    .clipShape(Capsule())
            }

            Text(stat.value)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundStyle(JarvisTheme.textPrimary)

            Text(stat.title)
                .font(.caption)
                .foregroundStyle(JarvisTheme.textMuted)
        }
        .padding(JarvisTheme.cardPadding)
        .background(JarvisTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.cardRadius))
    }
}
