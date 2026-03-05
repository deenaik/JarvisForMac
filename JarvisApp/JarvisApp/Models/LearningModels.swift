import SwiftUI

struct LearningStat: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let change: String
    let changeColor: Color
}

struct LearnedPattern: Identifiable {
    let id = UUID()
    let title: String
    let confidence: Int
    let icon: String
    let barColor: Color
}

struct KnowledgeArea: Identifiable {
    let id = UUID()
    let name: String
    let patternCount: String
    let progress: CGFloat // 0-1
    let accentColor: Color
}

struct SettingsToggle: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let isOn: Bool
}

struct DataAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
}

struct AboutInfoRow: Identifiable {
    let id = UUID()
    let label: String
    let value: String
}

enum MockLearningData {
    static let stats: [LearningStat] = [
        LearningStat(label: "PATTERNS LEARNED", value: "342", change: "+18 this week", changeColor: JarvisTheme.accent),
        LearningStat(label: "TRAINING SESSIONS", value: "56", change: "by you", changeColor: JarvisTheme.textMuted),
        LearningStat(label: "MODEL CONFIDENCE", value: "94.7%", change: "↑ 2.1%", changeColor: JarvisTheme.accent),
    ]

    static let patterns: [LearnedPattern] = [
        LearnedPattern(title: "Newsletter emails → Archive", confidence: 99, icon: "envelope.fill", barColor: JarvisTheme.accent),
        LearnedPattern(title: ".pdf files → Documents/PDFs", confidence: 98, icon: "folder.fill", barColor: JarvisTheme.accent),
        LearnedPattern(title: "Morning routine → Slack, Figma, VS Code", confidence: 89, icon: "terminal.fill", barColor: JarvisTheme.accent),
        LearnedPattern(title: "Meeting recap → #engineering Slack", confidence: 72, icon: "mic.fill", barColor: JarvisTheme.textSecondary),
    ]

    static let knowledgeAreas: [KnowledgeArea] = [
        KnowledgeArea(name: "Email Management", patternCount: "156 patterns", progress: 1.0, accentColor: JarvisTheme.accent),
        KnowledgeArea(name: "File Organization", patternCount: "98 patterns", progress: 0.71, accentColor: JarvisTheme.accent),
        KnowledgeArea(name: "App Workflows", patternCount: "54 patterns", progress: 0.52, accentColor: JarvisTheme.accent),
        KnowledgeArea(name: "Meeting Notes", patternCount: "34 patterns", progress: 0.32, accentColor: JarvisTheme.textSecondary),
    ]
}

enum MockSettingsData {
    static let generalSettings: [SettingsToggle] = [
        SettingsToggle(title: "Launch at startup", description: "Start Jarvis when you log in to your Mac", isOn: true),
        SettingsToggle(title: "Show in menu bar", description: "Display Jarvis icon in the macOS menu bar", isOn: true),
        SettingsToggle(title: "Sound notifications", description: "Play sounds for completed automations", isOn: false),
    ]

    static let privacySettings: [SettingsToggle] = [
        SettingsToggle(title: "Screen recording access", description: "Allow Jarvis to observe your screen for learning", isOn: true),
        SettingsToggle(title: "Accessibility permissions", description: "Control apps and automate UI interactions", isOn: true),
        SettingsToggle(title: "File system access", description: "Read and organize files in selected folders", isOn: true),
    ]

    static let aboutInfo: [AboutInfoRow] = [
        AboutInfoRow(label: "Model", value: "Local + Cloud"),
        AboutInfoRow(label: "Storage used", value: "1.2 GB"),
        AboutInfoRow(label: "Last updated", value: "Mar 3, 2026"),
    ]

    static let dataActions: [DataAction] = [
        DataAction(title: "Export learned data", icon: "externaldrive.fill"),
        DataAction(title: "Import configuration", icon: "square.and.arrow.up"),
        DataAction(title: "Reset all learned data", icon: "trash"),
    ]
}
