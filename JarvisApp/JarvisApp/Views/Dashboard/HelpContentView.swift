import SwiftUI

struct HelpContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: JarvisTheme.sectionSpacing) {
                // Title
                VStack(alignment: .leading, spacing: 4) {
                    Text("Help & Support")
                        .font(.title.bold())
                        .foregroundStyle(JarvisTheme.textPrimary)
                    Text("Get help with Jarvis features and troubleshooting.")
                        .font(.subheadline)
                        .foregroundStyle(JarvisTheme.textMuted)
                }

                // Quick links + keyboard shortcuts
                HStack(alignment: .top, spacing: 16) {
                    // Quick links
                    VStack(alignment: .leading, spacing: 16) {
                        Text("QUICK LINKS")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(JarvisTheme.textMuted)
                            .kerning(2)

                        VStack(spacing: 4) {
                            ForEach(helpLinks, id: \.title) { link in
                                HelpLinkRow(link: link)
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(JarvisTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.cardRadius))

                    // Keyboard shortcuts
                    VStack(alignment: .leading, spacing: 16) {
                        Text("KEYBOARD SHORTCUTS")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(JarvisTheme.textMuted)
                            .kerning(2)

                        VStack(spacing: 8) {
                            ForEach(shortcuts, id: \.label) { shortcut in
                                HStack {
                                    Text(shortcut.label)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(JarvisTheme.textPrimary)
                                    Spacer()
                                    Text(shortcut.keys)
                                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                                        .foregroundStyle(JarvisTheme.textMuted)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(JarvisTheme.sidebar)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                            }
                        }
                    }
                    .padding(20)
                    .frame(width: 340, alignment: .leading)
                    .background(JarvisTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.cardRadius))
                }
            }
            .padding(32)
        }
    }

    private var helpLinks: [(title: String, description: String, icon: String)] {
        [
            ("Getting Started", "Learn the basics of using Jarvis", "book.fill"),
            ("Workflow Guide", "Create and manage automated workflows", "arrow.triangle.branch"),
            ("Teaching Patterns", "Train Jarvis to learn your habits", "brain"),
            ("Troubleshooting", "Fix common issues and errors", "wrench.and.screwdriver.fill"),
        ]
    }

    private var shortcuts: [(label: String, keys: String)] {
        [
            ("Toggle Chat Panel", "⌘⇧J"),
            ("Open Dashboard", "⌘⇧D"),
            ("Quick Search", "⌘K"),
            ("New Conversation", "⌘N"),
        ]
    }
}

private struct HelpLinkRow: View {
    let link: (title: String, description: String, icon: String)

    var body: some View {
        Button(action: {}) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(JarvisTheme.accent.opacity(0.08))
                        .frame(width: 36, height: 36)
                    Image(systemName: link.icon)
                        .font(.system(size: 14))
                        .foregroundStyle(JarvisTheme.accent)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(link.title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(JarvisTheme.textPrimary)
                    Text(link.description)
                        .font(.system(size: 12))
                        .foregroundStyle(JarvisTheme.textMuted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(JarvisTheme.textMuted)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}
