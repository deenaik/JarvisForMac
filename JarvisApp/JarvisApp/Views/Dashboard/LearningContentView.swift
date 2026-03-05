import SwiftUI

struct LearningContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: JarvisTheme.sectionSpacing) {
                // Top bar
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Learning Center")
                            .font(.title.bold())
                            .foregroundStyle(JarvisTheme.textPrimary)
                        Text("See what Jarvis has learned and train new behaviors.")
                            .font(.subheadline)
                            .foregroundStyle(JarvisTheme.textMuted)
                    }
                    Spacer()
                    Button(action: {}) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.caption)
                            Text("Teach New Pattern")
                                .font(.subheadline.bold())
                        }
                        .foregroundStyle(JarvisTheme.background)
                        .padding(.horizontal, 20)
                        .frame(height: 40)
                        .background(JarvisTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.buttonRadius))
                    }
                    .buttonStyle(.plain)
                }

                // Stats row
                HStack(spacing: 16) {
                    ForEach(MockLearningData.stats) { stat in
                        LearningStatCard(stat: stat)
                    }
                }

                // Bottom: Learned Patterns + Knowledge Areas
                HStack(alignment: .top, spacing: 16) {
                    LearnedPatternsCard()
                        .frame(maxWidth: .infinity)
                    KnowledgeAreasCard()
                        .frame(width: 340)
                }
            }
            .padding(32)
        }
    }
}

// MARK: - Stat Card

private struct LearningStatCard: View {
    let stat: LearningStat

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(stat.label)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(JarvisTheme.textMuted)
                .kerning(2)
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(stat.value)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundStyle(stat.changeColor == JarvisTheme.accent ? JarvisTheme.accent : JarvisTheme.textPrimary)
                Text(stat.change)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(stat.changeColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(JarvisTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.cardRadius))
    }
}

// MARK: - Learned Patterns

private struct LearnedPatternsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("LEARNED PATTERNS")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(JarvisTheme.textMuted)
                    .kerning(2)
                Spacer()
                Button("See all →") {}
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(JarvisTheme.accent)
                    .buttonStyle(.plain)
            }

            VStack(spacing: 4) {
                ForEach(MockLearningData.patterns) { pattern in
                    PatternRow(pattern: pattern)
                }
            }
        }
        .padding(20)
        .background(JarvisTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.cardRadius))
    }
}

private struct PatternRow: View {
    let pattern: LearnedPattern

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(JarvisTheme.accent.opacity(0.08))
                    .frame(width: 36, height: 36)
                Image(systemName: pattern.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(JarvisTheme.accent)
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(pattern.title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(JarvisTheme.textPrimary)
                    Spacer()
                    Text("\(pattern.confidence)%")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundStyle(pattern.barColor)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(JarvisTheme.sidebar)
                            .frame(height: 3)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(pattern.barColor)
                            .frame(width: geo.size.width * CGFloat(pattern.confidence) / 100, height: 3)
                    }
                }
                .frame(height: 3)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Knowledge Areas

private struct KnowledgeAreasCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("KNOWLEDGE AREAS")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(JarvisTheme.textMuted)
                .kerning(2)

            VStack(spacing: 10) {
                ForEach(MockLearningData.knowledgeAreas) { area in
                    KnowledgeAreaRow(area: area)
                }
            }
        }
        .padding(20)
        .background(JarvisTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.cardRadius))
    }
}

private struct KnowledgeAreaRow: View {
    let area: KnowledgeArea

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(area.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(JarvisTheme.textPrimary)
                Spacer()
                Text(area.patternCount)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(area.accentColor)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(JarvisTheme.card)
                        .frame(height: 3)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(area.accentColor)
                        .frame(width: geo.size.width * area.progress, height: 3)
                }
            }
            .frame(height: 3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(JarvisTheme.sidebar)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
