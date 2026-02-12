import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @State private var showSuccess = false
    @State private var lastCompletedChore: String = ""
    @State private var completedChoreIds: Set<UUID> = []

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingLG) {
                // MARK: - Greeting Header
                greetingSection

                // MARK: - Person Picker
                personSection

                // MARK: - Today's Progress
                progressSection

                // MARK: - Quick Chores
                choresSection

                // MARK: - Error
                if let error = viewModel.errorMessage {
                    errorBanner(error)
                }
            }
            .padding(.horizontal, AppTheme.spacingMD)
            .padding(.bottom, AppTheme.spacingXL)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Home")
        .overlay(alignment: .top) {
            SuccessToast(message: "\(lastCompletedChore) done!", isShowing: $showSuccess)
                .padding(.top, AppTheme.spacingSM)
        }
        .onAppear { viewModel.refresh() }
    }

    // MARK: - Greeting

    private var greetingSection: some View {
        HStack(spacing: AppTheme.spacingMD) {
            VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                Text(GreetingHelper.greeting())
                    .font(.title2.weight(.bold))
                Text(Date().formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: GreetingHelper.greetingIcon())
                .font(.title)
                .foregroundStyle(.orange.gradient)
        }
        .padding(.top, AppTheme.spacingSM)
    }

    // MARK: - Person Picker

    private var personSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
            SectionHeaderView(title: "WHO'S DOING CHORES?", icon: "person.2")
            PersonPickerView(people: viewModel.people, selectedPersonId: $viewModel.selectedPersonId)
        }
        .glassCard()
    }

    // MARK: - Progress

    private var progressSection: some View {
        HStack(spacing: AppTheme.spacingMD) {
            // Today's points
            VStack(spacing: AppTheme.spacingSM) {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundStyle(.orange.gradient)
                Text(todayPointsForSelected)
                    .font(.title.weight(.bold))
                    .contentTransition(.numericText())
                Text("Today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .glassCard()

            // Leader
            VStack(spacing: AppTheme.spacingSM) {
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow.gradient)
                Text(viewModel.leaderName ?? "--")
                    .font(.title3.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("Leader")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .glassCard()

            // Summary
            VStack(spacing: AppTheme.spacingSM) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green.gradient)
                Text("\(viewModel.todayCompletionCount)")
                    .font(.title.weight(.bold))
                    .contentTransition(.numericText())
                Text("Done")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .glassCard()
        }
    }

    // MARK: - Chores Grid

    private var choresSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            SectionHeaderView(title: "QUICK CHORES", icon: "bolt.fill")

            if viewModel.topChores.isEmpty {
                EmptyStateView(
                    icon: "checklist",
                    title: "No chores yet",
                    subtitle: "Add chores in the Chores tab to start tracking."
                )
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: AppTheme.spacingMD),
                        GridItem(.flexible(), spacing: AppTheme.spacingMD)
                    ],
                    spacing: AppTheme.spacingMD
                ) {
                    ForEach(viewModel.topChores, id: \.id) { chore in
                        ChoreButton(
                            chore: chore,
                            justCompleted: completedChoreIds.contains(chore.id)
                        ) {
                            completeChore(chore)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Error

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: AppTheme.spacingSM) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(message)
                .font(.subheadline)
        }
        .padding(AppTheme.spacingMD)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusSM, style: .continuous))
    }

    // MARK: - Helpers

    private var todayPointsForSelected: String {
        guard let id = viewModel.selectedPersonId,
              let points = viewModel.todayTotals[id], points > 0 else {
            return "0"
        }
        return "\(points)"
    }

    private func completeChore(_ chore: Chore) {
        viewModel.markDone(chore: chore)
        Haptics.success()
        lastCompletedChore = chore.title

        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            completedChoreIds.insert(chore.id)
            showSuccess = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.3)) {
                completedChoreIds.remove(chore.id)
            }
        }
    }
}

// MARK: - Chore Button Card

private struct ChoreButton: View {
    let chore: Chore
    let justCompleted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.spacingSM) {
                HStack {
                    Image(systemName: AppTheme.categoryIcon(for: chore.category))
                        .font(.title3)
                        .foregroundStyle(AppTheme.categoryColor(for: chore.category).gradient)
                    Spacer()
                    PointsBadge(
                        points: chore.points,
                        color: AppTheme.categoryColor(for: chore.category)
                    )
                }

                HStack {
                    Text(chore.title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }

                if let category = chore.category {
                    HStack {
                        Text(category)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
            .padding(AppTheme.spacingMD)
            .background {
                RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous)
                    .fill(justCompleted ? Color.green.opacity(0.12) : Color(.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
            }
            .overlay {
                if justCompleted {
                    RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous)
                        .strokeBorder(Color.green.opacity(0.5), lineWidth: 1.5)
                }
            }
            .scaleEffect(justCompleted ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Complete \(chore.title), \(chore.points) points")
    }
}
