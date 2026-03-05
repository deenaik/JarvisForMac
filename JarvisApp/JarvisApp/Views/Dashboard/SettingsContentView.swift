import SwiftUI

struct SettingsContentView: View {
    @State private var generalToggles: [Bool] = MockSettingsData.generalSettings.map(\.isOn)
    @State private var privacyToggles: [Bool] = MockSettingsData.privacySettings.map(\.isOn)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: JarvisTheme.sectionSpacing) {
                // Title
                VStack(alignment: .leading, spacing: 4) {
                    Text("Settings")
                        .font(.title.bold())
                        .foregroundStyle(JarvisTheme.textPrimary)
                    Text("Configure Jarvis preferences and permissions.")
                        .font(.subheadline)
                        .foregroundStyle(JarvisTheme.textMuted)
                }

                // Body: left column (toggles) + right column (about + data)
                HStack(alignment: .top, spacing: 24) {
                    // Left column
                    VStack(spacing: 16) {
                        SettingsSection(title: "GENERAL", toggles: MockSettingsData.generalSettings, states: $generalToggles)
                        SettingsSection(title: "PRIVACY & PERMISSIONS", toggles: MockSettingsData.privacySettings, states: $privacyToggles)
                    }
                    .frame(maxWidth: .infinity)

                    // Right column
                    VStack(spacing: 16) {
                        AboutCard()
                        DataManagementCard()
                    }
                    .frame(width: 340)
                }
            }
            .padding(32)
        }
    }
}

// MARK: - Settings Section

private struct SettingsSection: View {
    let title: String
    let toggles: [SettingsToggle]
    @Binding var states: [Bool]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(JarvisTheme.textMuted)
                .kerning(2)
                .padding(.bottom, 4)

            ForEach(Array(toggles.enumerated()), id: \.element.id) { index, toggle in
                if index > 0 {
                    Rectangle()
                        .fill(JarvisTheme.sidebar)
                        .frame(height: 1)
                }
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(toggle.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(JarvisTheme.textPrimary)
                        Text(toggle.description)
                            .font(.system(size: 12))
                            .foregroundStyle(JarvisTheme.textMuted)
                    }
                    Spacer()
                    SettingsToggleSwitch(isOn: $states[index])
                }
                .padding(.vertical, 14)
            }
        }
        .padding(20)
        .background(JarvisTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.cardRadius))
    }
}

// MARK: - Custom Toggle

private struct SettingsToggleSwitch: View {
    @Binding var isOn: Bool

    var body: some View {
        Button(action: { isOn.toggle() }) {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(isOn ? JarvisTheme.accent : JarvisTheme.label)
                    .frame(width: 44, height: 24)
                Circle()
                    .fill(.white)
                    .frame(width: 18, height: 18)
                    .padding(3)
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isOn)
    }
}

// MARK: - About Card

private struct AboutCard: View {
    var body: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(JarvisTheme.accent)
                    .frame(width: 56, height: 56)
                Text("J")
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundStyle(JarvisTheme.background)
            }

            Text("Jarvis for Mac")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(JarvisTheme.textPrimary)

            Text("Version 2.4.1 (build 847)")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(JarvisTheme.textMuted)

            Rectangle()
                .fill(JarvisTheme.sidebar)
                .frame(height: 1)

            VStack(spacing: 10) {
                ForEach(MockSettingsData.aboutInfo) { row in
                    HStack {
                        Text(row.label)
                            .font(.system(size: 12))
                            .foregroundStyle(JarvisTheme.textMuted)
                        Spacer()
                        Text(row.value)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(JarvisTheme.textPrimary)
                    }
                }
            }
        }
        .padding(24)
        .background(JarvisTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.cardRadius))
    }
}

// MARK: - Data Management

private struct DataManagementCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DATA MANAGEMENT")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(JarvisTheme.textMuted)
                .kerning(2)

            VStack(spacing: 8) {
                ForEach(MockSettingsData.dataActions) { action in
                    Button(action: {}) {
                        HStack(spacing: 12) {
                            Image(systemName: action.icon)
                                .font(.system(size: 14))
                                .foregroundStyle(JarvisTheme.textSecondary)
                                .frame(width: 16)
                            Text(action.title)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(JarvisTheme.textPrimary)
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(JarvisTheme.sidebar)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .background(JarvisTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.cardRadius))
    }
}
