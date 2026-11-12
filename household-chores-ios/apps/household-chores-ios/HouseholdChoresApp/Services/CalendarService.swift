import EventKit
import Foundation

struct AdamCalendarEvent: Identifiable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let notes: String?
}

struct AdamCalendarEventInput {
    let type: AdamEventType
    let personName: String
    let startDate: Date
    let endDate: Date
    let notes: String?
}

protocol CalendarServiceProtocol {
    func requestAccess() async throws -> Bool
    func ensureTargetCalendar(named name: String?) throws -> EKCalendar
    func upcomingWeekEvents(in calendar: EKCalendar?) throws -> [AdamCalendarEvent]
    func createEvent(_ input: AdamCalendarEventInput, in calendar: EKCalendar?) throws -> String
    func updateEvent(eventId: String, input: AdamCalendarEventInput) throws
    func deleteEvent(eventId: String) throws
}

final class CalendarService: CalendarServiceProtocol {
    private let eventStore = EKEventStore()

    func requestAccess() async throws -> Bool {
        try await eventStore.requestFullAccessToEvents()
    }

    func ensureTargetCalendar(named name: String? = "Family Tasks") throws -> EKCalendar {
        if let name, let existing = eventStore.calendars(for: .event).first(where: { $0.title == name }) {
            return existing
        }
        if let defaultCalendar = eventStore.defaultCalendarForNewEvents {
            return defaultCalendar
        }
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = name ?? "Family Tasks"
        calendar.source = eventStore.defaultCalendarForNewEvents?.source ?? eventStore.sources.first
        try eventStore.saveCalendar(calendar, commit: true)
        return calendar
    }

    func upcomingWeekEvents(in calendar: EKCalendar?) throws -> [AdamCalendarEvent] {
        let start = Date()
        let end = Calendar.current.date(byAdding: .day, value: 7, to: start) ?? start
        let calendars = calendar.map { [$0] } ?? nil
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: calendars)
        return eventStore.events(matching: predicate)
            .filter { $0.title?.hasPrefix("Adam ") == true }
            .sorted(by: { $0.startDate < $1.startDate })
            .compactMap {
                guard let id = $0.eventIdentifier,
                      let title = $0.title else {
                    return nil
                }
                return AdamCalendarEvent(
                    id: id,
                    title: title,
                    startDate: $0.startDate,
                    endDate: $0.endDate,
                    notes: $0.notes
                )
            }
    }

    func createEvent(_ input: AdamCalendarEventInput, in calendar: EKCalendar?) throws -> String {
        let event = EKEvent(eventStore: eventStore)
        event.title = input.type.title(personName: input.personName)
        event.startDate = input.startDate
        event.endDate = input.endDate
        event.notes = input.notes
        if let calendar {
            event.calendar = calendar
        } else {
            event.calendar = try ensureTargetCalendar(named: "Family Tasks")
        }
        try eventStore.save(event, span: .thisEvent, commit: true)
        return event.eventIdentifier
    }

    func updateEvent(eventId: String, input: AdamCalendarEventInput) throws {
        guard let event = eventStore.event(withIdentifier: eventId) else { return }
        event.title = input.type.title(personName: input.personName)
        event.startDate = input.startDate
        event.endDate = input.endDate
        event.notes = input.notes
        try eventStore.save(event, span: .thisEvent, commit: true)
    }

    func deleteEvent(eventId: String) throws {
        guard let event = eventStore.event(withIdentifier: eventId) else { return }
        try eventStore.remove(event, span: .thisEvent, commit: true)
    }
}
