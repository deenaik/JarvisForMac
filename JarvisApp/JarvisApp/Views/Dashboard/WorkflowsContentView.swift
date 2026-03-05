import SwiftUI

struct WorkflowsContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: JarvisTheme.sectionSpacing) {
                // Title bar
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Workflows")
                            .font(.title.bold())
                            .foregroundStyle(JarvisTheme.textPrimary)
                        Text("Manage your automated workflows")
                            .font(.subheadline)
                            .foregroundStyle(JarvisTheme.textSecondary)
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        Button(action: {}) {
                            HStack(spacing: 6) {
                                Image(systemName: "line.3.horizontal.decrease")
                                Text("Filter")
                            }
                            .font(.subheadline)
                            .foregroundStyle(JarvisTheme.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(JarvisTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.buttonRadius))
                        }
                        .buttonStyle(.plain)

                        Button(action: {}) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                Text("New Workflow")
                            }
                            .font(.subheadline.bold())
                            .foregroundStyle(JarvisTheme.background)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(JarvisTheme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: JarvisTheme.buttonRadius))
                        }
                        .buttonStyle(.plain)
                    }
                }

                // 2x2 grid
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    ForEach(MockData.workflows) { workflow in
                        WorkflowCardView(workflow: workflow)
                    }
                }
            }
            .padding(JarvisTheme.sectionSpacing)
        }
    }
}
