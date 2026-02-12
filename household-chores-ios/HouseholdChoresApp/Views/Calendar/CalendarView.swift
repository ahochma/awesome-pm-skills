import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject var viewModel: CalendarViewModel
    @State private var people: [Person] = []
    @State private var showAdd = false
    @State private var editingEvent: AdamCalendarEvent?

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingLG) {
                // MARK: - Permission Card (only when not granted)
                if !viewModel.permissionGranted {
                    permissionCard
                }

                // MARK: - Add Event Button
                if viewModel.permissionGranted {
                    addEventButton
                }

                // MARK: - Upcoming Events
                upcomingSection

                // MARK: - Error
                if let error = viewModel.errorMessage {
                    errorBanner(error)
                }
            }
            .padding(.horizontal, AppTheme.spacingMD)
            .padding(.bottom, AppTheme.spacingXL)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Calendar")
        .sheet(isPresented: $showAdd) {
            NavigationStack {
                CalendarEventEditorView(people: people, initialEvent: nil) { input in
                    viewModel.createEvent(input: input)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $editingEvent) { event in
            NavigationStack {
                CalendarEventEditorView(people: people, initialEvent: event) { input in
                    viewModel.updateEvent(id: event.id, input: input)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            people = (try? modelContext.fetch(FetchDescriptor<Person>()).sorted(by: { $0.name < $1.name })) ?? []
            try? viewModel.refreshUpcoming()
        }
    }

    // MARK: - Permission Card

    private var permissionCard: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(.orange.gradient)

            Text("Calendar Access Needed")
                .font(.headline)

            Text("Grant calendar access to create and view family events.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Haptics.light()
                Task { await viewModel.requestAccess() }
            } label: {
                Text("Grant Access")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, AppTheme.spacingLG)
                    .padding(.vertical, AppTheme.spacingSM + 2)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .glassCard()
    }

    // MARK: - Add Event Button

    private var addEventButton: some View {
        Button {
            Haptics.light()
            showAdd = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                Text("Add Dropoff / Pickup Event")
                    .font(.subheadline.weight(.medium))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.accentColor)
        }
        .glassCard()
    }

    // MARK: - Upcoming Events

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            SectionHeaderView(title: "NEXT 7 DAYS", icon: "calendar")

            if viewModel.upcomingEvents.isEmpty {
                EmptyStateView(
                    icon: "calendar",
                    title: "No upcoming events",
                    subtitle: viewModel.permissionGranted
                        ? "Tap the button above to add a new event."
                        : "Grant calendar access to see your events."
                )
            } else {
                VStack(spacing: AppTheme.spacingSM) {
                    ForEach(viewModel.upcomingEvents) { event in
                        EventCard(event: event) {
                            editingEvent = event
                        } onDelete: {
                            Haptics.medium()
                            withAnimation {
                                viewModel.deleteEvent(id: event.id)
                            }
                        }
                    }
                }
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
}

// MARK: - Event Card

private struct EventCard: View {
    let event: AdamCalendarEvent
    let onEdit: () -> Void
    let onDelete: () -> Void

    private var isDropoff: Bool {
        event.title.contains("Dropoff")
    }

    var body: some View {
        HStack(spacing: AppTheme.spacingMD) {
            // Icon
            Image(systemName: isDropoff ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .font(.title2)
                .foregroundStyle(isDropoff ? Color.blue.gradient : Color.green.gradient)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)

                Text(event.startDate.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().hour().minute()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Menu {
                Button { onEdit() } label: {
                    Label("Edit", systemImage: "pencil")
                }
                Button(role: .destructive) { onDelete() } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, AppTheme.spacingXS)
    }
}
