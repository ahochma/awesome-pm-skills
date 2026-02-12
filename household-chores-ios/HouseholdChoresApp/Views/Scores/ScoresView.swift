import SwiftUI

struct ScoresView: View {
    @StateObject var viewModel: ScoresViewModel
    @State private var showCloseConfirmation = false

    private var monthKeys: [String] {
        MonthKey.lastMonthKeys(count: 12)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingLG) {
                // MARK: - Month Selector
                monthSelector

                // MARK: - Points Table
                pointsSection

                // MARK: - Monthly Winners
                winnersSection

                // MARK: - 6 Month Summary
                sixMonthSection

                // MARK: - History Link
                historyLink

                // MARK: - Error
                if let error = viewModel.errorMessage {
                    errorBanner(error)
                }
            }
            .padding(.horizontal, AppTheme.spacingMD)
            .padding(.bottom, AppTheme.spacingXL)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Scores")
        .onAppear { viewModel.refresh() }
        .alert("Close this month?", isPresented: $showCloseConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Close Month") {
                viewModel.closeSelectedMonth()
                Haptics.success()
            }
        } message: {
            Text("This will finalize scores for \(viewModel.selectedMonthKey) and record the winner. This cannot be undone.")
        }
    }

    // MARK: - Month Selector

    private var monthSelector: some View {
        VStack(spacing: AppTheme.spacingMD) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Month")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    MonthPickerView(selectedMonthKey: $viewModel.selectedMonthKey, keys: monthKeys)
                        .onChange(of: viewModel.selectedMonthKey) { _, _ in viewModel.refresh() }
                }

                Spacer()

                Button {
                    Haptics.medium()
                    showCloseConfirmation = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                        Text("Close")
                            .font(.subheadline.weight(.medium))
                    }
                    .padding(.horizontal, AppTheme.spacingMD)
                    .padding(.vertical, AppTheme.spacingSM)
                    .background(Color.orange.opacity(0.15))
                    .foregroundStyle(.orange)
                    .clipShape(Capsule())
                }
            }
        }
        .glassCard()
    }

    // MARK: - Points Section

    private var pointsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            SectionHeaderView(title: "POINTS THIS MONTH", icon: "chart.bar.fill")

            if viewModel.people.isEmpty {
                EmptyStateView(
                    icon: "person.2.slash",
                    title: "No people yet",
                    subtitle: "Add household members in Settings."
                )
            } else {
                let maxPoints = viewModel.totalsByPerson.values.max() ?? 1

                VStack(spacing: AppTheme.spacingMD) {
                    ForEach(Array(viewModel.people.enumerated()), id: \.element.id) { index, person in
                        let points = viewModel.totalsByPerson[person.id, default: 0]
                        let isLeading = points == maxPoints && points > 0
                        let progress = maxPoints > 0 ? Double(points) / Double(maxPoints) : 0

                        HStack(spacing: AppTheme.spacingMD) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(AppTheme.color(for: index).opacity(0.15))
                                    .frame(width: 36, height: 36)
                                Text(person.name.prefix(1).uppercased())
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(AppTheme.color(for: index))
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(person.name)
                                        .font(.subheadline.weight(.medium))
                                    if isLeading {
                                        Image(systemName: "crown.fill")
                                            .font(.caption2)
                                            .foregroundStyle(.yellow)
                                    }
                                    Spacer()
                                    Text("\(points) pts")
                                        .font(.subheadline.weight(.bold).monospacedDigit())
                                        .foregroundStyle(isLeading ? AppTheme.color(for: index) : .secondary)
                                }

                                GeometryReader { proxy in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                            .fill(Color(.tertiarySystemFill))
                                            .frame(height: 8)
                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                            .fill(AppTheme.color(for: index).gradient)
                                            .frame(width: max(proxy.size.width * progress, progress > 0 ? 8 : 0), height: 8)
                                            .animation(.spring(response: 0.5), value: progress)
                                    }
                                }
                                .frame(height: 8)
                            }
                        }
                    }
                }
            }
        }
        .glassCard()
    }

    // MARK: - Winners Section

    private var winnersSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            SectionHeaderView(title: "MONTHLY WINNERS", icon: "trophy.fill")

            if viewModel.monthlyResults.isEmpty {
                VStack(spacing: AppTheme.spacingSM) {
                    Image(systemName: "trophy")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("No months closed yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.spacingLG)
            } else {
                VStack(spacing: AppTheme.spacingSM) {
                    ForEach(viewModel.monthlyResults, id: \.monthKey) { result in
                        HStack(spacing: AppTheme.spacingMD) {
                            Image(systemName: "trophy.fill")
                                .font(.caption)
                                .foregroundStyle(.yellow)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(formattedMonth(result.monthKey))
                                    .font(.subheadline.weight(.medium))
                                Text(viewModel.winnerText(for: result))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding(.vertical, AppTheme.spacingXS)

                        if result.monthKey != viewModel.monthlyResults.last?.monthKey {
                            Divider()
                        }
                    }
                }
            }
        }
        .glassCard()
    }

    // MARK: - 6 Month Summary

    private var sixMonthSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            SectionHeaderView(title: "LAST 6 MONTHS", icon: "calendar.badge.clock")

            HStack(spacing: AppTheme.spacingMD) {
                ForEach(Array(viewModel.people.enumerated()), id: \.element.id) { index, person in
                    let wins = viewModel.sixMonthWins[person.id, default: 0]

                    VStack(spacing: AppTheme.spacingSM) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.color(for: index).opacity(0.15))
                                .frame(width: 44, height: 44)
                            Text(person.name.prefix(1).uppercased())
                                .font(.headline.weight(.bold))
                                .foregroundStyle(AppTheme.color(for: index))
                        }

                        Text(person.name)
                            .font(.caption.weight(.medium))

                        Text("\(wins)")
                            .font(.title2.weight(.bold).monospacedDigit())
                            .foregroundStyle(AppTheme.color(for: index))

                        Text(wins == 1 ? "win" : "wins")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .glassCard()
    }

    // MARK: - History Link

    private var historyLink: some View {
        NavigationLink {
            HistoryView(monthKey: viewModel.selectedMonthKey)
        } label: {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundStyle(.accentColor)
                Text("View completion history")
                    .font(.subheadline.weight(.medium))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .glassCard()
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

    private func formattedMonth(_ key: String) -> String {
        // key format is "2025-01"
        let parts = key.split(separator: "-")
        guard parts.count == 2,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              month >= 1 && month <= 12 else { return key }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        return key
    }
}
