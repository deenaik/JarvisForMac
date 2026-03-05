import SwiftUI

enum MockData {
    static let stats: [StatCard] = [
        StatCard(title: "Tasks Completed", value: "1,284", change: "+12%", isPositive: true,
                 icon: "checkmark.circle.fill", iconColor: JarvisTheme.accent),
        StatCard(title: "Workflows Active", value: "23", change: "+3", isPositive: true,
                 icon: "arrow.triangle.branch", iconColor: Color(hex: "A78BFA")),
        StatCard(title: "Time Saved", value: "48h", change: "+8h", isPositive: true,
                 icon: "clock.fill", iconColor: Color(hex: "34D399")),
        StatCard(title: "Success Rate", value: "98.5%", change: "+0.5%", isPositive: true,
                 icon: "chart.line.uptrend.xyaxis", iconColor: Color(hex: "FB923C")),
    ]

    static let workflows: [WorkflowItem] = [
        WorkflowItem(name: "Daily Standup Prep", description: "Summarizes git commits, open PRs, and calendar events into a morning brief",
                     icon: "sun.max.fill", iconColor: Color(hex: "FBBF24"),
                     status: .active, runsToday: 1, successRate: "100%", lastRun: "8:00 AM"),
        WorkflowItem(name: "Code Review Assistant", description: "Monitors new PRs, runs static analysis, and posts initial review comments",
                     icon: "chevron.left.forwardslash.chevron.right", iconColor: JarvisTheme.accent,
                     status: .active, runsToday: 7, successRate: "96%", lastRun: "2 min ago"),
        WorkflowItem(name: "Email Digest", description: "Scans inbox hourly, categorizes emails, drafts quick replies for routine messages",
                     icon: "envelope.fill", iconColor: Color(hex: "A78BFA"),
                     status: .paused, runsToday: 0, successRate: "92%", lastRun: "Yesterday"),
        WorkflowItem(name: "Meeting Notes", description: "Records meeting audio, transcribes, extracts action items and sends summaries",
                     icon: "mic.fill", iconColor: Color(hex: "34D399"),
                     status: .active, runsToday: 3, successRate: "99%", lastRun: "1:30 PM"),
    ]

    static let activities: [ActivityItem] = [
        ActivityItem(timestamp: "2:34 PM", title: "Deployed v2.4.1 to staging",
                     description: "Automated deployment triggered by merge to develop branch",
                     icon: "arrow.up.circle.fill", iconColor: JarvisTheme.accent,
                     category: .actions, isCompleted: true),
        ActivityItem(timestamp: "1:45 PM", title: "Learned new API pattern",
                     description: "Stored REST pagination pattern from code review session",
                     icon: "brain", iconColor: Color(hex: "A78BFA"),
                     category: .learning, isCompleted: true),
        ActivityItem(timestamp: "12:30 PM", title: "Organized 47 emails",
                     description: "Categorized inbox: 12 important, 8 follow-up, 27 archived",
                     icon: "envelope.fill", iconColor: Color(hex: "34D399"),
                     category: .actions, isCompleted: true),
        ActivityItem(timestamp: "11:15 AM", title: "Code review on PR #342",
                     description: "Found 3 issues: unused import, missing error handling, type mismatch",
                     icon: "chevron.left.forwardslash.chevron.right", iconColor: JarvisTheme.accent,
                     category: .actions, isCompleted: true),
        ActivityItem(timestamp: "10:00 AM", title: "Updated workflow preferences",
                     description: "User prefers concise summaries over detailed reports",
                     icon: "gearshape.fill", iconColor: Color(hex: "FB923C"),
                     category: .learning, isCompleted: true),
        ActivityItem(timestamp: "9:30 AM", title: "Morning brief generated",
                     description: "3 PRs to review, 2 meetings, 5 priority emails",
                     icon: "sun.max.fill", iconColor: Color(hex: "FBBF24"),
                     category: .actions, isCompleted: true),
        ActivityItem(timestamp: "8:00 AM", title: "System health check",
                     description: "All 23 workflows operational, API latency normal",
                     icon: "heart.fill", iconColor: JarvisTheme.statusActive,
                     category: .actions, isCompleted: true),
    ]

    static let quickActions: [QuickAction] = [
        QuickAction(title: "New Workflow", icon: "plus.circle.fill", color: JarvisTheme.accent),
        QuickAction(title: "Run Report", icon: "doc.text.fill", color: Color(hex: "A78BFA")),
        QuickAction(title: "Search Memory", icon: "magnifyingglass", color: Color(hex: "34D399")),
        QuickAction(title: "Open Terminal", icon: "terminal.fill", color: Color(hex: "FB923C")),
    ]
}
