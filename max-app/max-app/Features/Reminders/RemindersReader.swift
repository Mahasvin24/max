//
//  RemindersReader.swift
//  max-app
//

import EventKit
import Foundation

enum RemindersReaderError: LocalizedError {
    case accessDenied

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            "Max needs Reminders access to sync your tasks."
        }
    }
}

/// Reads the user's currently incomplete reminders and converts them to the
/// small, transport-safe representation expected by the sync endpoint.
@MainActor
final class RemindersReader {
    private let eventStore: EKEventStore

    init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
    }

    /// Requests access when needed, then returns one complete sync snapshot.
    func makePayload() async throws -> ReminderSyncPayload {
        guard try await eventStore.requestFullAccessToReminders() else {
            throw RemindersReaderError.accessDenied
        }

        let reminders = await fetchIncompleteReminders()
        return ReminderSyncPayload(
            reminders: reminders
                .map(ReminderPayload.init(reminder:))
                .sorted { lhs, rhs in
                    lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
                }
        )
    }

    private func fetchIncompleteReminders() async -> [EKReminder] {
        let predicate = eventStore.predicateForIncompleteReminders(
            withDueDateStarting: nil,
            ending: nil,
            calendars: nil
        )

        return await withCheckedContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { reminders in
                continuation.resume(returning: reminders ?? [])
            }
        }
    }
}

private extension ReminderPayload {
    init(reminder: EKReminder) {
        reminderIdentifier = reminder.calendarItemIdentifier
        title = reminder.title
        notes = reminder.notes.nilIfEmpty
        list = ReminderListPayload(
            identifier: reminder.calendar.calendarIdentifier,
            title: reminder.calendar.title
        )
        dueDate = ReminderDateFormatter.string(from: reminder.dueDateComponents)
        url = reminder.url?.absoluteString
        location = reminder.location.nilIfEmpty
            ?? reminder.alarms?
                .compactMap(\.structuredLocation?.title.nilIfEmpty)
                .first
        recurrenceRules = (reminder.recurrenceRules ?? []).map(ReminderRecurrenceRulePayload.init(rule:))
    }
}

private extension ReminderRecurrenceRulePayload {
    init(rule: EKRecurrenceRule) {
        frequency = switch rule.frequency {
        case .daily: "daily"
        case .weekly: "weekly"
        case .monthly: "monthly"
        case .yearly: "yearly"
        @unknown default: "unknown"
        }
        interval = rule.interval
        daysOfTheWeek = (rule.daysOfTheWeek ?? []).map {
            ReminderRecurrenceDayPayload(
                weekday: $0.dayOfTheWeek.rawValue,
                weekNumber: $0.weekNumber
            )
        }
        daysOfTheMonth = rule.daysOfTheMonth?.map(\.intValue) ?? []
        monthsOfTheYear = rule.monthsOfTheYear?.map(\.intValue) ?? []
        weeksOfTheYear = rule.weeksOfTheYear?.map(\.intValue) ?? []
        daysOfTheYear = rule.daysOfTheYear?.map(\.intValue) ?? []
        setPositions = rule.setPositions?.map(\.intValue) ?? []
        endDate = ReminderDateFormatter.string(from: rule.recurrenceEnd?.endDate)

        if let count = rule.recurrenceEnd?.occurrenceCount, count > 0 {
            occurrenceCount = count
        } else {
            occurrenceCount = nil
        }
    }
}

private enum ReminderDateFormatter {
    private static let california = TimeZone(identifier: "America/Los_Angeles")!

    static func string(from components: DateComponents?) -> String? {
        guard var components else { return nil }

        var calendar = components.calendar ?? Calendar(identifier: .gregorian)
        calendar.timeZone = california
        components.calendar = calendar
        components.timeZone = california

        guard let date = calendar.date(from: components) else { return nil }
        return string(from: date)
    }

    static func string(from date: Date?) -> String? {
        guard let date else { return nil }

        let formatter = ISO8601DateFormatter()
        formatter.timeZone = california
        formatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone]
        return formatter.string(from: date)
    }
}

private extension Optional where Wrapped == String {
    var nilIfEmpty: String? {
        guard let value = self?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }
        return value
    }
}
