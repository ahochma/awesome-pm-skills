import EventKit
import Foundation
import Combine

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var permissionGranted = false
    @Published var upcomingEvents: [AdamCalendarEvent] = []
    @Published var selectedCalendar: EKCalendar?
    @Published var errorMessage: String?

    private let calendarService: CalendarServiceProtocol

    init(calendarService: CalendarServiceProtocol) {
        self.calendarService = calendarService
    }

    func requestAccess() async {
        do {
            permissionGranted = try await calendarService.requestAccess()
            if permissionGranted {
                selectedCalendar = try calendarService.ensureTargetCalendar(named: "Family Tasks")
                try refreshUpcoming()
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshUpcoming() throws {
        upcomingEvents = try calendarService.upcomingWeekEvents(in: selectedCalendar)
    }

    func createEvent(input: AdamCalendarEventInput) {
        do {
            _ = try calendarService.createEvent(input, in: selectedCalendar)
            try refreshUpcoming()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateEvent(id: String, input: AdamCalendarEventInput) {
        do {
            try calendarService.updateEvent(eventId: id, input: input)
            try refreshUpcoming()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteEvent(id: String) {
        do {
            try calendarService.deleteEvent(eventId: id)
            try refreshUpcoming()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
